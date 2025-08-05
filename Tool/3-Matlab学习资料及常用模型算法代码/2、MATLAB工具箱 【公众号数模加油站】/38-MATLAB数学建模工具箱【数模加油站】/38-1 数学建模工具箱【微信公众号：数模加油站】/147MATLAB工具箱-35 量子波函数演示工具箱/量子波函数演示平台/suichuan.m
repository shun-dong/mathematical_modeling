function varargout = suichuan(varargin)
% SUICHUAN M-file for suichuan.fig
%      SUICHUAN, by itself, creates text4 new SUICHUAN or raises the existing
%      singleton*.
%
%      H = SUICHUAN returns the handle to text4 new SUICHUAN or the handle to
%      the existing singleton*.
%
%      SUICHUAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUICHUAN.M with the given input arguments.
%
%      SUICHUAN('Property','Value',...) creates text4 new SUICHUAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before suichuan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to suichuan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help suichuan

% Last Modified by GUIDE v2.5 25-Apr-2011 10:42:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @suichuan_OpeningFcn, ...
                   'gui_OutputFcn',  @suichuan_OutputFcn, ...
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


% --- Executes just before suichuan is made visible.
function suichuan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to suichuan (see VARARGIN)

% Choose default command line output for suichuan
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes suichuan wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = suichuan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(suichuan);
get(zongpingtai)



function m_Callback(hObject, eventdata, handles)
% hObject    handle to m (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m as text
%        str2double(get(hObject,'String')) returns contents of m as text4 double


% --- Executes during object creation, after setting all properties.
function m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to m (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E_Callback(hObject, eventdata, handles)
% hObject    handle to E (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E as text
%        str2double(get(hObject,'String')) returns contents of E as text4 double


% --- Executes during object creation, after setting all properties.
function E_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function U0_Callback(hObject, eventdata, handles)
% hObject    handle to U0 (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of U0 as text
%        str2double(get(hObject,'String')) returns contents of U0 as text4 double


% --- Executes during object creation, after setting all properties.
function U0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to U0 (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function a_Callback(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a as text
%        str2double(get(hObject,'String')) returns contents of a as text4 double


% --- Executes during object creation, after setting all properties.
function a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toushe_Callback(hObject, eventdata, handles)
% hObject    handle to toushe (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toushe as text
%        str2double(get(hObject,'String')) returns contents of toushe as text4 double


% --- Executes during object creation, after setting all properties.
function toushe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toushe (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fanshe_Callback(hObject, eventdata, handles)
% hObject    handle to fanshe (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fanshe as text
%        str2double(get(hObject,'String')) returns contents of fanshe as text4 double


% --- Executes during object creation, after setting all properties.
function fanshe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fanshe (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toushegeshu_Callback(hObject, eventdata, handles)
% hObject    handle to toushegeshu (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toushegeshu as text
%        str2double(get(hObject,'String')) returns contents of toushegeshu as text4 double


% --- Executes during object creation, after setting all properties.
function toushegeshu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toushegeshu (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fanshegeshu_Callback(hObject, eventdata, handles)
% hObject    handle to fanshegeshu (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fanshegeshu as text
%        str2double(get(hObject,'String')) returns contents of fanshegeshu as text4 double


% --- Executes during object creation, after setting all properties.
function fanshegeshu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fanshegeshu (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
h=1.0545e-34;
a=str2num(get(handles.a,'string'));a0=a*1e-10;%��ȡ���ݿ��
m=str2num(get(handles.m,'string'))*9.10908e-31;%��ȡ��������
e=str2num(get(handles.E,'string'))*1.602192e-19;%��ȡ��������
u=str2num(get(handles.U0,'string'));%��ȡ���ݸ߶�
u0=u*1.602192e-19;
k1=((2*m*e)^(1/2))/h;
if u0>e %��������С�����ݸ߶�
k2=((2*m*(u0-e))^(1/2))/h;
patch([7 8 8 7],[0 0 4 4],'b');%�����������飨��ɫ��
hold on;
mm=sinh(k2*a0);
T=(4*(k1^2)*(k2^2))/(((k1^2+k2^2)^2)*mm^2+4*(k1^2)*(k2^2))%����͸��ϵ��
else if u0<e %���������������ݸ߶�
        k2=((2*m*(e-u0))^(1/2))/h;
        patch([7 8 8 7],[0 0 2 2],'b');%�����������飨��ɫ��
    hold on;
    mm=sin(k2*a0);
T=(4*(k1^2)*(k2^2))/(((k1^2-k2^2)^2)*mm^2+4*(k1^2)*(k2^2))
    else %���������������ݸ߶�
         patch([7 8 8 7],[0 0 3 3],'g');%�����������飨��ɫ��
    hold on;
        T=1
    end
end
set(handles.toushe,'string',T);%��ʾ͸��ϵ��
set(handles.fanshe,'string',1-T);%��ʾ����ϵ��
t=0;f=0;%����ͳ��͸�䷴�������ֵ
y=str2num(get(handles.n,'string'));%��ȡ��ʾ������
for j=1:y%�������Ӹ���
    r=rand;%������0��1�������
    if 1-T<r&r<=1 %����͸������
    x=0;y=3;
    m=plot(x,y,'.','EraseMode','Xor','MarkerSize',5,'color','r');%��������
    axis([0 15 0 7]);
    axis manual;%�̶�������
    for i=1:160
     if i<70 %�������
    x=x+0.1;
    set(m,'Xdata',x,'Ydata',y);
    drawnow;%ˢ��
    i=i+1;
     else if 70<=i&i<80%���ӵ�������
        if u0>e%��������С�����ݸ߶�
             x=x+0.1;
        y=3+sin(6*pi*x);%����͸����Ϊ���壨����ͨ����
      set(m,'Xdata',x,'Ydata',y);
      drawnow;%ˢ��
      pause(0.02);
      i=i+1;
        else %�����������ڵ������ݸ߶�
            x=x+0.1;y=3;
            set(m,'Xdata',x,'Ydata',y);
           drawnow;
           pause(0.02);
           i=i+1;
        end
         else %�����Ҷ�
             x=x+0.1;y=3;
            set(m,'Xdata',x,'Ydata',y);
           drawnow;
           i=i+1;
         end
     end
    end
     t=t+1; 
    else %�������ӷ�������
     x=0;y=3;
    m=plot(x,y,'.','EraseMode','Xor','MarkerSize',5,'color','r');%����'EraseMode'���ԣ��ɲ�������'Markersize'����
    axis([0 15 0 7]);
    axis manual;
    for i1=1:160
     if i1<70 %�������
    x=x+0.1;
    set(m,'Xdata',x,'Ydata',y);
    drawnow;
    i1=i1+1;
     else %���ӱ������ȥ
             x=x-0.1;%����-0.1ȡ��
            set(m,'Xdata',x,'Ydata',y);
           drawnow;%ˢ��
           i1=i1+1;   
     end
    end
    f=f+1;%ͳ�Ʒ�����������1
    end
    set(handles.toushegeshu,'string',t);%��ʾͳ��͸�����
    set(handles.fanshegeshu,'string',f);%��ʾͳ�Ʒ���������
end


% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause;


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
set(handles.m,'string','');
set(handles.E,'string','');
set(handles.U0,'string','');
set(handles.a,'string','');
set(handles.n,'string','');
set(handles.toushe,'string','');
set(handles.fanshe,'string','');
set(handles.toushegeshu,'string','');
set(handles.fanshegeshu,'string','');



function n_Callback(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n as text
%        str2double(get(hObject,'String')) returns contents of n as text4 double


% --- Executes during object creation, after setting all properties.
function n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in text4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have text4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
