function varargout = sitake(varargin)
% SITAKE M-file for sitake.fig
%      SITAKE, by itself, creates a new SITAKE or raises the existing
%      singleton*.
%
%      H = SITAKE returns the handle to a new SITAKE or the handle to
%      the existing singleton*.
%
%      SITAKE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SITAKE.M with the given input arguments.
%
%      SITAKE('Property','Value',...) creates a new SITAKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sitake_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sitake_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sitake

% Last Modified by GUIDE v2.5 05-May-2011 15:28:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sitake_OpeningFcn, ...
                   'gui_OutputFcn',  @sitake_OutputFcn, ...
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


% --- Executes just before sitake is made visible.
function sitake_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sitake (see VARARGIN)

% Choose default command line output for sitake
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes=get(handles.axes1);
    xlabel('E(V/m)');
    ylabel('△E(eV)');

% UIWAIT makes sitake wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sitake_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(sitake);
get(zongpingtai)



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function first_Callback(hObject, eventdata, handles)
% hObject    handle to first (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of first as text
%        str2double(get(hObject,'String')) returns contents of first as a double


% --- Executes during object creation, after setting all properties.
function first_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function second_Callback(hObject, eventdata, handles)
% hObject    handle to second (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of second as text
%        str2double(get(hObject,'String')) returns contents of second as a double


% --- Executes during object creation, after setting all properties.
function second_CreateFcn(hObject, eventdata, handles)
% hObject    handle to second (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function third_Callback(hObject, eventdata, handles)
% hObject    handle to third (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of third as text
%        str2double(get(hObject,'String')) returns contents of third as a double


% --- Executes during object creation, after setting all properties.
function third_CreateFcn(hObject, eventdata, handles)
% hObject    handle to third (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fourth_Callback(hObject, eventdata, handles)
% hObject    handle to fourth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fourth as text
%        str2double(get(hObject,'String')) returns contents of fourth as a double


% --- Executes during object creation, after setting all properties.
function fourth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fourth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fifth_Callback(hObject, eventdata, handles)
% hObject    handle to fifth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fifth as text
%        str2double(get(hObject,'String')) returns contents of fifth as a double


% --- Executes during object creation, after setting all properties.
function fifth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fifth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function n_Callback(hObject, eventdata, handles)
% hObject    handle to n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n as text
%        str2double(get(hObject,'String')) returns contents of n as a double


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


% --- Executes on button press in jisuan.
function jisuan_Callback(hObject, eventdata, handles)
% hObject    handle to jisuan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
global w;
global n;
n = get(handles.n,'String');
n=str2num(n);
set(handles.edit15,'String',num2str(n^2));
global i;
i=0;
global f;
global temp;
a=5.291771e-11;%波尔半径
temp=zeros(20); 
switch n
    case 2
        for m=0:1:n-1
            for l=0:1:n-2                                   %对(6)式进行分解，分为八个部分来计算。
                %第一部分
                part1=-n/2;
                %第二部分
                part2=sqrt(factorial(n-l-1)/(2*n*(factorial(n+l))^3));
                %第三部分
                part3=sqrt(factorial(n-l-2)/(2*n*(factorial(n+l+1))^3));
                %第四部分
                part4=factorial(n+l);
                %第五部分
                part5=factorial(n+l+1);
                %第六部分
                part6=factorial(2*l+4);
                %第七部分
                k=0;
                sum=0;
                sum1=0;
                sum2=0;
                sum3=0;
                while n-l-1-k>=0&n-l-2-k>=0&k>=0
                    if 3-(n-l-1-k)+1<=0
                        sum1=0;
                    else
                        if n-l-1-k==0
                            sum1=1;
                        end
                        if n-l-1-k~=0
                            sum1=factorial(3)/factorial(3-n+l+1+k)/factorial(n-l-1-k);
                        end
                    end
                    if 1-(n-l-2-k)+1<=0
                        sum2=0;
                    else
                        if n-l-2-k~=0
                            sum2=1;
                        end
                        if n-l-2-k==0
                            sum2=1/factorial(n-l-2-k);
                        end
                    end
                    if 2*l+4+1<=0
                        sum3=0;
                    else
                        if k==0
                            sum3=1;
                        end
                        if k~=0
                            sum3=factorial(2*l+4+k)/factorial(2*l+4)/factorial(k);
                        end
                    end
                    sum=sum+sum1*sum2*sum3;
                    k=k+1;
                end
                part7=sum;
                %第八部分               
                part8=sqrt(((l+1)^2-(m)^2)/((2*l+1)*(2*l+3)));
                %**********************************************************
                h=part1*part2*part3*part4*part5*part6*part7*part8;
                temp(i+1)=h;
                i=i+1;
            end
        end
        %计算矩阵元
      
       syms w
        p1=[w,temp(1);temp(1),w];
        p2=[w,temp(2);temp(2),w];
        y=det(p1);
        w1=double(solve(y,w));
        y=det(p2);
        w2=double(solve(y,w));
        w1=w1';
        w2=w2';
        w=[w2(1),w1];
        set(handles.edit10,'String',num2str(w1));
        set(handles.edit11,'String',num2str(w2(1)));
        
        
        t1=[0,temp(1);temp(1),0];
        t2=[0];
        set(handles.first,'String',num2str(t1));
        set(handles.second,'String',num2str(t2));
        
    case 3      
        for m=0:1:n-1
            for l=0:1:n-2
                
                part1=-n/2;
                
                part2=sqrt(factorial(n-l-1)/(2*n*(factorial(n+l))^3));
                
                part3=sqrt(factorial(n-l-2)/(2*n*(factorial(n+l+1))^3));
                
                part4=factorial(n+l);
                
                part5=factorial(n+l+1);
                
                part6=factorial(2*l+4);
                
                k=0;
                sum=0;
                sum1=0;
                sum2=0;
                sum3=0;
                while n-l-1-k>=0&n-l-2-k>=0&k>=0
                    if 3-(n-l-1-k)+1<=0
                        sum1=0;
                    else
                        if n-l-1-k==0
                            sum1=1;
                        end
                        if n-l-1-k~=0
                            sum1=factorial(3)/factorial(3-n+l+1+k)/factorial(n-l-1-k);
                        end
                    end
                    if 1-(n-l-2-k)+1<=0
                        sum2=0;
                    else
                        if n-l-2-k~=0
                            sum2=1;
                        end
                        if n-l-2-k==0
                            sum2=1/factorial(n-l-2-k);
                        end
                    end
                    if 2*l+4+1<=0
                        sum3=0;
                    else
                        if k==0
                            sum3=1;
                        end
                        if k~=0
                            sum3=factorial(2*l+4+k)/factorial(2*l+4)/factorial(k);
                        end
                    end
                    sum=sum+sum1*sum2*sum3;
                    k=k+1;
                end
                part7=sum;
                
                part8=sqrt(((l+1)^2-(m)^2)/((2*l+1)*(2*l+3)));
                
                h=part1*part2*part3*part4*part5*part6*part7*part8;
                temp(i+1)=h;
                i=i+1;
            end
        end
        %计算矩阵元
        syms w
        p3=[w,temp(1),0;temp(1),w,temp(2);0,temp(2),w];
        p2=[w,temp(4);temp(4),w];
        p1=[w,temp(3);temp(3),w];
        y=det(p3);
        w3=double(solve(y,w));
        y=det(p2);
        w2=double(solve(y,w));
        y=det(p1);
        w1=double(solve(y,w));
        w1=w1';
        w2=w2';
        w3=w3';
        w=[w3,w2,w1(1)];
        set(handles.edit10,'String',num2str(w3));
        set(handles.edit11,'String',num2str(w2));
        set(handles.edit12,'String',num2str(w1(1)));
        %计算矩阵元对应的能量本征值
        t3=[0,temp(1),0;temp(1),0,temp(2);0,temp(2),0];
        t2=[0,temp(4);temp(4),0];
        t1=[0];
        set(handles.first,'String',num2str(t3));
        set(handles.second,'String',num2str(t2));
        set(handles.third,'String',num2str(t1));
    case 5    
        for m=0:1:n-1
            for l=0:1:n-2
                
                part1=-n/2;
                
                part2=sqrt(factorial(n-l-1)/(2*n*(factorial(n+l))^3));
                
                part3=sqrt(factorial(n-l-2)/(2*n*(factorial(n+l+1))^3));
                
                part4=factorial(n+l);
                
                part5=factorial(n+l+1);
                
                part6=factorial(2*l+4);

                k=0;
                sum=0;
                sum1=0;
                sum2=0;
                sum3=0;
                while n-l-1-k>=0&n-l-2-k>=0&k>=0
                    if 3-(n-l-1-k)+1<=0
                        sum1=0;
                    else
                        if n-l-1-k==0
                            sum1=1;
                        end
                        if n-l-1-k~=0
                            sum1=factorial(3)/factorial(3-n+l+1+k)/factorial(n-l-1-k);
                        end
                    end
                    if 1-(n-l-2-k)+1<=0
                        sum2=0;
                    else
                        if n-l-2-k~=0
                            sum2=1;
                        end
                        if n-l-2-k==0
                            sum2=1/factorial(n-l-2-k);
                        end
                    end
                    if 2*l+4+1<=0
                        sum3=0;
                    else
                        if k==0
                            sum3=1;
                        end
                        if k~=0
                            sum3=factorial(2*l+4+k)/factorial(2*l+4)/factorial(k);
                        end
                    end
                    sum=sum+sum1*sum2*sum3;
                    k=k+1;
                end
                part7=sum;            
                part8=sqrt(((l+1)^2-(m)^2)/((2*l+1)*(2*l+3)));
                h=part1*part2*part3*part4*part5*part6*part7*part8;
                temp(i+1)=h;
                i=i+1;
            end
        end
        %计算矩阵元
        syms w
        p5=[w,temp(1),0,0,0;temp(1),w,temp(2),0,0;0,temp(2),w,temp(3),0;0,0,temp(3),w,temp(4);0,0,0,temp(4),w];
        p4=[w,temp(6),0,0;temp(6),w,temp(7),0;0,temp(7),w,temp(8);0,0,temp(8),w];
        p3=[w,temp(11),0;temp(11),w,temp(12);0,temp(12),w];
        p2=[w,temp(16);temp(16),w];
        p1=[w,temp(15);temp(15),w];
        y=det(p5);
        w5=double(solve(y,w));
        y=det(p4);
        w4=double(solve(y,w));
        y=det(p3);
        w3=double(solve(y,w));
        y=det(p2);
        w2=double(solve(y,w));
        y=det(p1);
        w1=double(solve(y,w));
        w1=w1';
        w2=w2';
        w3=w3';
        w4=w4';
        w5=w5';
        w=[w5,w4,w3,w2,w1(1)];
        set(handles.edit10,'String',num2str(w5));
         set(handles.edit11,'String',num2str(w4));
        set(handles.edit12,'String',num2str(w3));
        set(handles.edit13,'String',num2str(w2));
        set(handles.edit14,'String',num2str(w1(1)));
        %计算矩阵元对应的能量本征值
        t5=[0,temp(1),0,0,0;temp(1),0,temp(2),0,0;0,temp(2),0,temp(3),0;0,0,temp(3),0,temp(4);0,0,0,temp(4),0];
        t4=[0,temp(6),0,0;temp(6),0,temp(7),0;0,temp(7),0,temp(8);0,0,temp(8),0];
        t3=[0,temp(11),0;temp(11),0,temp(12);0,temp(12),0];
        t2=[0,temp(16);temp(16),0];
        t1=[0];
        set(handles.first,'String',num2str(t5));
        set(handles.second,'String',num2str(t4));
        set(handles.third,'String',num2str(t3));
        set(handles.fourth,'String',num2str(t2));
        set(handles.fifth,'String',num2str(t1));
    case 4    
        for m=0:1:n-1
            for l=0:1:n-2
                part1=-n/2;
                part2=sqrt(factorial(n-l-1)/(2*n*(factorial(n+l))^3));
                part3=sqrt(factorial(n-l-2)/(2*n*(factorial(n+l+1))^3));
                part4=factorial(n+l);
                part5=factorial(n+l+1);
                part6=factorial(2*l+4);
                k=0;
                sum=0;
                sum1=0;
                sum2=0;
                sum3=0;
                while n-l-1-k>=0&n-l-2-k>=0&k>=0
                    if 3-(n-l-1-k)+1<=0
                        sum1=0;
                    else
                        if n-l-1-k==0
                            sum1=1;
                        end
                        if n-l-1-k~=0
                            sum1=factorial(3)/factorial(3-n+l+1+k)/factorial(n-l-1-k);
                        end
                    end
                    if 1-(n-l-2-k)+1<=0
                        sum2=0;
                    else
                        if n-l-2-k~=0
                            sum2=1;
                        end
                        if n-l-2-k==0
                            sum2=1/factorial(n-l-2-k);
                        end
                    end
                    if 2*l+4+1<=0
                        sum3=0;
                    else
                        if k==0
                            sum3=1;
                        end
                        if k~=0
                            sum3=factorial(2*l+4+k)/factorial(2*l+4)/factorial(k);
                        end
                    end
                    sum=sum+sum1*sum2*sum3;
                    k=k+1;
                end
                part7=sum;
               
                part8=sqrt(((l+1)^2-(m)^2)/((2*l+1)*(2*l+3)));
               
                h=part1*part2*part3*part4*part5*part6*part7*part8;
                temp(i+1)=h;
                i=i+1;
            end
        end
        %计算矩阵元
        syms w
        p4=[w,temp(1),0,0;temp(1),w,temp(2),0;0,temp(2),w,temp(3);0,0,temp(3),w];
        p3=[w,temp(5),0;temp(5),w,temp(6);0,temp(6),w];
        p2=[w,temp(9);temp(9),w];
        p1=[w,temp(4);temp(4),w];
        y=det(p4);
        w4=double(solve(y,w));
        y=det(p3);
        w3=double(solve(y,w));
        y=det(p2);
        w2=double(solve(y,w));
        y=det(p1);
        w1=double(solve(y,w));
        w1=w1';
        w2=w2';
        w3=w3';
        w4=w4';
        w=[w4,w3,w2,w1(1)];
         set(handles.edit10,'String',num2str(w4));
        set(handles.edit11,'String',num2str(w3));
        set(handles.edit12,'String',num2str(w2));
        set(handles.edit13,'String',num2str(w1(1)));
        %计算矩阵元对应的能量本征值
        t4=[0,temp(1),0,0;temp(1),0,temp(2),0;0,temp(2),0,temp(3);0,0,temp(3),0];
        t3=[0,temp(5),0;temp(5),0,temp(6);0,temp(6),0];
        t2=[0,temp(9);temp(9),0];
        t1=[0];
        set(handles.first,'String',num2str(t4));
        set(handles.second,'String',num2str(t3));
        set(handles.third,'String',num2str(t2));
        set(handles.fourth,'String',num2str(t1));
        otherwise
        errordlg('n为2、3、4或5','Error');
end
o=numel(w);
p=o;
global r;
r=w;
for i=1:1:p-1
    for j=i+1:1:p
    if r(i)==r(j)
        p=p-1;
        for k=j+1:1:p+1
            r(k-1)=r(k);
        end
        
    end
    end
end
set(handles.edit16,'String',num2str(p));
guidata(hObject, handles);


% --- Executes on button press in zuotu.
function zuotu_Callback(hObject, eventdata, handles)
% hObject    handle to zuotu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
global w;
a=5.291771e-11;
o=numel(w);
x=0:2e6:1e7;
for k=1:1:o            
    y=w(k)*a*x;   
    plot(x,y,'r');
    xlabel('E(V/m)');
    ylabel('△E(eV)');
    title('能级分裂曲线');
    hold on 
    grid on;
end








% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
set(handles.n,'String','');
set(handles.first,'String','');
set(handles.second,'String','');
set(handles.third,'String','');
set(handles.fourth,'String','');
set(handles.fifth,'String','');
set(handles.edit15,'String','');
set(handles.edit16,'String','');
set(handles.edit10,'String','');
set(handles.edit11,'String','');
set(handles.edit12,'String','');
set(handles.edit13,'String','');
set(handles.edit14,'String','');


% --- Executes on button press in qudian.
function qudian_Callback(hObject, eventdata, handles)
% hObject    handle to qudian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode;
