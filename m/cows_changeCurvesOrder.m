close all
clear all
home

load('cows_cfg');

patient = patients(23);
nImg    = 2;

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{3}(:,1)',...
	patient.control_points{nImg}{3}(:,2)');
c3 = [xs' ys'];

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{2}(:,1)',...
	patient.control_points{nImg}{2}(:,2)');
c2 = [xs' ys'];

[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{1}(:,1)',...
	patient.control_points{nImg}{1}(:,2)');
c1   = [xs' ys'];

im = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);

figure; imshow(im); hold on;
plot(c1(:,1),c1(:,2),'.-','color','y')
text(min(c1(:,1)),min(c1(:,2)),'\fontsize{16}1','color','y');
plot(c2(:,1),c2(:,2),'.-','color','y')
text(min(c2(:,1)),min(c2(:,2)),'\fontsize{16}2','color','y');
plot(c3(:,1),c3(:,2),'.-','color','y')
text(min(c3(:,1)),min(c3(:,2)),'\fontsize{16}3','color','y');

% break

%% Intercambiar orden de curvas
% keyboard
luz    = patient.control_points{nImg}{1};
tunica = patient.control_points{nImg}{2};
wall   = patient.control_points{nImg}{3};

patient.control_points{nImg}{1} = wall;
patient.control_points{nImg}{2} = tunica;
patient.control_points{nImg}{3} = luz;

%%
% keyboard
cows_add_patient(patient, 1)