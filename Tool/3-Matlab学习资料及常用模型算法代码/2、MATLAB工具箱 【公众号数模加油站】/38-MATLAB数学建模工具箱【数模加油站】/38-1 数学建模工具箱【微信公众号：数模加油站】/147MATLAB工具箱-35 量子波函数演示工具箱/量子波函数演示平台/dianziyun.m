function varargout = dianziyun(varargin)
% DIANZIYUN M-file for dianziyun.fig
%      DIANZIYUN, by itself, creates a new DIANZIYUN or raises the existing
%      singleton*.
%
%      H = DIANZIYUN returns the handle to a new DIANZIYUN or the handle to
%      the existing singleton*.
%
%      DIANZIYUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIANZIYUN.M with the given input arguments.
%
%      DIANZIYUN('Property','Value',...) creates a new DIANZIYUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dianziyun_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dianziyun_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dianziyun

% Last Modified by GUIDE v2.5 16-May-2011 20:27:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dianziyun_OpeningFcn, ...
                   'gui_OutputFcn',  @dianziyun_OutputFcn, ...
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


% --- Executes just before dianziyun is made visible.
function dianziyun_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dianziyun (see VARARGIN)

% Choose default command line output for dianziyun
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dianziyun wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dianziyun_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in jing.
function jing_Callback(hObject, eventdata, handles)
% hObject    handle to jing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
syms r t;
global n l m R;
if n>0&l<n&m>=-l&m<=l
    if (n-round(n)==0)&(l-round(l)==0)&(m-round(m)==0)
        a=-n+l+1;
b=2*l+2;
f=1;
a1=a;
b1=b;
k=1;
while a
    f=f+(a1/b1)*(1/factorial(k))*((2*r/n)^k);
    a=a+1;
    b=b+1;
    k=k+1;
    a1=a1*a;
    b1=b1*b;
end
a=exp(-r/n);
b=(2*r/n)^l;
a1=factorial(n+l);
b1=factorial(n-l-1);
d=(n^2*factorial(2*l+1));
R=a*b*f*2*sqrt(a1/b1)/d;
R1=R^2*r^2;
ezplot(R1,[0,5*n^2])
title('径向概率分布')
xlabel('r/a')
grid on;
    else 
        errordlg('量子数必为整数','Error')
    end
else
    errordlg('量子数输入错误，请参看说明','Error')
end


% --- Executes on button press in jiaoping.
function jiaoping_Callback(hObject, eventdata, handles)
% hObject    handle to jiaoping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
syms r t J m1;
global n l m w R;
if m>=0
    if l+m==0;
        P=1;
    else
        P=((1-t^2)^(m/2))*diff((t^2-1)^l,l+m);
    end
else
    m1=-m;
    P=((1-t^2)^(m1/2))*diff((t^2-1)^l,l+m1);
    P=P1*(-1)^(-m)*factorial(l+m)/factorial(l-m);
end
a=2^l*factorial(l);
a=1/a;
a=a*(-1)^m;
b=(2*l+1)*factorial(l-m);
d=4*pi*factorial(l+m);
Y=P*sqrt(b/d)*a;
if l==0
    ezplot('.795774715e-1');
else
    x=0:0.02*pi:2*pi;
    t=cos(x);
    Y1=subs(Y,sym('t'),t);
    Y1=abs(Y1).^2;
 
    polar(x,Y1,'-r');
end
title('角向平面图')



% --- Executes on button press in jiaosanwei.
function jiaosanwei_Callback(hObject, eventdata, handles)
% hObject    handle to jiaosanwei (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n l m R w;
delta=pi/40;
theta0=0:delta:pi;
phi0=0:2*delta:2*pi;
[phi,theta]=meshgrid(phi0,theta0);  %构造θφ数据网络
Ylm=legendre(l,cos(theta0));      %计算勒让德函数的值
b=(2*l+1)*factorial(l-m); d=4*pi*factorial(l+m);
m=abs(m);
Ylm=Ylm(m+1,:)';
L=size(theta,1);
Y=repmat(Ylm,1,L);
yy=Y.^2*b/d;
%计算实部在球坐标系下各点的值
r=yy.*sin(theta);
x=r.*cos(phi);
y=r.*sin(phi);
z=yy.*cos(theta);
%绘图
surf(x,y,z)
view((get(findobj(gcf,'tag','slider1'),'value')),(get(findobj(gcf,'tag','slider2'),'value')));
xlabel('x')
ylabel('y')
zlabel('z')
axis equal

title('角向分布');

% --- Executes on button press in donghua.
function donghua_Callback(hObject, eventdata, handles)
% hObject    handle to donghua (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n l m R w;
delta=pi/40;
theta0=0:delta:pi;
phi0=0:2*delta:2*pi;
[phi,theta]=meshgrid(phi0,theta0);  %构造θφ数据网络
Ylm=legendre(l,cos(theta0));      %计算勒让德函数的值
b=(2*l+1)*factorial(l-m); d=4*pi*factorial(l+m);
m=abs(m);
Ylm=Ylm(m+1,:)';
L=size(theta,1);
Y=repmat(Ylm,1,L);
yy=Y.^2*b/d;
%计算实部在球坐标系下各点的值
r=yy.*sin(theta);
x=r.*cos(phi);
y=r.*sin(phi);
z=yy.*cos(theta);
%绘图

j1=1;
MOV=moviein(36);
for al=-180:10:180
    surf(x,y,z);
    view(al+(get(findobj(gcf,'tag','slider1'),'value')),(get(findobj(gcf,'tag','slider2'),'value')));
   axis equal

    MOV(:,j1)=getframe;
    j1=j1+1;
end
surf(x,y,z);
axis equal

view((get(findobj(gcf,'tag','slider1'),'value')),(get(findobj(gcf,'tag','slider2'),'value')));


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.n,'string','');
set(handles.l,'string','');
set(handles.m,'string','');
cla reset;



% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
% hObject    handle to back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(dianziyun);
get(zongpingtai)



function n_Callback(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n as text
%        str2double(get(hObject,'String')) returns contents of n as a double
global n;
n=str2double(get(hObject,'string'));

% --- Executes during object creation, after setting all properties.
function n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function l_Callback(hObject, eventdata, handles)
% hObject    handle to l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of l as text
%        str2double(get(hObject,'String')) returns contents of l as a double
global l;
l=str2double(get(hObject,'string'));

% --- Executes during object creation, after setting all properties.
function l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function m_Callback(hObject, eventdata, handles)
% hObject    handle to m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m as text
%        str2double(get(hObject,'String')) returns contents of m as a double
global m;
m=str2double(get(hObject,'string'));

% --- Executes during object creation, after setting all properties.
function m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fangweijiao_Callback(hObject, eventdata, handles)
% hObject    handle to fangweijiao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fangweijiao as text
%        str2double(get(hObject,'String')) returns contents of fangweijiao as a double


% --- Executes during object creation, after setting all properties.
function fangweijiao_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fangweijiao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yangjiao_Callback(hObject, eventdata, handles)
% hObject    handle to yangjiao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yangjiao as text
%        str2double(get(hObject,'String')) returns contents of yangjiao as a double


% --- Executes during object creation, after setting all properties.
function yangjiao_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yangjiao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.fangweijiao,'string',get(handles.slider1,'value'))


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.yangjiao,'string',get(handles.slider2,'value'))

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
