function varargout = gui_curve_drawing(varargin)
% GUI_CURVE_DRAWING MATLAB code for gui_curve_drawing.fig
%      GUI_CURVE_DRAWING, by itself, creates a new GUI_CURVE_DRAWING or raises the existing
%      singleton*.
%
%      H = GUI_CURVE_DRAWING returns the handle to a new GUI_CURVE_DRAWING or the handle to
%      the existing singleton*.
%
%      GUI_CURVE_DRAWING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CURVE_DRAWING.M with the given input arguments.
%
%      GUI_CURVE_DRAWING('Property','Value',...) creates a new GUI_CURVE_DRAWING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_curve_drawing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_curve_drawing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_curve_drawing

% Last Modified by GUIDE v2.5 21-May-2013 18:15:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_curve_drawing_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_curve_drawing_OutputFcn, ...
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


% --- Executes just before gui_curve_drawing is made visible.
function gui_curve_drawing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_curve_drawing (see VARARGIN)

% Choose default command line output for gui_curve_drawing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes gui_curve_drawing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_curve_drawing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_closed_curve.
function button_closed_curve_Callback(hObject, eventdata, handles)
ultravacas_colors;
[points, h_curve, h_points] = closed_curve();
gcf;
hold on;
delete(h_points);
delete(h_curve);
[xs, ys] = closed_spline(points(:,1)',points(:,2)');
h_curve=plot(xs,ys,'--','color',colors{1},'Linewidth',2);
str=[get(gcf,'tag') '_interpolada'];
set(h_curve,'tag',str);
h_points=zeros(size(points,1),1);
for i=1:size(points,1)
	h_points(i) = plot(points(i,1), points(i,2), 'oy', 'linewidth', 2);
	set(h_points(i),'tag',[get(gcf,'tag') '_control_' num2str(i)]);
	set(h_points(i),'ButtonDownFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 0)']);
end
ud=get(gcf,'UserData');
ud.handle_control_points=h_points;
ud.control_points=points;
ud.handle_interpol=h_curve;
ud.mode = 'normal';
ud.id = ud.id+1;
set(gcf,'UserData',ud);

set(gcf,'WindowButtonUpFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 1)']);
set(gcf,'WindowButtonMotionFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 2)']);

% hObject    handle to button_closed_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_curve.
function clear_curve_Callback(hObject, eventdata, handles)
clear all
ud = get(gcf,'UserData');
delete(ud.handle_control_points);
delete(ud.handle_interpol);
ud.handle_control_points=[];
ud.control_points=[];
ud.handle_interpol=0;
set(gcf,'UserData',ud);
%delete(ud.
% hObject    handle to clear_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_image_tag.
function load_image_tag_Callback(hObject, eventdata, handles)
[fname,PathName,FilterIndex] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif'},'.');
if(fname~=0)
    currentImageName = [PathName fname];
	im=imread( currentImageName );
	gcf;
	imshow(im);
	set(gcf,'tag',fname);
end
ud = get(gcf,'UserData');
% if ~isempty(ud)
% 	delete(ud.handle_control_points);
% 	delete(ud.handle_interpol);
% end
ud.id=0;
ud.handle_control_points=[];
ud.control_points=[];
ud.handle_interpol=0;
ud.ImagesPath = PathName;
dirinfo = dir([ud.ImagesPath, '/*.png']);
ud.dirinfo = dirinfo;
ud.ImagesProcessed = 0;
ud.currentImageName = currentImageName;
set(gcf,'UserData',ud);
% [fname,PathName,FilterIndex] = uigetfile('c:/vips/incoming/converted/*.png');
% hObject    handle to load_image_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
ud = get(gcf,'UserData');
ud.comment = get(findobj(gcf, 'tag','comments'), 'String');
set(gcf,'UserData',ud);

% fname = ['./logs/' get(gcf, 'tag')];
fname = ud.currentImageName;

% f=fopen([fname '.xml'],'w');
% fprintf(f,'%s\n',['<curva' num2str(ud.id) '>']);
% fprintf(f,'\t%s\n','<control_points>');
% for i=1:size(ud.control_points,1)
% 	fprintf(f,'\t\t%d\t%d\n',ud.control_points(i,1), ud.control_points(i,2));
% end
% fprintf(f,'\t%s\n','</control_points>');
% fprintf(f,'%s\n',['</curva' num2str(ud.id) '>']);
% fclose(f);

count = 0;
log_name = [fname '_' num2str(count)];
while exist([log_name '.mat'],'file')
	log_name = [fname '_' num2str(count)];
	count = count+1;
end
save([log_name '.mat'],'-struct','ud')
disp(['Saved file: ' log_name '.mat']);
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function comments_Callback(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comments as text
%        str2double(get(hObject,'String')) returns contents of comments as a double


% --- Executes during object creation, after setting all properties.
function comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_curve.
function load_curve_Callback(hObject, eventdata, handles)
[fname,PathName,FilterIndex] = uigetfile({'*.mat'},'.');
if(fname~=0)
	ultravacas_colors;
	ud = load([PathName fname]);
	h = findobj('tag','comments');
	set(h, 'string', ud.comment);
	gcf
	hold on
	ud.mode = 'normal';
	
	for i=1:size(ud.control_points,1)
		h_points(i) = plot(ud.control_points(i,1), ud.control_points(i,2), 'oy', 'linewidth', 2);
		set(h_points(i),'tag',[get(gcf,'tag') '_control_' num2str(i)]);
		set(h_points(i),'ButtonDownFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 0)']);
	end
	
	[xs, ys] = closed_spline(ud.control_points(:,1)',ud.control_points(:,2)');
	h1 = plot(xs,ys,'--','color',colors{1},'Linewidth',2);
	
	set(h1,'tag',[get(gcf,'tag') '_interpolada']);
	
	ud.handle_control_points = h_points;
	ud.handle_interpol=h1;
	
	set(gcf,'UserData',ud);
	
	set(gcf,'WindowButtonUpFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 1)']);
	set(gcf,'WindowButtonMotionFcn',['edit_curve(''' char(get(gcf,'tag')) ''',' num2str(i) ', 2)']);

end
% hObject    handle to load_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
ud = get(gcf,'UserData');
ud.ImagesProcessed = ud.ImagesProcessed + 1;
dirinfo = ud.dirinfo;
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed + 1 ).name ]
gcf;
im = imread( nextImageName );
imshow( im )
ud.currentImageName = nextImageName;
set(gcf,'UserData',ud);
set(findobj(gcf, 'tag','comments'), 'String','Comment:');

% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles)
ud = get(gcf,'UserData');
ud.ImagesProcessed = ud.ImagesProcessed -1;
dirinfo = ud.dirinfo;
nextImageName = [ ud.ImagesPath dirinfo( ud.ImagesProcessed - 1 ).name ]
gcf;
im = imread( nextImageName );
imshow( im )
ud.currentImageName = nextImageName;
set(gcf,'UserData',ud);
set(findobj(gcf, 'tag','comments'), 'String','Comment:');
% hObject    handle to prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
