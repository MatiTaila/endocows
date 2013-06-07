function varargout = manual_segmentation_gui(varargin)
% MANUAL_SEGMENTATION_GUI MATLAB code for manual_segmentation_gui.fig
%      MANUAL_SEGMENTATION_GUI, by itself, creates a new MANUAL_SEGMENTATION_GUI or raises the existing
%      singleton*.
%
%      H = MANUAL_SEGMENTATION_GUI returns the handle to a new MANUAL_SEGMENTATION_GUI or the handle to
%      the existing singleton*.
%
%      MANUAL_SEGMENTATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_SEGMENTATION_GUI.M with the given input arguments.
%
%      MANUAL_SEGMENTATION_GUI('Property','Value',...) creates a new MANUAL_SEGMENTATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manual_segmentation_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manual_segmentation_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manual_segmentation_gui

% Last Modified by GUIDE v2.5 07-Jun-2013 11:21:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manual_segmentation_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @manual_segmentation_gui_OutputFcn, ...
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


% --- Executes just before manual_segmentation_gui is made visible.
function manual_segmentation_gui_OpeningFcn(hObject, eventdata, handles, varargin)
disp('Aca puedo poner cosas que quiero que se ejecuten al principio');
home
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manual_segmentation_gui (see VARARGIN)

% Choose default command line output for manual_segmentation_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manual_segmentation_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manual_segmentation_gui_OutputFcn(hObject, eventdata, handles) 
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

[fname,PathName,FilterIndex] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif'},'.');
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

set(gcf,'UserData',ud);


% --- Executes on button press in nextImage.
function nextImage_Callback(hObject, eventdata, handles)
ud = get(gcf,'UserData');
ud.n_curves = 0;
ud.ImagesProcessed = ud.ImagesProcessed + 1;
dirinfo = ud.dirinfo;
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed + 1 ).name ];
gcf;
im = imread( nextImageName );
imshow( im )
ud.currentImageName = nextImageName;
set(findobj(gcf, 'tag','comments'), 'String','Comment:');
fname = ud.dirinfo(ud.ImagesProcessed + 1).name;
ud.text_handle = show_text(fname);
set(gcf,'UserData',ud);
% hObject    handle to nextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prevImage.
function prevImage_Callback(hObject, eventdata, handles)
ud = get(gcf,'UserData');
ud.n_curves = 0;
ud.ImagesProcessed = ud.ImagesProcessed - 1;
dirinfo = ud.dirinfo;
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed + 1 ).name ];
gcf;
im = imread( nextImageName );
imshow( im )
ud.currentImageName = nextImageName;
set(findobj(gcf, 'tag','comments'), 'String','Comment:');
fname = ud.dirinfo(ud.ImagesProcessed + 1).name;
ud.text_handle = show_text(fname);
set(gcf,'UserData',ud);
% hObject    handle to prevImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


% --- Executes on button press in drawCurve.
function drawCurve_Callback(hObject, eventdata, handles)
% hObject    handle to drawCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud = get(gcf,'UserData');
ud.n_curves = ud.n_curves + 1;

[points, h_curve, h_points] = draw_closed_curve(ud.n_curves);

ud.handle_control_points(ud.n_curves) = {h_points};
ud.control_points(ud.n_curves) = {points};
ud.handle_interpol(ud.n_curves) = h_curve;
ud.mode = 'normal';

set(gcf,'UserData',ud);
set(gcf,'WindowButtonUpFcn',['edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0 , 1)']);
set(gcf,'WindowButtonMotionFcn',['edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(ud.n_curves) ', 0, 2)']);

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


% --- Executes on button press in show1Curve.
function show1Curve_Callback(hObject, eventdata, handles)
% hObject    handle to show1Curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clearAll.
function clearAll_Callback(hObject, eventdata, handles)
% hObject    handle to clearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
