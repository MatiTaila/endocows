function varargout = cows_manual_segmentation_gui(varargin)
% COWS_MANUAL_SEGMENTATION_GUI MATLAB code for cows_manual_segmentation_gui.fig
%      COWS_MANUAL_SEGMENTATION_GUI, by itself, creates a new COWS_MANUAL_SEGMENTATION_GUI or raises the existing
%      singleton*.
%
%      H = COWS_MANUAL_SEGMENTATION_GUI returns the handle to a new COWS_MANUAL_SEGMENTATION_GUI or the handle to
%      the existing singleton*.
%
%      COWS_MANUAL_SEGMENTATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COWS_MANUAL_SEGMENTATION_GUI.M with the given input arguments.
%
%      COWS_MANUAL_SEGMENTATION_GUI('Property','Value',...) creates a new COWS_MANUAL_SEGMENTATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cows_manual_segmentation_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cows_manual_segmentation_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cows_manual_segmentation_gui

% Last Modified by GUIDE v2.5 17-Jun-2013 11:04:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cows_manual_segmentation_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @cows_manual_segmentation_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cows_manual_segmentation_gui is made visible.
function cows_manual_segmentation_gui_OpeningFcn(hObject, eventdata, handles, varargin)
disp('Aca puedo poner cosas que quiero que se ejecuten al principio');
home
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cows_manual_segmentation_gui (see VARARGIN)

% Choose default command line output for cows_manual_segmentation_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cows_manual_segmentation_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cows_manual_segmentation_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadImage.
function loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname,PathName,FilterIndex] = uigetfile({'*.png', 'All png images (*.png)'; ...
	'*.png; *.jpg; *.jpeg; *.pnm; *.tiff', 'All images (*.png; *.jpg; *.jpeg; *.pnm; *.tiff)'; ...
	'*.*', 'All files (*.*)'}, ...
	'Select image for manual segmentation', ...
	'../../data');
if(fname~=0)
    currentImageName = [PathName fname];
	im=imread( currentImageName );
	gcf;
	imshow(im);
	set(gcf,'tag',fname);
end

ud = get(gcf,'UserData');
ud.n_curves = 0;
ud.handle_control_points = {};
ud.control_points = {};
ud.handle_interpol = 0;
ud.ImagesPath = PathName;
ud.dirinfo = dir([ud.ImagesPath, '/*.png']);
ud.currentImageName = currentImageName;

% vaca_id = sscanf(fname, '%*c%*d%*c%*d%*c%*d%*c%d*');
count = 1;
curr_name = ud.dirinfo(count).name;
k=strcmp(curr_name,fname);
while ~k
	count = count + 1;
	curr_name = ud.dirinfo(count).name;
	k=strcmp(curr_name,fname);
end

ud.ImagesProcessed = count - 1;
ud.text_handle = show_text(fname);
ud.comment = '';
set(gcf,'UserData',ud);
set(findobj('tag','comment'), 'String', ud.comment);

show_curves(fname);


% --- Executes on button press in nextImage.
function nextImage_Callback(hObject, eventdata, handles)
% hObject    handle to nextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.n_curves = 0;
ud.ImagesProcessed = ud.ImagesProcessed + 1;
dirinfo = ud.dirinfo;
if ud.ImagesProcessed == size(dirinfo,1)
	ud.ImagesProcessed = 0;
end
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed + 1 ).name ];
gcf;
im = imread( nextImageName );
cla
imshow( im )
ud.currentImageName = nextImageName;
set(findobj(gcf, 'tag','comment'), 'String','Comment:');
fname = ud.dirinfo(ud.ImagesProcessed + 1).name;
ud.text_handle = show_text(fname);
ud.comment = '';
set(gcf,'UserData',ud);
set(findobj('tag','comment'), 'String', ud.comment);
show_curves(fname);


% --- Executes on button press in prevImage.
function prevImage_Callback(hObject, eventdata, handles)
% hObject    handle to prevImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.n_curves = 0;
ud.ImagesProcessed = ud.ImagesProcessed - 1;
dirinfo = ud.dirinfo;
if ud.ImagesProcessed == -1
	ud.ImagesProcessed = size(dirinfo,1)-1;
end
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed + 1 ).name ];
gca;
im = imread( nextImageName );
cla
imshow( im )
ud.currentImageName = nextImageName;
set(findobj(gcf, 'tag','comment'), 'String','Comment:');
fname = ud.dirinfo(ud.ImagesProcessed + 1).name;
ud.text_handle = show_text(fname);
ud.comment = '';
set(gcf,'UserData',ud);
set(findobj('tag','comment'), 'String', ud.comment);
show_curves(fname);


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud=get(gcf, 'UserData');
new_path = sprintf([ud.ImagesPath, 'logs']);
mkdir_cmd = sprintf(['mkdir ' new_path]);
if ~exist(new_path, 'dir')
	disp(['Creating folder: ' new_path ' ...']);
	system(mkdir_cmd);
	disp('Done!');
end
files = dir([ud.ImagesPath, '/*.mat']);
old_path = pwd;
cd(new_path);

% output file name
count = 0;
base_tar_name = 'all_logs_';
tar_name = [base_tar_name num2str(count) '.tar'];
while exist(tar_name, 'file')
	count = count+1;
	tar_name = [base_tar_name num2str(count) '.tar'];
end

disp(['Exporting all curves into: ' new_path '/' tar_name ' ...']);
tar(tar_name, {files.name}, ud.ImagesPath);
disp('Done!');
cd(old_path)


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.comment = get(findobj(gcf, 'tag','comment'), 'String');
set(gcf,'UserData',ud);
fname = ud.currentImageName;
count = 0;
log_name = [fname '_' num2str(count)];
while exist([log_name '.mat'],'file')
	log_name = [fname '_' num2str(count)];
	count = count+1;
end
save([log_name '.mat'],'-struct','ud')
disp(['Saved file: ' log_name '.mat']);


% --- Executes on button press in drawCurve.
function drawCurve_Callback(hObject, eventdata, handles)
% hObject    handle to drawCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.n_curves = ud.n_curves + 1;

[points, h_curve, h_points] = cows_draw_closed_curve(ud.n_curves);

ud.handle_control_points(ud.n_curves) = {h_points};
ud.control_points(ud.n_curves) = {points};
ud.handle_interpol(ud.n_curves) = h_curve;
ud.mode = 'normal';

set(gcf,'UserData',ud);
set(gcf,'WindowButtonUpFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0 , 1)']);
set(gcf,'WindowButtonMotionFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0, 2)']);

function comment_Callback(hObject, eventdata, handles)
% hObject    handle to comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of comment as text
%        str2double(get(hObject,'String')) returns contents of comment as a double


% --- Executes during object creation, after setting all properties.
function comment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in info.
function info_Callback(hObject, eventdata, handles)
% hObject    handle to info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of info
ud = get(gcf, 'UserData');
state = get(ud.text_handle, 'Visible');
if strcmp(state, 'on')
	set(ud.text_handle, 'Visible', 'off')
else
	set(ud.text_handle, 'Visible', 'on')
end
set(gcf, 'UserData', ud);

% --- Executes on button press in showHideCurves.
function showHideCurves_Callback(hObject, eventdata, handles)
% hObject    handle to showHideCurves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of showHideCurves
ud = get(gcf, 'UserData');
if ~isempty(ud.control_points)
	state = get(ud.handle_interpol(1), 'Visible');
	if strcmp(state, 'on')
		new_state = 'off';
	else
		new_state = 'on';
	end
	for i=1:size(ud.handle_interpol,2)
		set(ud.handle_interpol(i), 'Visible', new_state)
		for j=1:size(ud.handle_control_points{i},1)
			set(ud.handle_control_points{i}(j), 'Visible', new_state);
		end
	end
end
set(gcf, 'UserData', ud);


% --- Executes on button press in show1Curve.
function show1Curve_Callback(hObject, eventdata, handles)
% hObject    handle to show1Curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf, 'UserData');
fname = ud.dirinfo(ud.ImagesProcessed + 1).name;
vaca_id = sscanf(fname, '%*c%*d%*c%*d%*c%*d%*c%d*');
[fname,PathName,FilterIndex] = uigetfile({...
	[fname '*.mat'], 'Saved curves for this image'; ...
	['*' num2str(vaca_id) '*.mat'], 'Saved curves for this cow'; ...
	'*.mat', 'All Matlab Files (*.mat)'; ...
	'*.*', 'All Files (*.*)'}, ...
	'Select *.mat file to show saved curves', ...
	ud.ImagesPath);
if(fname~=0)
	show_curve([PathName fname]);
end


% --- Executes on button press in clearAll.
function clearAll_Callback(hObject, eventdata, handles)
% hObject    handle to clearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.n_curves = 0;
for i=1:size(ud.handle_control_points,2)
	delete(ud.handle_control_points{i});
	delete(ud.handle_interpol(i));
end
ud.handle_control_points = {};
ud.control_points = {};
ud.handle_interpol = 0;
ud.comment = '';
set(gcf,'UserData',ud);
set(findobj('tag','comment'), 'String', ud.comment);


function h = show_text(str)
str2(1) = {strrep(str,'_','\_')};
h = text(10,350, str2, 'color', 'y', 'FontSize',15);
obj = findobj('tag','info');
button_state = get(obj,'Value');
if button_state == get(obj,'Max')
	set(h, 'Visible', 'on')
elseif button_state == get(obj,'Min')
	set(h, 'Visible', 'off')
end

function th = add_text_line(th_in, str_in)
% Se usa asi esta funcion
% ud = get(gcf, 'UserData');
% ud.text_handle = add_text_line(ud.text_handle, 'Linea nueva');
% set(gcf, 'UserData', ud);
str = get(th_in,'String');
str(size(str,1)+1) = {str_in};
th = th_in;
set(th,'String', str);


function show_curves(fname)
ud = get(gcf,'UserData');
obj = findobj('tag','showHideCurves');
button_state = get(obj,'Value');

logs = dir([ud.ImagesPath, fname '*.mat']);
if ~isempty(logs)
	for i=1:size(logs,1)
		show_curve([ud.ImagesPath logs(i).name]);
	end
end

if button_state == get(obj,'Min')
	ud = get(gcf, 'UserData');
	for i=1:size(ud.handle_interpol,2)
		set(ud.handle_interpol(i), 'Visible', 'off')
		for j=1:size(ud.handle_control_points{i},1)
			set(ud.handle_control_points{i}(j), 'Visible', 'off');
		end
	end
	set(gcf, 'UserData', ud);
end


function show_curve(path)
wid = 1.8;
ultravacas_colors;
data = load(path);
hold on;

ud = get(gcf,'UserData');

if ~isempty(data.control_points)
	if iscell(data.control_points)
		% version nueva - multiples curvas
		for k=1:data.n_curves
			ud.n_curves = ud.n_curves + 1;
			[xs, ys] = cows_closed_spline(data.control_points{k}(:,1)',data.control_points{k}(:,2)');
			h_curve = plot(xs,ys,'--','color',colors{1},'Linewidth',wid);
			
			str = [get(gcf,'tag') '_interpolada_' ud.n_curves];
			set(h_curve,'tag',str);

			h_points=zeros(size(data.control_points{k},1),1);
			
			for i=1:size(data.control_points{k},1)
				h_points(i) = plot(data.control_points{k}(i,1), data.control_points{k}(i,2), 'oy', 'linewidth', wid);
				set(h_points(i),'tag',[get(gcf,'tag') '_control_' num2str(ud.n_curves) '_' num2str(i)]);
				set(h_points(i),'ButtonDownFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ',' num2str(i) ', 0)']);
			end
% 			keyboard
			ud.handle_control_points(ud.n_curves) = {h_points};
			ud.control_points(ud.n_curves) = {data.control_points{k}};
			ud.handle_interpol(ud.n_curves) = h_curve;
			ud.mode = 'normal';

			set(gcf,'WindowButtonUpFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0 , 1)']);
			set(gcf,'WindowButtonMotionFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0, 2)']);
		end
		
% 		assignin('base', 'xCurve', xs);
% 		assignin('base', 'yCurve', ys);
		
	else
		ud.n_curves = ud.n_curves + 1;
		
		[xs, ys] = cows_closed_spline(data.control_points(:,1)',data.control_points(:,2)');
		h_curve = plot(xs,ys,'--','color',colors{1},'Linewidth',wid);
		
		str = [get(gcf,'tag') '_interpolada_' ud.n_curves];
		set(h_curve,'tag',str);
		
		h_points=zeros(size(data.control_points,1),1);
		for i=1:size(data.control_points,1)
			h_points(i) = plot(data.control_points(i,1), data.control_points(i,2), 'oy', 'linewidth', wid);
			set(h_points(i),'tag',[get(gcf,'tag') '_control_' num2str(ud.n_curves) '_' num2str(i)]);
			set(h_points(i),'ButtonDownFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ',' num2str(i) ', 0)']);
		end
		
		ud.handle_control_points(ud.n_curves) = {h_points};
		ud.control_points(ud.n_curves) = {data.control_points};
		ud.handle_interpol(ud.n_curves) = h_curve;
		ud.mode = 'normal';
		
		set(gcf,'WindowButtonUpFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0 , 1)']);
		set(gcf,'WindowButtonMotionFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0, 2)']);
		
% 		assignin('base', 'xCurve', xs);
% 		assignin('base', 'yCurve', ys);
		
	end
end

comment_obj = findobj('tag','comment');
new_comment = [get(comment_obj, 'String') ' - ' data.comment];
set(comment_obj, 'String', new_comment);
ud.comment = new_comment;

set(gcf, 'UserData', ud);
% keyboard