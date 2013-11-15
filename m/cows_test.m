function [miomNorm, endoNorm] = cows_test()

close all;
clear all;
home;
colors = cows_colors();

plotear = 2;
plot_step = 2;

load('cows_cfg');
patient = patients(2);
if plotear>=2
	cows_showPatientImages(patient);
end

%% Calculo del area

area = {};
for i=1:length(patient.selected_pics)
	for j=1:length(patient.control_points{i})
		[xs, ys] = cows_closed_spline(patient.control_points{i}{j}(:,1)',...
			patient.control_points{i}{j}(:,2)');
		area{i}{j} = polyarea(xs,ys);
	end
	patient.area(i).endo = area{i}{1}-area{i}{2};
	if size(area{i},2) >= 3;
		patient.area(i).mio = area{i}{2} - area{i}{3};
	else
		patient.area(i).mio = area{i}{2};
	end
end

%% distancia entre curvas

nImg = 2;

% --ancho endometrio
im = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);
[N,M,~] = size(im);

nCurve = 3;
[xs3, ys3, mask3] = cows_getPatientImageFeatures(patient, nImg, nCurve);

cHull = regionprops(mask3,'ConvexHull'); cHull = cHull.ConvexHull;
mask3 = roipoly(im,cHull(:,1),cHull(:,2));

B3 = bwboundaries(mask3); B3 = B3{1};
C3 = regionprops(mask3,'Centroid'); C3 = C3.Centroid;
[D3, IDX3] = bwdist(mask3);

nCurve = 2;
[xs2, ys2, mask2] = cows_getPatientImageFeatures(patient, nImg, nCurve);
B2 = bwboundaries(mask2); B2 = B2{1};
C2 = regionprops(mask2,'Centroid'); C2 = C2.Centroid;
[D2, IDX2] = bwdist(mask2);

nCurve = 1;
[xs1, ys1, mask1] = cows_getPatientImageFeatures(patient, nImg, nCurve);
B1 = bwboundaries(mask1); B1 = B1{1};
C1 = regionprops(mask1,'Centroid'); C1 = C1.Centroid;
[D1, IDX1] = bwdist(mask1);

endo = D3(B2(:,1)+N*(B2(:,2)-1));
miom = D2(B1(:,1)+N*(B1(:,2)-1));

miomNorm = interp1(1:length(miom), miom, 1:length(miom)/100:length(miom));
endoNorm = interp1(1:length(endo), endo, 1:length(endo)/100:length(endo));

%% curvas promedio

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

%% --plots

if plotear >= 3
	% para ver donde empieza a calcular los anchos
	figure;
	imshow(im);hold on;
	plot(B1(:,2),B1(:,1), 'y');plot(B2(:,2),B2(:,1), 'y');
	
	text(B1(1,2),B1(1,1) ,'\fontsize{14}1','color','r');  text(B2(1,2),B2(1,1)  ,'\fontsize{14}1','color','r');
	text(B1(3,2),B1(5,1) ,'\fontsize{14}2','color','r');  text(B2(5,2),B2(5,1)  ,'\fontsize{14}2','color','r');
	text(B1(10,2),B1(10,1),'\fontsize{14}3','color','r'); text(B2(10,2),B2(10,1),'\fontsize{14}3','color','r');
	
	text(xs1(1) , ys1(1) ,'\fontsize{14}1','color','g');  text(xs2(1), ys2(1)  ,'\fontsize{14}1','color','g');
	text(xs1(5) , ys1(5) ,'\fontsize{14}2','color','g');  text(xs2(5), ys2(5)  ,'\fontsize{14}2','color','g');
	text(xs1(10), ys1(10),'\fontsize{14}3','color','g');  text(xs2(10), ys2(10),'\fontsize{14}3','color','g');
end

if plotear >= 2
	figure(50);
	imshow(im);
	hold on
	plot(B3(:,2),B3(:,1), 'r')
	plot(C3(1),C3(2), 'r+')
	plot(B2(:,2),B2(:,1), 'g')
	plot(C2(1),C2(2), 'g+')
	plot(B1(:,2),B1(:,1), 'y')
	plot(C1(1),C1(2), 'y+')
	
	for i=1:plot_step:size(B1,1)
		long_ind = IDX2(B1(i,1),B1(i,2));
		ind = [long_ind-fix(long_ind/N)*N fix(long_ind/N)];
		line([B1(i,2) ind(2)],[B1(i,1) ind(1)], 'color', colors{1})
		
		long_ind = IDX3(ind(1),ind(2));
		ind_luz = [long_ind-fix(long_ind/N)*N fix(long_ind/N)];
		line([ind(2) ind_luz(2)],[ind(1) ind_luz(1)], 'color', colors{1})
	end
	
	figure(51);
	imshow(im);
	hold on
	for i=1:plot_step:size(B1,1)
		long_ind = IDX2(B1(i,1),B1(i,2));
		ind = [long_ind-fix(long_ind/N)*N fix(long_ind/N)];
		line([B1(i,2) ind(2)],[B1(i,1) ind(1)], 'color', colors{1})
		
		% 		keyboard
		% 		l = [ind(1) ind(2);C3(1) C3(2)];
		% 		l = [[ind(2); C3(1)] [ind(1); C3(2)]];
		% 		[a,b]=polyxpoly(xs1,ys1,l(:,1),l(:,2));
		% 		[~,aux] = min( (a-C3(1)).^2 + (b-C3(2)).^2 );
		% 		a = a(aux); b = b(aux);
		% 		[c,d]=polyxpoly(xs2,ys2,l(1,:),l(2,:));
		% 		[~,aux] = min( (c-C3(1)).^2 + (d-C3(2)).^2 );
		% 		c = c(aux); d = d(aux);
		% 		plot([a c], [b d], 'color', 'y')
		
		line([ind(2) C3(1)],[ind(1) C3(2)], 'color', colors{1})
	end
	plot(B3(:,2),B3(:,1), 'r', 'linewidth',2)
	plot(C3(1),C3(2), 'r+')
	plot(B2(:,2),B2(:,1), 'g')
	plot(C2(1),C2(2), 'g+')
	plot(B1(:,2),B1(:,1), 'y')
	plot(C1(1),C1(2), 'y+')
	
	figure(52);
	imshow(im);
	hold on
	plot(xs1,ys1,'r.-')
	plot(xs2,ys2,'r.-')
	plot(xs3,ys3,'r.-')
	plot(level0_mio(1,:),level0_mio(2,:),'y.')
	plot(level0_endo(1,:),level0_endo(2,:),'y.')
	
	dxlevel0_mio = gradient(level0_mio(1,:));
	dylevel0_mio = gradient(level0_mio(2,:));
	
	dxlevel0_endo = gradient(level0_endo(1,:));
	dylevel0_endo = gradient(level0_endo(2,:));
	
	for i=1:plot_step:size(level0_mio,2)
		l = [ level0_mio(1,i)+50*dylevel0_mio(i)*[-1 1] ; level0_mio(2,i)-50*dxlevel0_mio(i)*[-1 1] ];
		[a,b]=polyxpoly(xs1,ys1,l(1,:),l(2,:));
		[~,aux] = min( (a-level0_mio(1,i)).^2 + (b-level0_mio(2,i)).^2 );
		a = a(aux); b = b(aux);
		[c,d]=polyxpoly(xs2,ys2,l(1,:),l(2,:));
		[~,aux] = min( (c-level0_mio(1,i)).^2 + (d-level0_mio(2,i)).^2 );
		c = c(aux); d = d(aux);
		plot([a c], [b d], 'color', 'y')
	end
	for i=1:plot_step:size(level0_endo,2)
		l = [ level0_endo(1,i)+50*dylevel0_endo(i)*[-1 1] ; level0_endo(2,i)-50*dxlevel0_endo(i)*[-1 1] ];
		[a,b]=polyxpoly(xs2,ys2,l(1,:),l(2,:));
		[~,aux] = min( (a-level0_endo(1,i)).^2 + (b-level0_endo(2,i)).^2 );
		a = a(aux); b = b(aux);
		[c,d]=polyxpoly(xs3,ys3,l(1,:),l(2,:));
		[~,aux] = min( (c-level0_endo(1,i)).^2 + (d-level0_endo(2,i)).^2 );
		c = c(aux); d = d(aux);
		plot([a c], [b d], 'color', 'y')
		if isempty(a) | isempty(c)
			line(l(1,:),l(2,:), 'color', 'b')
		end
	end
end

if plotear >=1
	figure(100);
	plot(endoNorm, 'color', colors{1}, 'linewidth', 2);
	hold on;
	plot(miomNorm, 'color', colors{7}, 'linewidth', 2); legend('Endometrio', 'Miometrio'); grid
end
keyboard
end

function [xs, ys, mask] = cows_getPatientImageFeatures(patient, nImg, nCurve)
% if size(patient.control_points{nImg},2) < 3 % No hay luz
xCurvePoints = patient.control_points{nImg}{nCurve}(:,1);
yCurvePoints = patient.control_points{nImg}{nCurve}(:,2);
[xs,ys] = cows_closed_spline(xCurvePoints',yCurvePoints');
im = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);
mask    = roipoly(im,xs,ys);
end