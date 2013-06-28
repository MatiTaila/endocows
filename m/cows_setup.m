function cows_setup(varargin)
% -------------------------------------------------------------------------
% function cows_setup(varargin)
% -------------------------------------------------------------------------
% Usage:
%	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'lema', 'overwrite', 0);
%	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'cerros1', 'overwrite', 0);
%	cows_setup('data_dir', '~/matitai/facultad/ultravacas/data',...
% 			'data_set', 'cerros2', 'overwrite', 0);
% -------------------------------------------------------------------------

opt.overwrite=0;
opt.data_dir='';
opt.data_set='';

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
	pics_ids(i) = sscanf(dirinfo(i).name, '%*c%*d%*c%*d%*c%*d%*c%d*');
end

cows_ids = unique(pics_ids);
n_pics = hist(pics_ids, cows_ids)';

n_patients = size(cows_ids, 1);

for k=1:n_patients
	patient.n_pics = n_pics(k);
	patient.id = cows_ids(k);
	patient.tambo = opt.data_set;
	patient.ids = [];
	patient.selected_pics = {};
	patient.control_points = {};
	patient.n_curves = [];
	
	segmented_info = dir([[opt.data_dir '/' opt.data_set], ['/*' num2str(patient.id) '*_0.mat']]);
	for j=1:size(segmented_info,1) % for sobre las imagenes segmentadas
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
	patient = addUserData2Database(patient, opt);
% 	patient
% 	keyboard
	cows_add_patient(patient, opt.overwrite);
end


function patient = addUserData2Database(patient, opt)

for i = 1:length(patient.selected_pics)
	logs = dir([[opt.data_dir '/' opt.data_set], ['/' patient.selected_pics{i} '*.mat']]);
	aux.n_curves = 0;
	for j = 1:size(logs,1)
		data = load([opt.data_dir '/' opt.data_set '/' logs(j).name]);
		if ~isempty(data.control_points)
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
	end
	patient.control_points{i} = aux.control_points;
	patient.n_curves(i) = aux.n_curves;
end
