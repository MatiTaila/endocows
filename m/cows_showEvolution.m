function cows_showEvolution(patient, nImg)

colors		  = cows_colors();
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

% se crea la estructura data_final que tiene toda la informacion de la
% evolucion. En dimension uno estan las coordenadas x e y. En la dimension
% 2 esta el tiempo y en la dimension 3 estan los diferentes puntos.
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

ax = [min(c1(:,1))-1 max(c1(:,1))+1 min(c1(:,2))-1 max(c1(:,2))+1];

clf
hold off
imshow(im)
axis(ax)
hold on
plot(c1(:,1),c1(:,2),'.-', 'color',colors{2})
plot(c2(:,1),c2(:,2),'.-', 'color',colors{2})
plot(c3(:,1),c3(:,2),'.-', 'color',colors{2})
for i=1:N
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{3})
	plot(data_final(1,N1+1:end,i),data_final(2,N1+1:end,i),'color',colors{3})
end
for i=N+1:maxInd
	plot(data_final(1,1:N1,i),data_final(2,1:N1,i),'color',colors{1})
	plot(data_final(1,N1+1:end,i),data_final(2,N1+1:end,i),'color',colors{1})
end
% plot(data_final(1,1,1),data_final(2,1,1),'*b')
% plot(data_final(1,1,2),data_final(2,1,2),'*r')
title('\fontsize{16}Evolucion')