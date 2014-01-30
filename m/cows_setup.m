function cows_setup(varargin)
% -------------------------------------------------------------------------
% function cows_setup(varargin)
% -------------------------------------------------------------------------
% Usage:
% 	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'lema', 'overwrite', 0);
%	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'cerros1', 'overwrite', 0);
%	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'cerros2', 'overwrite', 0);
% -------------------------------------------------------------------------

opt.overwrite = 0;
opt.data_dir  = '';
opt.data_set  = '';
opt.getWidth  = 1;

opt = parse_pv_pairs(opt, varargin);

if strcmp(opt.data_dir, '')
	fprintf('You must parse a valid data dir, for example:\n\tcows_setup(''data_dir'', ''/home/mat/matitai/facultad/ultravacas/data'', ''data_set'', ''lema'')\n');
	return;
end

database_filename='./cows_cfg.mat';
if exist(database_filename, 'file')
	fprintf('Using existing database\n');
else
	fprintf('Creating new database\n');
	patients=[];
	save(database_filename,'patients');
end

dirinfo = dir([[opt.data_dir '/' opt.data_set], '/*.png']);
total_pics = size(dirinfo,1);
pics_ids = zeros(total_pics, 1);
for i=1:total_pics
	tmp_id = sscanf(dirinfo(i).name, '%*c%*d%*c%*d%*c%*d%*c%d*');
	if ~isempty(tmp_id)
		pics_ids(i) = tmp_id;
	else
		pics_ids(i) = 0000;
	end
		
end

cows_ids = unique(pics_ids);
if length(cows_ids)>1
	n_pics = hist(pics_ids, cows_ids)';
else
	n_pics = sum(find(cows_ids==cows_ids(1)));
end

n_patients = size(cows_ids, 1);

for k=1:n_patients
	fprintf('patient: %d\n',k);
	patient.n_pics = n_pics(k);
	patient.id = cows_ids(k);
	patient.tambo = opt.data_set;
	patient.ids = [];
	patient.selected_pics = {};
	patient.control_points = {};
	patient.n_curves = [];
	patient.path = [];
	patient.mioWidth = {};
	patient.endoWidth = {};
	
	segmented_info = dir([[opt.data_dir '/' opt.data_set], ['/*' num2str(patient.id) '*.mat']]);
	for j=1:size(segmented_info,1) % for sobre las imagenes segmentadas
		fprintf('\timagen: %d\n',j);
		patient_info = dir([[opt.data_dir '/' opt.data_set], ['/*' num2str(patient.id) '*.png']]);
		ind = 0;
		for i=1:size(patient_info, 1)
			if strcmp(patient_info(i).name, segmented_info(j).name(1:end-6));
				ind = i;
			end
		end
		if ind
			patient.ids = [patient.ids ind];
			patient.selected_pics{j} = patient_info(ind).name;
		end
	end
	patient.ids = unique(patient.ids);
	patient.selected_pics = unique(patient.selected_pics);
	
	patient = addUserData2Database(patient, opt);
	patient.path = opt.data_dir;
	
	% calculo de los anchos
	for i=1:length(patient.ids)
			if ((opt.getWidth) && (patient.n_curves(i) >= 3))
			[mioWidth, endoWidth] = cows_getCurvesWidth2(patient, i);
			patient.mioWidth{i} = mioWidth;
			patient.endoWidth{i} = endoWidth;
% 			keyboard
		end
	end
	cows_add_patient(patient, opt.overwrite);
end


function patient = addUserData2Database(patient, opt)

CHANGE_CURVES_ORDER = 0;

for i = 1:length(patient.selected_pics)
	logs = dir([[opt.data_dir '/' opt.data_set], ['/' patient.selected_pics{i} '*.mat']]);
	aux.n_curves = 0;
	aux.control_points = {};
	for j = 1:size(logs,1)
		data = load([opt.data_dir '/' opt.data_set '/' logs(j).name]);
		if (~isempty(data.control_points) && data.n_curves )
			if iscell(data.control_points)
				for k=1:data.n_curves
					aux.n_curves = aux.n_curves + 1;
					aux.control_points(aux.n_curves) = {data.control_points{k}};
				end		
			else
				aux.n_curves = aux.n_curves + 1;
				aux.control_points(aux.n_curves) = {data.control_points};
			end
		end
		
		
		if CHANGE_CURVES_ORDER
			aux
			if length(aux.control_points)>=3
				[xs,ys] = cows_closed_spline(...
					aux.control_points{3}(:,1)',...
					aux.control_points{3}(:,2)');
				c3 = [xs' ys'];
			end
			if length(aux.control_points)>=2
				[xs,ys] = cows_closed_spline(...
					aux.control_points{2}(:,1)',...
					aux.control_points{2}(:,2)');
				c2 = [xs' ys'];
			end
			if length(aux.control_points)>=1
				[xs,ys] = cows_closed_spline(...
					aux.control_points{1}(:,1)',...
					aux.control_points{1}(:,2)');
				c1   = [xs' ys'];
			end
			
			im = imread([opt.data_dir '/' opt.data_set '/' patient.selected_pics{i}]);
			
			figure(23); clf; imshow(im); hold on;
			if length(aux.control_points)>=1
				plot(c1(:,1),c1(:,2),'.-','color','y')
				text(min(c1(:,1)),min(c1(:,2)),'\fontsize{16}1','color','y');
			end
			if length(aux.control_points)>=2
				plot(c2(:,1),c2(:,2),'.-','color','y')
				text(min(c2(:,1)),min(c2(:,2)),'\fontsize{16}2','color','y');
			end
			if length(aux.control_points)>=3
				plot(c3(:,1),c3(:,2),'.-','color','y')
				text(min(c3(:,1)),min(c3(:,2)),'\fontsize{16}3','color','y');
			end
			
			keyboard
			
			if 0
				luz    = data.control_points{4};
				tunica = data.control_points{2};
				wall   = data.control_points{1};
				
				data.control_points = {};
				data.control_points{1} = wall;
				data.control_points{2} = tunica;
				data.control_points{3} = luz;
				data.n_curves = 3;
				
				logg_name = [opt.data_dir '/' opt.data_set '/' logs(j).name];
				save(logg_name,'-struct','data')
				disp(['Re-written file: ' logg_name]);
			end
			
		end
		
		
	end
	patient.control_points{i} = aux.control_points;
	patient.n_curves(i) = aux.n_curves;
end
