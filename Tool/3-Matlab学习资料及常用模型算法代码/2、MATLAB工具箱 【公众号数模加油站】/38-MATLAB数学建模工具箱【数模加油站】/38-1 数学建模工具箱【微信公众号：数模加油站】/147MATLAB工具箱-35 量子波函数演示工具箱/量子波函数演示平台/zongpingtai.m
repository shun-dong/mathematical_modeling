function varargout = zongpingtai(varargin)
% ZONGPINGTAI M-file for zongpingtai.fig
%      ZONGPINGTAI, by itself, creates a new ZONGPINGTAI or raises the existing
%      singleton*.
%
%      H = ZONGPINGTAI returns the handle to a new ZONGPINGTAI or the handle to
%      the existing singleton*.
%
%      ZONGPINGTAI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZONGPINGTAI.M with the given input arguments.
%
%      ZONGPINGTAI('Property','Value',...) creates a new ZONGPINGTAI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zongpingtai_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zongpingtai_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zongpingtai

% Last Modified by GUIDE v2.5 16-May-2011 15:45:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @zongpingtai_OpeningFcn, ...
                   'gui_OutputFcn',  @zongpingtai_OutputFcn, ...
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


% --- Executes just before zongpingtai is made visible.
function zongpingtai_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to zongpingtai (see VARARGIN)

% Choose default command line output for zongpingtai
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes zongpingtai wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = zongpingtai_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in dianziyun.
function dianziyun_Callback(hObject, eventdata, handles)
% hObject    handle to dianziyun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(zongpingtai);
get(dianziyun)


% --- Executes on button press in suichuan.
function suichuan_Callback(hObject, eventdata, handles)
% hObject    handle to suichuan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(zongpingtai);
get(suichuan)



% --- Executes on button press in sitake.
function sitake_Callback(hObject, eventdata, handles)
% hObject    handle to sitake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(zongpingtai);
get(sitake)


% --- Executes on button press in shuangfeng.
function shuangfeng_Callback(hObject, eventdata, handles)
% hObject    handle to shuangfeng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(zongpingtai);
get(shuangfeng)
