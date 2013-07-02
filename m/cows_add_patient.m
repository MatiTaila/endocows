function cows_add_patient(patient, update)
keyboard
if nargin<2
	update=0;
end

database_filename=['./cows_cfg'];

load(database_filename);

[ind_p, n_pat_found] = cows_patient_search(patient.id, patient.tambo);

state.bkp=1;

if n_pat_found==0
	patients=[patients patient];
	fprintf('Adding new patient... \n');
elseif update
	fprintf('Updating existing patient...\n');
	fprintf('index: %d\n',ind_p);
	patients(ind_p) = patient;
else
	fprintf('Patient exist. Not adding.\n');
	state.bkp = 0;
end

if state.bkp
	database_filename_backup=sprintf(['bkp/' database_filename  '_backup_%4d_%02d_%02d_%02d_%02d_%02d'],fix(clock));
	if ~exist('bkp', 'dir')
		fprintf('bkp dir does not exist, creating...\n');
		mkdir('bkp')
	end
	cmd = ['cp -f ' database_filename '.mat ' database_filename_backup '.mat'];
	fprintf('Saving backup: %s ...\n',database_filename_backup);
	fprintf('  cmd: %s\n', cmd);
	system(cmd);
	save(database_filename,'patients');
end
