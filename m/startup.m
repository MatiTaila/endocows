close all
clear all
home

% Base dir for windows or linux
ultravacas_root = pwd;

if(isunix)
  slash = '/';
else
  slash = '\';
end

c=cell(1,1);

[status,host_str]=system('hostname');
hostname=strtrim(host_str);

if (strcmp(computer,'GLNX86') || strcmp(computer,'GLNXA64') || strcmp(computer,'MACI') || strcmp(computer,'MACI64'))
    if(strcmp(hostname,'tailabook'))
        homedir='~';
    else
        homedir='~';
    end
    basedir=[homedir '/develop/matlab'];
else
    homedir='c:/mat/develop';
    basedir=[homedir '/matlab'];
end

fprintf('base_dir: %s\n', basedir);

c{1}='/m_libs';
c{2}='/matlab';
c{3}='/octave';
c{4}='/oct-mat';

l=length(c);
p=[];
for i=1:l
    curr_path=[genpath([basedir c{i}])];
    fprintf('%s\n',curr_path);
    p=[p curr_path];
end

% % Agrego subdirectorios del path actual
path_tmp=genpath(sprintf('%s%cpics', ultravacas_root, slash));
p=[p path_tmp];

addpath(path,p)

%% Other

slCharacterEncoding('UTF-8');

% set format
% format long g

% load colors
ultravacas_colors