function [mioWidth, endoWidth] = cows_getCurvesWidth(patient, nImg)
% -------------------------------------------------------------------------
% function [mioWidth, endoWidth] = cows_getCurvesWidth(patient, nImg)
% -------------------------------------------------------------------------
% load('cows_cfg');
% cows_getCurvesWidth(patients(2),2)
% -------------------------------------------------------------------------

figNum		  = 7;
opt.plot	  = 1;
opt.visualize = 1;
colors		  = cows_colors();
im			  = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);

% Segmentacion de la luz
nCurve = 3;
[xsLuz,ysLuz] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
luz = [xsLuz' ysLuz'];



luz = luz(1:end-1,:); % OJO ESTE ES UN FIX PARA ESTA IMAGEN QUE ESTA MAL SEGMENTADA



N   = size(luz,1);
ax  = [min(luz(:,1))-1 max(luz(:,1))+1 min(luz(:,2))-1 max(luz(:,2))+1];



% luz=flipud(luz); % OJO ESTE ES UN FIX PARA ESTA IMAGEN QUE ESTA MAL SEGMENTADA



luz_orig = luz;

% Marcar los segmentos a evolucionar
[~,cHullInd] = convexHull(luz);
evolve = ones(N,1); evolve(cHullInd) = 0;

if opt.plot
	figure(figNum);
	imshow(im);
	hold on;
	plot(luz(:,1),luz(:,2))
	for i=1:N
		plot(luz(i,1),luz(i,2),'*','color',colors{evolve(i)+4})
	end
end

% thr = mean(distancia(luz))/2;

ends   = (1:N)';
active = ones(N,1);
% distance = zeros(N,1);
eta   = 0.1; % Paso de la evolucion
cont = 1;
normals = zeros(N,4);

cHullDist = zeros(N,1);

while sum(evolve)>0
	% Paso en funcion de la Curvatura
% 	x= luz(:,1)'; y= luz(:,2)';
% 	x1 = circshift(x,[0 1]); x2 = x; x3 = circshift(x,[0 -1]);
% 	y1 = circshift(y,[0 1]); y2 = y; y3 = circshift(y,[0 -1]);
% 	a = sqrt((x3-x2).^2+(y3-y2).^2); % a, b, and c are the three sides
% 	b = sqrt((x1-x3).^2+(y1-y3).^2);
% 	c = sqrt((x2-x1).^2+(y2-y1).^2);
% 	A = 1/2*(x1.*y2+x2.*y3+x3.*y1-x1.*y3-x2.*y1-x3.*y2); % The triangle's area
% 	kappa = [0,4*A./(a.*b.*c),0]; % The reciprocal of its circumscribed radius
% 	kappa = abs(kappa)/max(abs(kappa));
 	
	% Paso en funcion de la distancia al Convex Hull
% 	mask = roipoly(im,luz_orig(cHullInd,1),luz_orig(cHullInd,2));
% 	[D, ~] = bwdist(mask);
% 	for i=1:N
% 		cHullDist(i) = D(round(luz(i,1)),round(luz(i,2)));
% 	end
% 	kappa = cHullDist/max(cHullDist+0.1)+0.1;
	
	% Paso fijo
	kappa = eta*ones(N,1);
	
	luzPrev = luz;
	
	if evolve(1)
% 		n = [-(luz(1,2)-luz(N,2)), luz(1,1)-luz(N,1)];
		n = [-(luzPrev(2,2)-luzPrev(N,2)), luzPrev(2,1)-luzPrev(N,1)];
		n = n/norm(n);
		normals(1,:) = [luz(1,:) n];
		luz(1,:) = luz(1,:)+kappa(1)*n;
% 		distance(1) = distance(1)+eta;
	end
	for i = 2:N-1
		if evolve(i)
% 			n = [-(luz(i,2)-luz(i-1,2)), luz(i,1)-luz(i-1,1)]; % n = [-dy,dx]
			n = [-(luzPrev(i+1,2)-luzPrev(i-1,2)), luzPrev(i+1,1)-luzPrev(i-1,1)];
			n = n/norm(n);
			normals(i,:) = [luz(i,:) n];
			luz(i,:) = luz(i,:)+kappa(i)*n;
% 			distance(i) = distance(i)+eta;
		end
	end
	if evolve(N)
		n = [-(luzPrev(1,2)-luzPrev(N-1,2)), luzPrev(1,1)-luzPrev(N-1,1)];
		n = n/norm(n);
		normals(N,:) = [luz(N,:) n];
		luz(N,:) = luz(N,:)+kappa(N)*n;
	end
	
	% Union de puntos
	intersects = zeros(N,1);
	p = intersectLines(normals(1,:),normals(N,:));
	xMin = min([normals(1,1) normals(1,1)+normals(1,3)]);% normals(N,1) normals(N,1)+normals(N,3)]);
	xMax = max([normals(1,1) normals(1,1)+normals(1,3)]);% normals(N,1) normals(N,1)+normals(N,3)]);
	yMin = min([normals(1,2) normals(1,2)+normals(1,4)]);% normals(N,2) normals(N,2)+normals(N,4)]);
	yMax = max([normals(1,2) normals(1,2)+normals(1,4)]);% normals(N,2) normals(N,2)+normals(N,4)]);
	if p(1)>xMin && p(1)<xMax && p(2)>yMin && p(2)<yMax
		intersects(i)=1;
	end
	for i=2:N
		p = intersectLines(normals(i,:),normals(i-1,:));
		xMin = min([normals(i,1) normals(i,1)+normals(i,3)]);% normals(i-1,1) normals(i-1,1)+normals(i-1,3)]);
		xMax = max([normals(i,1) normals(i,1)+normals(i,3)]);% normals(i-1,1) normals(i-1,1)+normals(i-1,3)]);
		yMin = min([normals(i,2) normals(i,2)+normals(i,4)]);% normals(i-1,2) normals(i-1,2)+normals(i-1,4)]);
		yMax = max([normals(i,2) normals(i,2)+normals(i,4)]);% normals(i-1,2) normals(i-1,2)+normals(i-1,4)]);
		if p(1)>xMin && p(1)<xMax && p(2)>yMin && p(2)<yMax
			intersects(i)=1;
		end
	end
	ind = find(intersects);
% 	ind = find(distancia(luz)<thr);

	for k = 1:length(ind)
		if (ind(k)==1)
			if evolve(1) && evolve(N)
				luz(1,:) = [(luz(1,1)+luz(N,1))/2,(luz(1,2)+luz(N,2))/2];
				i = 1;
				j = N;
			elseif evolve(1) && ~evolve(N)
				i = N;
				j = 1;
			elseif ~evolve(1) && evolve(N)
				i = 1;
				j = N;
			end
			if evolve(1) || evolve(N)
				ends(j)   = i;
				evolve(j) = 0;
				active(j) = 0;
			end			
		else
			if evolve(ind(k)) && evolve(ind(k)-1)
				luz(ind(k),:) = [(luz(ind(k),1)+luz(ind(k)-1,1))/2,(luz(ind(k),2)+luz(ind(k)-1,2))/2];
% 				p = intersectLines(normals(ind(k),:),normals(ind(k)-1,:));
% 				luz(ind(k),:) = p;
				i = ind(k);
				j = ind(k)-1;
			elseif evolve(ind(k)) && ~evolve(ind(k)-1)
				i = ind(k)-1;
				j = ind(k);
			elseif ~evolve(ind(k)) && evolve(ind(k)-1)
				i = ind(k);
				j = ind(k)-1;
			end
			if evolve(ind(k)) || evolve(ind(k)-1)
				ends(j)   = i;
				evolve(j) = 0;
				active(j) = 0;
			end
		end
	end
	
% 	[~,ind] = convexHull(luz);
% 	evolve(ind) = 0;
	
	% Intersecion con el Convex Hull
	for i=1:N
		p = intersectLinePolygon(normals(i,:).*[1 1 kappa(i) kappa(i)], luz_orig(cHullInd,:));
		xMin = min([normals(i,1) normals(i,1)+normals(i,3)*kappa(i)]);
		xMax = max([normals(i,1) normals(i,1)+normals(i,3)*kappa(i)]);
		yMin = min([normals(i,2) normals(i,2)+normals(i,4)*kappa(i)]);
		yMax = max([normals(i,2) normals(i,2)+normals(i,4)*kappa(i)]);
		for j=1:size(p,1)
			if p(j,1)>xMin && p(j,1)<xMax && p(j,2)>yMin && p(j,2)<yMax
				luz(i,:)  = p(j,:);
				evolve(i) = 0;
			end
		end
	end
	
	
	if opt.visualize
		figure(figNum)
		hold off
		imshow(im); hold on;
		axis(ax)
		plot(luz(logical(active),1),luz(logical(active),2), 'color', colors{1})
		for i=1:N
			plot(luz(i,1),luz(i,2),'*','color',colors{evolve(i)+3})
			line([normals(i,1) normals(i,1)+normals(i,3)],[normals(i,2) normals(i,2)+normals(i,4)], 'color', 'r');
		end
 		pause(0.1)
		drawnow
	end
	cont = cont+1;
	
end

if opt.plot
	figure(figNum)
	plot(luz_orig(:,1),luz_orig(:,2),'y*')
	for i=1:N
		line([luz_orig(i,1) luz(ends(i),1)], [luz_orig(i,2) luz(ends(i),2)])
	end
	
	figure(figNum+1)
	imshow(im); hold on;
	axis(ax)
	plot(luz(logical(active),1),luz(logical(active),2),'*-', 'color',colors{1})
	plot(luz_orig(:,1),luz_orig(:,2),'*-', 'color','y')
	for i=1:N
		line([luz_orig(i,1) luz(ends(i),1)], [luz_orig(i,2) luz(ends(i),2)])
	end
end

% keyboard
end

function d = distancia(luz)
if size(luz,1)<size(luz,2)
	luz = luz';
end
N = size(luz,1);
d = [luz(1,1)-luz(N,1);diff(luz(:,1))].^2+[luz(1,2)-luz(N,2);diff(luz(:,2))].^2;
end

% % Intentos de calculo de curvatura
% 	kappa = curvature(0,luz(:,1),luz(:,2),'polynom',10);
% 	kappa = (xprime.*ysec - xsec.*yprime)./ ...
%         power(xprime.*xprime + yprime.*yprime, 3/2);	
% 	x= luz(:,1)'; y= luz(:,2)';
% % 	x1 = x(1:end-2); x2 = x(2:end-1); x3 = x(3:end);
% 	x1 = circshift(x,[0 1]); x2 = x; x3 = circshift(x,[0 -1]);
% % 	y1 = y(1:end-2); y2 = y(2:end-1); y3 = y(3:end);
% 	y1 = circshift(y,[0 1]); y2 = y; y3 = circshift(y,[0 -1]);
% 	a = sqrt((x3-x2).^2+(y3-y2).^2); % a, b, and c are the three sides
% 	b = sqrt((x1-x3).^2+(y1-y3).^2);
% 	c = sqrt((x2-x1).^2+(y2-y1).^2);
% 	A = 1/2*(x1.*y2+x2.*y3+x3.*y1-x1.*y3-x2.*y1-x3.*y2); % The triangle's area
% 	kappa = [0,4*A./(a.*b.*c),0]; % The reciprocal of its circumscribed radius
