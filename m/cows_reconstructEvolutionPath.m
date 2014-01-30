save('T01_130520-143702_2011_.evolution.mat','DATA');
data  = load('T01_130520-143702_2011_.evolution.mat'); DATA = DATA.DATA;
[N,M] = size(data);

load('cows_cfg');
patient = patients(1);
nImg    = 1;

im    = imread([patient.path '/' patient.tambo '/' patient.selected_pics{nImg}]);

data_final = zeros(2,N/3,M);
for i=1:N/3;
	labs = data(3*i-2,:);
	pts  = data(3*i-1:3*i,:);
	for j=1:M
		if ~isnan(labs(j))
			data_final(:,i,labs(j))=pts(:,j);
		end
	end
end

data_final(data_final==0)=NaN;

nCurve = 3;
[xsLuz,ysLuz] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
luz = [xsLuz' ysLuz'];

nCurve = 2;
[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
tunica = [xs' ys'];

nCurve = 1;
[xs,ys] = cows_closed_spline(...
	patient.control_points{nImg}{nCurve}(:,1)',...
	patient.control_points{nImg}{nCurve}(:,2)');
wall   = [xs' ys'];

ax = [min(wall(:,1))-1 max(wall(:,1))+1 min(wall(:,2))-1 max(wall(:,2))+1];

figure;
imshow(im)
axis(ax)
hold on
colors = cows_colors();
plot(luz(:,1),luz(:,2),'.-', 'color',colors{2})
plot(tunica(:,1),tunica(:,2),'.-', 'color',colors{2})
plot(wall(:,1),wall(:,2),'.-', 'color',colors{2})
for i=1:maxInd
	plot(data_final(1,:,i),data_final(2,:,i))
% 	drawnow
% 	pause
end
