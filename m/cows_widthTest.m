close all
clear all
home

%% EVOLUCION

opt.log			 = 1;
opt.figNum		 = 15;
opt.plot	     = 1;
opt.visualize    = 0;
opt.fusion_type  = 2;
evolveToInterior = 1;
colors		     = cows_colors();
logPath			 = 'test.evolution';

if opt.log && exist(logPath, 'file')
	logPathBackup = sprintf([logPath '_backup_%4d_%02d_%02d_%02d_%02d_%02d'],fix(clock));
	cmd = ['cp -f ' logPath ' ' logPathBackup];
	fprintf('Saving backup: %s ...\n',logPathBackup);
	fprintf('cmd: %s\n', cmd);
	system(cmd);
	cmd = ['rm ' logPath];
	system(cmd);
end

nIm = 400;
im  = zeros(nIm,nIm);

rLuz    = nIm*.1;
rTunica = nIm*.2;
rWall   = nIm*.4;

nPts    = 30;
theta   = 0:pi/nPts:2*pi-pi/nPts;
xLuz    = nIm/2+rLuz*sin(theta);
yLuz    = nIm/2+rLuz*cos(theta);
xTunica = nIm/2+rTunica*sin(theta);
yTunica = nIm/2+rTunica*cos(theta);
xWall   = nIm/2+rWall*sin(theta);
yWall   = nIm/2+rWall*cos(theta);

luz     = [xLuz' yLuz'];
tunica  = [xTunica' yTunica'];
wall    = [xWall' yWall'];
N	    = size(luz,1);

% Agregado de chichon
f = @(x, mu, sigma) 1/sqrt(2*pi)/sigma*exp(-(x-mu).^2/2/sigma^2);
x = -5:10/nPts:5;
y = f(x, 0, 1); y = y/max(y);
y = y*nIm*.05;
tunicaPrev = tunica;
for i=1:length(y)
	left = i-1; if left==0, left = N; end
	right = i+1;if right>N, right = 1; end	
	n = [-(tunicaPrev(right,2)-tunicaPrev(left,2)), tunicaPrev(right,1)-tunicaPrev(left,1)];
	n = n/norm(n);
	tunica(i,:) = tunica(i,:)+y(i)*n;
end

opt.ax = [min(luz(:,1))-1 max(luz(:,1))+1 min(luz(:,2))-1 max(luz(:,2))+1];

% Curve must be in CCW
luz = cows_curve2CCW(luz);

% Convex Hull as Target Curve
[~,cHullInd] = convexHull(luz);
cHullInd     = unique(sort(cHullInd));

% Reparameterize Target Curve
x=[];
y=[];
if opt.plot >= 2
	figure(opt.figNum+1);
	plot(luz(:,1),luz(:,2),'-*k', 'markersize',15);
	hold on;
end
for k=1:size(cHullInd,1)
	i = cHullInd(k);
	if k~=size(cHullInd,1)
		j = cHullInd(k+1);
		paso = (luz(j,1)-luz(i,1))/(j-i);
	else
		j = cHullInd(1);
		paso = (luz(j,1)-luz(i,1))/(size(luz,1)+j-i);
	end
	pts = luz(i,1)+paso:paso:luz(j,1)+sign(paso)*eps;
	if isempty(pts)
		keyboard
	end
	f = @(x)(luz(j,2)-luz(i,2))/(luz(j,1)-luz(i,1))*(x-luz(i,1)) + luz(i,2);
	x = [x pts];
	y = [y f(pts)];
	if opt.plot >= 2
		figure(opt.figNum+1);
		plot(pts,f(pts),'*','color',colors{mod(i,size(colors,2))+1}, 'markersize',10)
	end
end
cHull = [x' y'];
cHull = circshift(cHull,cHullInd(1));

if opt.plot >= 2
	figure(opt.figNum+1);
	for i=1:size(luz,1)
		text(cHull(i,1),cHull(i,2),num2str(i),'color','r')
		text(cHull(i,1),cHull(i,2),num2str(i),'color','k')
		line([luz(i,1) cHull(i,1)],[luz(i,2) cHull(i,2)]);
	end
end

%% Evolution
% Evolution from cHull to luz
disp('Evolution from cHull to luz');
% Marcar los segmentos a evolucionar
evolve = ones(N,1); evolve(cHullInd) = 0;
tic
[evolvedLuz, activeLuz, endsLuz, labels1, d1, N1] = cows_evolveCurveToTarget(im, cHull, luz, evolve, evolveToInterior, opt, logPath, 0); sprintf('\n');
toc
if (length(labels1)~=N)
	% Se crean puntos en la evolucion del cHull hacia la luz. Esas
	% distancias no se usan despues. OJO. Solamente se guardan las
	% distancias correspondientes a los puntos con labels <= N. Los puntos
	% creados en la evolucion del cHull hasta la luz (que tienen labels >N)
	% no se consideran para el ancho. Es complicado considerarlos porque
	% hay que guardar los padres que lo crean y luego sumar la distancia
	% de la evolucion de esos padres desde el cHull hasta la tunica.
	disp('ERROR EN EL LARGO DE LABELS1 - COWS_GETCURVESWIDTH2');
end
maxInd = max(labels1);
dIni = zeros(N,1);
ind = 1;
for i=1:maxInd
	if labels1(i) <= N
		dIni(ind) = d1(labels1(i));
		ind = ind+1;
	end
end
dIni = flipud(dIni);

% Evolution from cHull to tunica
disp('Evolution from cHull to tunica')
tunica = cows_curve2CCW(tunica);
opt.ax = [min(tunica(:,1))-1 max(tunica(:,1))+1 min(tunica(:,2))-1 max(tunica(:,2))+1];
tic
[evolvedTunica, activeTunica, endsTunica, labels2, d2] = cows_evolveCurveToTarget(im, cHull, tunica, ones(N,1), ~evolveToInterior, opt, logPath, dIni, (N:-1:1)', maxInd); sprintf('\n');
toc
maxInd = max(labels2);

% Evolution from tunica to wall
disp('Evolution from tunica to wall');
wall   = cows_curve2CCW(wall);
opt.ax = [min(wall(:,1))-1 max(wall(:,1))+1 min(wall(:,2))-1 max(wall(:,2))+1];
tic
[evolvedWall, activeWall, endsWall, labels3, d3] = cows_evolveCurveToTarget(im, evolvedTunica, wall, ones(size(evolvedTunica,1),1), ~evolveToInterior, opt, logPath, 0, labels2, maxInd); sprintf('\n');
toc
maxInd = max(labels3);

% Save data
data2save.data		 = dlmread(logPath);
data2save.iterations = [N N1];
fprintf('Saving evolution data in %s\n',[logPath '.mat']);
save([logPath '.mat'],'-struct','data2save');

%% Anchos
mioWidth  = d3(logical(activeWall));
endoWidth = d2(logical(activeTunica));

%% Load saved evolution
loadedData    = load([logPath '.mat']);
data		  = loadedData.data;
[Ndata,Mdata] = size(data);
N			  = loadedData.iterations(1);
N1			  = loadedData.iterations(2);

data_final    = zeros(2,Ndata/3,10);
for i=1:Ndata/3;
	labs = data(3*i-2,:);
	pts  = data(3*i-1:3*i,:);
	for j=1:Mdata
		if labs(j)
			data_final(:,i,labs(j))=pts(:,j);
		end
	end
end
data_final(data_final==0)=NaN;
maxInd = size(data_final,3);

c1 = wall;
c2 = tunica;
c3 = luz;
ax = [min(c1(:,1))-1 max(c1(:,1))+1 min(c1(:,2))-1 max(c1(:,2))+1];

%% Plot results
if opt.plot >= 1
	figure(opt.figNum+3);
		imshow(ones(size(im)))
		axis(ax)
		hold on
		plot(c1(:,1),c1(:,2),'.-', 'color','k')
		plot(c2(:,1),c2(:,2),'.-', 'color','k')
		plot(c3(:,1),c3(:,2),'.-', 'color','k')
		for i=1:N
			plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{5})
			plot(data_final(1,N1+1:end,i),data_final(2,N1+1:end,i),'color',colors{5})
		end
		for i=N+1:maxInd
			plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{1})
			plot(data_final(1,N1+1:end,i),data_final(2,N1+1:end,i),'color',colors{1})
		end
% 		plot(data_final(1,1,1),data_final(2,1,1),'*b')
% 		plot(data_final(1,1,2),data_final(2,1,2),'*r')
		title('\fontsize{16}Evolucion')
		fill([80 80 105 105]-1,[80 102+8 102+8 80]-15,'w')
		text(80,80,'\fontsize{40}\Gamma_1')
		fill([140 140 166 166]-1,[140 162+8 162+8 140]-15,'w')
		text(140,140,'\fontsize{40}\Gamma_2')
		fill([170 170 196 196]-1,[170 192+8 192+8 170]-15,'w')
		text(170,170,'\fontsize{40}\Gamma_3')
		fill([148 148 258 258]-1,[252 272+8 272+8 252]-15,'w')
		text(148,252,'\fontsize{30}Endometrium')
		fill([148 148 258 258]-1,[252 272+8 272+8 252]-15+58,'w')
		text(152,310,'\fontsize{30}Myometrium')
		
	figure(opt.figNum+4);
		hold off
		plot(1/size(mioWidth,1):1/size(mioWidth,1):1,mioWidth,'.-','linewidth',2,'color',colors{1},'markersize',10)
		hold on; grid on;
		plot(1/size(endoWidth,1):1/size(endoWidth,1):1,endoWidth,'.-','linewidth',2,'color',colors{5},'markersize',10)
		title('\fontsize{16}Anchos')
		legend('\fontsize{16}Miometrio', '\fontsize{16}Endometrio')
	figure(opt.figNum+5);
		hold off
		plot(mioWidth,'.-','linewidth',2,'color',colors{1},'markersize',10)
		hold on; grid on;
		plot(endoWidth,'.-','linewidth',2,'color',colors{5},'markersize',10)
		title('\fontsize{16}Anchos')
		legend('\fontsize{16}Miometrio', '\fontsize{16}Endometrio')
	figure
		ang = zeros(size(evolvedTunica,1),1);
		ang2 = zeros(size(evolvedWall,1),1);
		for i=1:size(evolvedTunica,1)
			ang(i)=atan2(evolvedTunica(i,2)-nIm/2, evolvedTunica(i,1)-nIm/2);
		end
		for i=1:size(evolvedWall,1)
			ang2(i)=atan2(evolvedWall(i,2)-nIm/2, evolvedWall(i,1)-nIm/2);
		end
		[~,ind2]=min(ang2);
		plot(circshift(ang2,-ind2+1),circshift(mioWidth,-ind2+1),'.-','linewidth',2.2,'color',colors{5},'markersize',10)
		hold on, grid on
		[~,ind]=min(ang);
		plot(circshift(ang,-ind+1),circshift(endoWidth,-ind+1),'.-','linewidth',2.2,'color',colors{1},'markersize',10)
		legend('\fontsize{16}Myometrium', '\fontsize{16}Endometrium','location','east')
		axis([-pi pi 35 85])
		xlabel('\fontsize{16}Phase [Rad]')
		ylabel('\fontsize{16}Thickness')
end

%% COMPARACION
break
%% --------- Algoritmo de evolucion ---------
load('cows_cfg');
patient = patients(end);
nImg = 1;

logPath	      = [patient.selected_pics{nImg}(1:end-3) 'evolution'];
im			  = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);

if exist([logPath '.mat'],'file')
	loadedData = load([logPath '.mat']);
else
	fprintf('\nError\n\tNo se puede encontrar el archivo\n');
	return
end

data		  = loadedData.data;
[Ndata,Mdata] = size(data);
N			  = loadedData.iterations(1);
N1			  = loadedData.iterations(2);
N2			  = 439;

data_final    = zeros(2,Ndata/3,10);
for i=1:Ndata/3;
	labs = data(3*i-2,:);
	pts  = data(3*i-1:3*i,:);
	for j=1:Mdata
		if labs(j)
			data_final(:,i,labs(j))=pts(:,j);
		end
	end
end
data_final(data_final==0)=NaN;
maxInd = size(data_final,3);

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{1}(:,1)',...
	patient.control_points{nImg}{1}(:,2)');
c1   = [xs' ys'];

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{2}(:,1)',...
	patient.control_points{nImg}{2}(:,2)');
c2 = [xs' ys'];

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{3}(:,1)',...
	patient.control_points{nImg}{3}(:,2)');
c3 = [xs' ys'];

ax = [min(c2(:,1))-1 max(c2(:,1))+1 min(c2(:,2))-1 max(c2(:,2))+1];

figure;
imshow(ones(size(im)));
axis(ax)
hold on
plot(c2(:,1),c2(:,2),'.-', 'color','k')
plot(c3(:,1),c3(:,2),'.-', 'color','k')
for i=1:N
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{5})
	plot(data_final(1,N1+1:N2,i),data_final(2,N1+1:N2,i),'color',colors{5})
end
for i=N+1:maxInd
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{1})
	plot(data_final(1,N1+1:N2,i),data_final(2,N1+1:N2,i),'color',colors{1})
end

% saco algunos puntos para que el muestreo quede mas lindo
for i=1:2:45
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color','w')
	plot(data_final(1,N1+1:N2,i),data_final(2,N1+1:N2,i),'color','w')
end
for i=150:-2:136
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color','w')
	plot(data_final(1,N1+1:N2,i),data_final(2,N1+1:N2,i),'color','w')
end


%% --------- Algoritmo de ---------

[N,M,~] = size(im);
plot_step = 1;

mask3 = roipoly(im,c3(:,1),c3(:,2));
B3 = bwboundaries(mask3); B3 = B3{1};
C3 = regionprops(mask3,'Centroid'); C3 = C3.Centroid;
[D3, IDX3] = bwdist(mask3);

mask2 = roipoly(im,c2(:,1),c2(:,2));
B2 = bwboundaries(mask2); B2 = B2{1};
C2 = regionprops(mask2,'Centroid'); C2 = C2.Centroid;
[D2, IDX2] = bwdist(mask2);

mask1 = roipoly(im,c1(:,1),c1(:,2));
B1 = bwboundaries(mask1); B1 = B1{1};
C1 = regionprops(mask1,'Centroid'); C1 = C1.Centroid;
[D1, IDX1] = bwdist(mask1);

contourImage1 = zeros(N,M);
contourImage1(B1(:,1)+N*(B1(:,2)-1))=1;
contourImage2 = zeros(N,M);
contourImage2(B2(:,1)+N*(B2(:,2)-1))=1;
contourImage3 = zeros(N,M);
contourImage3(B3(:,1)+N*(B3(:,2)-1))=1;

level0_mio = contourc(double(bwdist(contourImage1)-bwdist(contourImage2)),[0 0]);
[~,aux]=find(level0_mio==0);
level0_mio(:,aux) = [];

level0_endo = contourc(double(bwdist(contourImage2)-bwdist(contourImage3)),[0 0]);
[~,aux]=find(level0_endo==0);
level0_endo(:,aux) = [];

figure(50); % funcion distancia
	imshow(ones(size(im)));
	axis(ax)
	hold on	
	for i=1:plot_step:size(B1,1)
		long_ind = IDX2(B1(i,1),B1(i,2));
		aux = double(long_ind)/N;
		if aux == fix(aux)
			ind = [long_ind-(aux-1)*N fix(long_ind/N)];
		else
			ind = [long_ind-fix(aux)*N fix(long_ind/N)];
		end
% 		line([B1(i,2) ind(2)],[B1(i,1) ind(1)], 'color', 'b')	
		long_ind = IDX3(ind(1),ind(2));
		aux = double(long_ind)/N;
		if aux == fix(aux)
			ind_luz = [long_ind-(aux-1)*N fix(long_ind/N)];
		else
			ind_luz = [long_ind-fix(aux)*N fix(long_ind/N)];
		end
		line([ind(2) ind_luz(2)],[ind(1) ind_luz(1)], 'color', colors{5})
	end
	plot(c2(:,1),c2(:,2),'.-', 'color','k')
	plot(c3(:,1),c3(:,2),'.-', 'color','k')

figure(51); % centroide
	imshow(ones(size(im)));
	axis(ax)
	hold on
	plot(c2(:,1),c2(:,2),'.-', 'color','k')
	plot(c3(:,1),c3(:,2),'.-', 'color','k')
	for i=1:plot_step:size(B1,1)
		long_ind = IDX2(B1(i,1),B1(i,2));
		aux = double(long_ind)/N;
		if aux == fix(aux)
			ind = [long_ind-(aux-1)*N fix(long_ind/N)];
		else
			ind = [long_ind-fix(aux)*N fix(long_ind/N)];
		end
		linea = [fliplr(double(ind)) (C3)-fliplr(double(ind))];
		p = intersectLinePolygon(linea, c3);
		[~,index]=min((p(:,1)-double(ind(2))).^2+(p(:,2)-double(ind(1))).^2);
		% 		line([B1(i,2) ind(2)],[B1(i,1) ind(1)], 'color', 'b')
		line([ind(2) p(index,1)],[ind(1) p(index,2)], 'color',colors{5})
	end
	%%
figure(52);
	imshow(ones(size(im)));
	axis(ax)
	hold on
	plot(c2(:,1),c2(:,2),'.-', 'color','k')
	plot(c3(:,1),c3(:,2),'.-', 'color','k')
	
	dxlevel0_mio = gradient(level0_mio(1,:));
	dylevel0_mio = gradient(level0_mio(2,:));
	
	dxlevel0_endo = gradient(level0_endo(1,:));
	dylevel0_endo = gradient(level0_endo(2,:));
	
	for i=1:2*plot_step:size(level0_endo,2)
		l = [ level0_endo(1,i)+50*dylevel0_endo(i)*[-1 1] ; level0_endo(2,i)-50*dxlevel0_endo(i)*[-1 1] ];
		[a,b]=polyxpoly(c2(:,1),c2(:,2),l(1,:),l(2,:));
		[~,aux] = min( (a-level0_endo(1,i)).^2 + (b-level0_endo(2,i)).^2 );
		a = a(aux); b = b(aux);
		[c,d]=polyxpoly(c3(:,1),c3(:,2),l(1,:),l(2,:));
		[~,aux] = min( (c-level0_endo(1,i)).^2 + (d-level0_endo(2,i)).^2 );
		c = c(aux); d = d(aux);
		plot([a c], [b d], 'color', colors{5})
		if isempty(a) | isempty(c)
			p = intersectLinePolygon([l(1,1) l(2,1) l(1,2)-l(1,1) l(2,2)-l(2,1)],c2);
% 			line([p(1,1) l(1,1)],[p(1,2) l(2,1)], 'color', colors{1})
			line([p(1,1) p(2,1)],[p(1,2) p(2,2)], 'color', colors{1})
		end
	end
	
	plot(level0_endo(1,:),level0_endo(2,:),'.-','color',colors{3})