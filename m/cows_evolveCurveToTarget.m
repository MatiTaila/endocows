function [startCurve, active, ends, labels, d, cont] = cows_evolveCurveToTarget(im, startCurve, targetCurve, evolve, evolveToInterior, opt, logPath, dIni, labels, maxInd)

if ~evolveToInterior
	startCurve = flipud(startCurve);
end

N = size(startCurve,1);
if dIni == 0
	d = zeros(N,1);
else
	d = dIni;
end

if nargin<9
	labels = (1:N)';
	maxInd = N;
end
colors = cows_colors();

if opt.plot >= 2
	figure(opt.figNum); axis(opt.ax)
	imshow(im);
	hold on;
	plot(startCurve(:,1),startCurve(:,2))
	for i=1:N
		plot(startCurve(i,1),startCurve(i,2),'*','color',colors{evolve(i)+4})
	end
end

eta		= 0.2; % Paso de la evolucion
cont	= 1;
ends	= (1:N)';
active	= ones(N,1);
normals = zeros(N,4);

if opt.log
	fid = fopen(logPath,'a');
	fprintf(fid,strtrim(sprintf('%d\t', labels)));
	fprintf(fid,'\n');
	fprintf(fid,strtrim(sprintf('%.3f\t', startCurve(:,1))));
	fprintf(fid,'\n');
	fprintf(fid,strtrim(sprintf('%.3f\t', startCurve(:,2))));
	fprintf(fid,'\n');
end

while sum(evolve)>0
	N = size(startCurve,1);
	
	% Paso fijo
	kappa = eta*ones(N,1);
	
	% Calculo de normales y evolucion
	startCurvePrev = startCurve;	
	for i=1:N
		if evolve(i)
			left = i-1;
			if left==0, left = N; end
			while ~active(left), left = left-1; if left==0, left = N; end; end;
			right = i+1;
			if right>N, right = 1; end
			while ~active(right), right=right+1; if right>N, right = 1; end; end;
			
			n = [-(startCurvePrev(right,2)-startCurvePrev(left,2)), startCurvePrev(right,1)-startCurvePrev(left,1)];
			n = n/norm(n);
			normals(i,:) = [startCurve(i,:) n];
			startCurve(i,:) = startCurve(i,:)+kappa(i)*n;
			d(i) = d(i) + kappa(i);
		end
	end
	
	% plot
	if opt.visualize
		figure(opt.figNum);
		hold off; imshow(im); hold on; axis(opt.ax);		
		plot(startCurve(logical(active),1),startCurve(logical(active),2), 'color', colors{1})
		for i=1:size(startCurve,1)
			plot(startCurve(i,1),startCurve(i,2),'*','color',colors{evolve(i)+4})
			line([normals(i,1) normals(i,1)+normals(i,3)],[normals(i,2) normals(i,2)+normals(i,4)], 'color', 'r');
		end
		drawnow
% 		pause
	end
	
	% Union de puntos
	if opt.fusion_type == 1
		ind = intersectNormals(normals,active,eta);
	elseif opt.fusion_type == 2
		ind = intersectNormals2(normals,active,1);
	end
	
	for k = 1:size(ind,1)
		if evolve(ind(k,1)) && evolve(ind(k,2))
			tmp_flag=0;
			for mp=ind(k,1)+1:ind(k,2)-1 % recorro los puntos de medio
				if ~evolve(mp) && active(mp) % si el punto pertenece a una frontera
					tmp_flag = 1;
				end
			end
			if ~tmp_flag % todos los del medio tambien evolucionan
				startCurve(ind(k,1),:) = [(startCurve(ind(k,1),1)+startCurve(ind(k,2),1))/2,(startCurve(ind(k,1),2)+startCurve(ind(k,2),2))/2];
				i = min(ind(k,:));
				j = max(ind(k,:));
			else
				disp('este caso tengo q implementarlo. se da cuando uno de los puntos del medio (entre 2 que se juntan) ya pertenece a la frontera')
				keyboard
				startCurve(ind(k,1),:) = [(startCurve(ind(k,1),1)+startCurve(ind(k,2),1))/2,(startCurve(ind(k,1),2)+startCurve(ind(k,2),2))/2];
				i = min(ind(k,:));
				j = max(ind(k,:));
				disp(sprintf('\n Ojo!! Aca hay 2 puntos que se juntan pero entre medio de ellos hay algun punto que no debe evlucionar \n'));
			end
		elseif evolve(ind(k,1)) && ~evolve(ind(k,2))
			i = ind(k,2);
			j = ind(k,1);
		elseif ~evolve(ind(k,1)) && evolve(ind(k,2))
			i = ind(k,1);
			j = ind(k,2);
		end
		if evolve(ind(k,1)) || evolve(ind(k,2))
			desactivate = zeros(N,1);
			desactivate(i+1:j) = 1;
			if sum(desactivate) > N/2
				desactivate = zeros(N,1);
				desactivate(1:i-1) = 1;
				desactivate(j) = 1;
			end
			ends(logical(desactivate))   = i;
			evolve(logical(desactivate)) = 0;
			active(logical(desactivate)) = 0;
		end
	end
	
	% Intersecion con la targetCurve
	for i=1:N
		p = intersectLinePolygon(normals(i,:).*[1 1 kappa(i) kappa(i)], targetCurve);
		xMin = min([normals(i,1)-normals(i,3)*kappa(i) normals(i,1)+normals(i,3)*kappa(i)]);
		xMax = max([normals(i,1)-normals(i,3)*kappa(i) normals(i,1)+normals(i,3)*kappa(i)]);
		yMin = min([normals(i,2)-normals(i,4)*kappa(i) normals(i,2)+normals(i,4)*kappa(i)]);
		yMax = max([normals(i,2)-normals(i,4)*kappa(i) normals(i,2)+normals(i,4)*kappa(i)]);
		for j=1:size(p,1)
			if p(j,1)>xMin*(1-eps) && p(j,1)<xMax*(1+eps) && p(j,2)>yMin*(1-eps) && p(j,2)<yMax*(1+eps)
				d(i) = d(i) - norm(startCurve(i,:)-p(j,:));
				startCurve(i,:)  = p(j,:);				
				evolve(i) = 0;
			end
		end
	end
	
	% Creo puntos entre medio de puntos que estan muy lejos
	add = [];	
	aux = zeros(N,3);
	for i=1:N
		left = i-1;
		if left==0, left = N; end
		while ~active(left), left = left-1; if left==0, left = N; end; end;
		aux(i,:) = [left startCurve(i,1)-startCurve(left,1) startCurve(i,2)-startCurve(left,2)];
	end
	
	difs = [aux(:,1) aux(:,2).^2+aux(:,3).^2];
	if cont==1
		thr = mean(difs(:,2))*4;
	end
	difs(~active,2) = 0;
	difs(~evolve,2) = 0;
	
	for i=1:N
		if difs(i,2) > thr
			add = [add ; i (startCurve(i,1)+startCurve(difs(i,1),1))/2 (startCurve(i,2)+startCurve(difs(i,1),2))/2];
% 			keyboard
		end
	end
	
	% Agrego los puntos a la curva, del ultimo al primero
	ind = 1;
	for i=size(add,1):-1:1
		startCurve = [startCurve ; 0 0];
		startCurve(add(i,1)+1:end,:) = startCurve(add(i,1):end-1,:);
		startCurve(add(i,1),:) = add(i,2:3);
		
		active = [active ; 0];
		active(add(i,1)+1:end) = active(add(i,1):end-1);
		active(add(i,1),:) = 1;
		
		ends = [ends ; 0];
		ends(add(i,1)+1:end) = ends(add(i,1):end-1);
		ends(add(i,1)) = ends(i);
		
		evolve = [evolve ; 0];
		evolve(add(i,1)+1:end) = evolve(add(i,1):end-1);
		left = add(i,1)-1;
		if left==0, left = N; end
		while ~active(left), left = left-1; if left==0, left = N; end; end;
		right = add(i,1)+1;
		if right>N, right = 1; end
		while ~active(right), right=right+1; if right>N, right = 1; end; end;
		if ( evolve(left)==0 && evolve(right)==0 )
			evolve(add(i,1)) = 0;
		else
			evolve(add(i,1)) = 1;
		end
		
		labels = [labels ; 0];
		labels(add(i,1)+1:end) = labels(add(i,1):end-1);
		labels(add(i,1)) = maxInd+ind;
		ind = ind+1;
		
		d = [d ; 0];
		d(add(i,1)+1:end) = d(add(i,1):end-1);
		d(add(i,1)) = d(left);
		
		normals = [normals ; 0 0 0 0];
		normals(add(i,1)+1:end,:) = normals(add(i,1):end-1,:);
		normals(add(i,1),:) = normals(add(i,1),:);
	end
	maxInd = maxInd+size(add,1);
	
	cont = cont+1;
	
	if opt.log
		fprintf(fid,strtrim(sprintf('%d\t', labels(logical(active)))));
		fprintf(fid,'\n');
		fprintf(fid,strtrim(sprintf('%.3f\t', startCurve(logical(active),1))));
		fprintf(fid,'\n');
		fprintf(fid,strtrim(sprintf('%.3f\t', startCurve(logical(active),2))));
		fprintf(fid,'\n');
	end
end

if opt.log
	fclose(fid);
end

if ~evolveToInterior
	startCurve = flipud(startCurve);
	for i=1:N
		ends(i) = N-i+1;
	end
	ends   = flipud(ends);
	active = flipud(active);
	d	   = flipud(d);
end

end

function list = intersectNormals(n,active,eta)
list = [];
N    = size(n,1);
for i=1:N
	if active(i)
		i_xMin = min([n(i,1) n(i,1)+n(i,3)*eta]);
		i_xMax = max([n(i,1) n(i,1)+n(i,3)*eta]);
		i_yMin = min([n(i,2) n(i,2)+n(i,4)*eta]);
		i_yMax = max([n(i,2) n(i,2)+n(i,4)*eta]);
		for j=i+1:N
			if active(j)
				p = intersectLines(n(i,:),n(j,:));
				if p(1)>i_xMin && p(1)<i_xMax && p(2)>i_yMin && p(2)<i_yMax
						j_xMin = min([n(j,1) n(j,1)+n(j,3)*eta]);
						j_xMax = max([n(j,1) n(j,1)+n(j,3)*eta]);
						j_yMin = min([n(j,2) n(j,2)+n(j,4)*eta]);
						j_yMax = max([n(j,2) n(j,2)+n(j,4)*eta]);
						if p(1)>j_xMin && p(1)<j_xMax && p(2)>j_yMin && p(2)<j_yMax
							list = [list; i j];
						end
				end
			end
		end
	end
end

erase = zeros(size(list,1),1);
for i=1:size(list,1)-1
	if list(i,1)==list(i+1,1)
		erase(i)=1;
	end
end
list(logical(erase),:) = [];
end

function list = intersectNormals2(n,active,eta)
list = [];
N    = size(n,1);
if(active(1))
	i = 1;
	j = N;
	while ~active(j), j=j-1; if j==0, j=N; end; end;
	p = intersectLines(n(i,:),n(j,:));
	i_xMin = min([n(i,1) n(i,1)+n(i,3)*eta]);
	i_xMax = max([n(i,1) n(i,1)+n(i,3)*eta]);
	i_yMin = min([n(i,2) n(i,2)+n(i,4)*eta]);
	i_yMax = max([n(i,2) n(i,2)+n(i,4)*eta]);
	if p(1)>i_xMin && p(1)<i_xMax && p(2)>i_yMin && p(2)<i_yMax
		j_xMin = min([n(j,1) n(j,1)+n(j,3)*eta]);
		j_xMax = max([n(j,1) n(j,1)+n(j,3)*eta]);
		j_yMin = min([n(j,2) n(j,2)+n(j,4)*eta]);
		j_yMax = max([n(j,2) n(j,2)+n(j,4)*eta]);
		if p(1)>j_xMin && p(1)<j_xMax && p(2)>j_yMin && p(2)<j_yMax
			list = [list; j i];
		end
	end	
end
for i=2:N
	if(active(i))
		j = i-1;
		if j==0, j=N; end
		while ~active(j), j=j-1; if j==0, j=N; end; end;
		p = intersectLines(n(i,:),n(j,:));
		i_xMin = min([n(i,1) n(i,1)+n(i,3)*eta]);
		i_xMax = max([n(i,1) n(i,1)+n(i,3)*eta]);
		i_yMin = min([n(i,2) n(i,2)+n(i,4)*eta]);
		i_yMax = max([n(i,2) n(i,2)+n(i,4)*eta]);
		if p(1)>i_xMin && p(1)<i_xMax && p(2)>i_yMin && p(2)<i_yMax
			j_xMin = min([n(j,1) n(j,1)+n(j,3)*eta]);
			j_xMax = max([n(j,1) n(j,1)+n(j,3)*eta]);
			j_yMin = min([n(j,2) n(j,2)+n(j,4)*eta]);
			j_yMax = max([n(j,2) n(j,2)+n(j,4)*eta]);
			if p(1)>j_xMin && p(1)<j_xMax && p(2)>j_yMin && p(2)<j_yMax
				list = [list; j i];
				fprintf('| ');
			end
		end
	end
end
% fprintf('\n')
end

	
	% Paso en funcion de la Curvatura
% 	x= startCurve(:,1)'; y= startCurve(:,2)';
% 	x1 = circshift(x,[0 1]); x2 = x; x3 = circshift(x,[0 -1]);
% 	y1 = circshift(y,[0 1]); y2 = y; y3 = circshift(y,[0 -1]);
% 	a = sqrt((x3-x2).^2+(y3-y2).^2); % a, b, and c are the three sides
% 	b = sqrt((x1-x3).^2+(y1-y3).^2);
% 	c = sqrt((x2-x1).^2+(y2-y1).^2);
% 	A = 1/2*(x1.*y2+x2.*y3+x3.*y1-x1.*y3-x2.*y1-x3.*y2); % The triangle's area
% 	kappa = [0,4*A./(a.*b.*c),0]; % The reciprocal of its circumscribed radius
% 	kappa = abs(kappa)/max(abs(kappa));
 	
	% Paso en funcion de la distancia al target
% 	mask = roipoly(im,targetCurve(:,1),targetCurve(:,2));
% 	[D, ~] = bwdist(mask);
% 	for i=1:N
% 		cHullDist(i) = D(round(startCurve(i,1)),round(startCurve(i,2)));
% 	end
% 	kappa = cHullDist/max(cHullDist+0.1)+0.1;
