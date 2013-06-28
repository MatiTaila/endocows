function [ind, n_found] = cows_patient_search(id, tambo)

load('cows_cfg');
ind = [];
p_out = [];

for i=1:length(patients)
	p=patients(i);
	if( (p.id == id) && strcmp(p.tambo, tambo) )
        p_out=[p_out p];
		ind=[ind i];
	end
end

n_found = length(ind);
if n_found > 1
	fprintf('ERROR: more than 1 patient found!\n\tError in cows_patient_search.m at line 15\n');
end