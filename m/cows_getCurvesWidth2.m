function [mioWidth, endoWidth] = cows_getCurvesWidth2(patient, nImg)
% -------------------------------------------------------------------------
% function [mioWidth, endoWidth] = cows_getCurvesWidth(patient, nImg)
% -------------------------------------------------------------------------
% load('cows_cfg');
% cows_getCurvesWidth(patients(2),2)
% -------------------------------------------------------------------------

%% Defs
opt.log			 = 1;
opt.figNum		 = 7;
opt.plot	     = 1;
opt.visualize    = 0;
opt.fusion_type  = 2;
evolveToInterior = 1;
colors		     = cows_colors();
im			     = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);
logPath			 = [patient.selected_pics{nImg}(1:end-3) 'evolution'];

if opt.log && exist(logPath, 'file')
	logPathBackup = sprintf([logPath '_backup_%4d_%02d_%02d_%02d_%02d_%02d'],fix(clock));
	cmd = ['cp -f ' logPath ' ' logPathBackup];
	fprintf('Saving backup: %s ...\n',logPathBackup);
	fprintf('cmd: %s\n', cmd);
	system(cmd);
	cmd = ['rm ' logPath];
	system(cmd);
end
	
%% Load curves
nCurve = 3;
[xsLuz,ysLuz] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
luz = [xsLuz' ysLuz'];

startCurve = luz;
N		   = size(startCurve,1);
opt.ax     = [min(startCurve(:,1))-1 max(startCurve(:,1))+1 min(startCurve(:,2))-1 max(startCurve(:,2))+1];

% Curve must be in CCW
startCurve = cows_curve2CCW(startCurve);

% Convex Hull as Target Curve
[~,cHullInd] = convexHull(startCurve);
cHullInd     = unique(sort(cHullInd));

% Reparameterize Target Curve
x=[];
y=[];
if opt.plot >= 2
	figure(opt.figNum+1);
	plot(startCurve(:,1),startCurve(:,2),'-*k', 'markersize',15);
	hold on;
end
for k=1:size(cHullInd,1)
	i = cHullInd(k);
	if k~=size(cHullInd,1)
		j = cHullInd(k+1);
		paso = (startCurve(j,1)-startCurve(i,1))/(j-i);
	else
		j = cHullInd(1);
		paso = (startCurve(j,1)-startCurve(i,1))/(size(startCurve,1)+j-i);
	end
	pts = startCurve(i,1)+paso:paso:startCurve(j,1);
	f = @(x)(startCurve(j,2)-startCurve(i,2))/(startCurve(j,1)-startCurve(i,1))*(x-startCurve(i,1)) + startCurve(i,2);
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
	for i=1:size(startCurve,1)
		text(cHull(i,1),cHull(i,2),num2str(i),'color','r')
		text(cHull(i,1),cHull(i,2),num2str(i),'color','k')
		line([startCurve(i,1) cHull(i,1)],[startCurve(i,2) cHull(i,2)]);
	end
end

% Intercambiar target con start curves
targetCurve = startCurve;

% Marcar los segmentos a evolucionar
evolve = ones(N,1); evolve(cHullInd) = 0;

%% Evolution
% Evolution from cHull to luz
disp('Evolution from cHull to luz');
tic
[evolvedLuz, activeLuz, endsLuz, labels1, d1, N1] = cows_evolveCurveToTarget(im, cHull, targetCurve, evolve, evolveToInterior, opt, logPath, 0); sprintf('\n');
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
nCurve = 2;
[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
tunica = [xs' ys'];
tunica = cows_curve2CCW(tunica);
opt.ax = [min(tunica(:,1))-1 max(tunica(:,1))+1 min(tunica(:,2))-1 max(tunica(:,2))+1];
tic
[evolvedTunica, activeTunica, endsTunica, labels2, d2] = cows_evolveCurveToTarget(im, cHull, tunica, ones(N,1), ~evolveToInterior, opt, logPath, dIni, (N:-1:1)', maxInd); sprintf('\n');
toc
maxInd = max(labels2);

% Evolution from tunica to wall
disp('Evolution from tunica to wall');
nCurve = 1;
[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
wall   = [xs' ys'];
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

ang		  = zeros(size(evolvedTunica,1),1);
ang2	  = zeros(size(evolvedWall,1),1);
cenTunica = centroid(evolvedTunica);
cenWall   = centroid(evolvedWall); % estoy usando el centroide de la tunica para todo. no uso el de wall
for i=1:size(evolvedTunica,1)
	ang(i)=atan2(evolvedTunica(i,2)-cenTunica(2), evolvedTunica(i,1)-cenTunica(1));
end
for i=1:size(evolvedWall,1)
	ang2(i)=atan2(evolvedWall(i,2)-cenTunica(2), evolvedWall(i,1)-cenTunica(1));
end
ang2      = ang2(logical(activeWall));
[~,ind2]  = min(ang2);
ang       = ang(logical(activeTunica));
[~,ind]   = min(ang);

mioWidth  = [circshift(ang2,-ind2+1),circshift(mioWidth,-ind2+1)];
endoWidth = [circshift(ang,-ind+1),circshift(endoWidth,-ind+1)];

%% Plot results
if opt.plot >= 1
	figure(opt.figNum+3);
		cows_showEvolution(patient,nImg);
	
	figure(opt.figNum+4);
		plot(mioWidth(:,1),mioWidth(:,2),'.-','linewidth',2.2,'color',colors{5},'markersize',10)
		hold on, grid on
		plot(endoWidth(:,1),endoWidth(:,2),'.-','linewidth',2.2,'color',colors{1},'markersize',10)
		legend('\fontsize{16}Myometrium', '\fontsize{16}Endometrium','location','southeast')
		axis tight
end

if opt.plot >= 2
	figure(opt.figNum)
	plot(evolvedLuz(:,1),evolvedLuz(:,2),'y*')
	plot(evolvedTunica(:,1),evolvedTunica(:,2),'y*')
	for i=1:N
		if activeLuz(i), line([evolvedLuz(endsLuz(i),1) cHull(i,1)], [evolvedLuz(endsLuz(i),2) cHull(i,2)],'color', colors{1}), end
		if activeTunica(i), line([evolvedTunica(endsTunica(i),1) cHull(i,1)], [evolvedTunica(endsTunica(i),2) cHull(i,2)],'color', colors{1}), end
	end
	
	fig = figure(opt.figNum+2); set(fig, 'Position', [0 0 1000 1000]);
	imshow(im); hold on; axis(opt.ax)
	plot(luz(:,1),luz(:,2),'.-', 'color',colors{2})
	plot(tunica(:,1),tunica(:,2),'.-', 'color',colors{2})
	plot(wall(:,1),wall(:,2),'.-', 'color',colors{2})
	plot(cHull(:,1),cHull(:,2),'.-', 'color',colors{4})
	for i=1:N
		if activeLuz(i), line([evolvedLuz(endsLuz(i),1) cHull(i,1)], [evolvedLuz(endsLuz(i),2) cHull(i,2)],'color', colors{1}), end
		if activeTunica(i), line([evolvedTunica(endsTunica(i),1) cHull(i,1)], [evolvedTunica(endsTunica(i),2) cHull(i,2)],'color', colors{1}), end
		if activeWall(i), line([evolvedWall(endsWall(i),1) evolvedTunica(i,1)], [evolvedWall(endsWall(i),2) evolvedTunica(i,2)],'color', colors{1}), end
	end
end	

end

function d = distancia(startCurve)
if size(startCurve,1)<size(startCurve,2)
	startCurve = startCurve';
end
N = size(startCurve,1);
d = [startCurve(1,1)-startCurve(N,1);diff(startCurve(:,1))].^2+[startCurve(1,2)-startCurve(N,2);diff(startCurve(:,2))].^2;
end
		
% % Intentos de calculo de curvatura
% 	kappa = curvature(0,startCurve(:,1),startCurve(:,2),'polynom',10);
% 	kappa = (xprime.*ysec - xsec.*yprime)./ ...
%         power(xprime.*xprime + yprime.*yprime, 3/2);	
% 	x= startCurve(:,1)'; y= startCurve(:,2)';
% % 	x1 = x(1:end-2); x2 = x(2:end-1); x3 = x(3:end);
% 	x1 = circshift(x,[0 1]); x2 = x; x3 = circshift(x,[0 -1]);
% % 	y1 = y(1:end-2); y2 = y(2:end-1); y3 = y(3:end);
% 	y1 = circshift(y,[0 1]); y2 = y; y3 = circshift(y,[0 -1]);
% 	a = sqrt((x3-x2).^2+(y3-y2).^2); % a, b, and c are the three sides
% 	b = sqrt((x1-x3).^2+(y1-y3).^2);
% 	c = sqrt((x2-x1).^2+(y2-y1).^2);
% 	A = 1/2*(x1.*y2+x2.*y3+x3.*y1-x1.*y3-x2.*y1-x3.*y2); % The triangle's area
% 	kappa = [0,4*A./(a.*b.*c),0]; % The reciprocal of its circumscribed radius
