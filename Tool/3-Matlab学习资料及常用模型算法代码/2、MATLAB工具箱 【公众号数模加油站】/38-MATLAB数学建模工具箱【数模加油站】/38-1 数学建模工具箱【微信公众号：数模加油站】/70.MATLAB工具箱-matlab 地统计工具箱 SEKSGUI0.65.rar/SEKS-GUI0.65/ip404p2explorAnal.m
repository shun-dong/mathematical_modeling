function varargout = ip404p2explorAnal(varargin)
%IP404P2EXPLORANAL M-file for ip404p2explorAnal.fig
%      IP404P2EXPLORANAL, by itself, creates a new IP404P2EXPLORANAL or raises the existing
%      singleton*.
%
%      H = IP404P2EXPLORANAL returns the handle to a new IP404P2EXPLORANAL or the handle to
%      the existing singleton*.
%
%      IP404P2EXPLORANAL('Property','Value',...) creates a new IP404P2EXPLORANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip404p2explorAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP404P2EXPLORANAL('CALLBACK') and IP404P2EXPLORANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP404P2EXPLORANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE'sDistEdit Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip404p2explorAnal

% Last Modified by GUIDE v2.5 03-May-2006 10:08:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip404p2explorAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip404p2explorAnal_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before ip404p2explorAnal is made visible.
function ip404p2explorAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip404p2explorAnal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% UIWAIT makes ip404p2explorAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip404p2explorAnal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% PRELIMINARY SETTINGS
%
% Set any known information in the appropriate edit boxes.
% Check and correct any issues with duplicate coordinates in the data provided.
% The updated datasets are passed as global variables from the following
% function. Fill out the remaining boxes with the outcome.
%
global hardDataPresent softDataPresent
global ch zh cs ck ckIn2D totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory softpdftype nl limi probdens softApprox
global displayString
global usingGrid
global zhTemp limiTemp softApproxTemp
global allOkDtr
global zeroInLogScale
global trendDataSaved
global prevExtFigState
global maskKnown prevMaskState
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global minTdata maxTdata dataTimeSpan
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar
global prevAlltState
global cPt cPtValues
global useSoftApproximations
global firstTrendInst lastTrendInst

zhTempDetrended = [];                         % Initialize
softApproxTempDetrended = [];                 % Initialize
limiTempDetrended = [];                       % Initialize
firstTrendInst = [];                          % Initialize. To be set in trend function
lastTrendInst = [];                           % Initialize. To be set in trend function

chAtInst = [];                                % Initialize
zhAtInst = [];                                % Initialize
csAtInst = [];                                % Initialize
nlAtInst = [];                                % Initialize
limiAtInst = [];                              % Initialize
probdensAtInst = [];                          % Initialize
ckAtInst = [];                                % Initialize
zhTempAtInst = [];                            % Initialize
limiTempAtInst = [];                          % Initialize
softApproxTempAtInst = [];                    % Initialize

allOkDtr = 0;       % An indicator to allow user to continue to next stage.
trendDataSaved = 0; % Remains 0 if trend not saved or trend file not present. 

% Represent soft data as single values in exploratory analysis?
% FUTURE DEVELOPER NOTE:
% In future versions of the SeksGUI, there can be a button in this screen for
% the user to decide on this.
% Based on this decision, the mean trend and covariance will be calculated based
% either solely on the hard data or on the additional assistance from sodf data 
% approximations. When no hard data will be present, these tasks will be purely
% undertaken by the soft data approximations.
%
if ~hardDataPresent
  useSoftApproximations = 1;  % Should always be 1 if no hard data are present.
else
  useSoftApproximations = 1;  % Can be left to user choice at a later implementation.
end

if softDataPresent & useSoftApproximations
  % Represent soft data as single values. Use this feature in the calculation
  % of the mean trend. The approximations will not be used in the estimations.
  % 
  % Obtain mean of soft distribution
  [softApprox,dummy] = proba2stat(softpdftype,nl,limi,probdens);
  %if sdCategory==2 | sdCategory==4  % A) Uniform distribution or Interval
  %  for il=1:size(limi,1)           % If interval, obtain midpoint
  %    softApprox(il,1) = (limi(il,2)-limi(il,1))/2 + limi(il,1);
  %  end
  %else                              % B) Any other PDF        
  %  for il=1:size(limi,1)           % If PDF, obtain most probable soft PDF value (mode)
  %    softApprox(il,1) = ...      
  %      limi(il, find(probdens(il,1:nl(il))==max(probdens(il,1:nl(il))),1) );
  %  end
  %end
else
  softApprox = [];   % Proper definition in case of no soft data
end

if useSoftApproximations
    cPt = [ch;cs];               % Provides for in case of no HD, too.
    cPtValues = [zh;softApprox];   
else
    cPt = ch;
    cPtValues = zh;
end

% Break down data based on time reference.
% Cell arrays will hold each temporal instance information in separate cells.
%
if timePresent
  if hardDataPresent
    % For all instances in study find the indices where each appears
    for ith=1:dataTimeSpan     
      indx = find(ch(:,end)==(minTdata+ith-1));
      chAtInst{ith} = ch(indx,1:end-1);  % Create cell array for instance coords
      zhAtInst{ith} = zh(indx,:);        % Create cell array for instance data
    end
  else
    for ith=1:dataTimeSpan     
      chAtInst{ith} = [];
      zhAtInst{ith} = [];
    end
  end
  if softDataPresent
    % For all instances in study find the indices where each appears
    for ith=1:dataTimeSpan   
      indx = find(cs(:,end)==(minTdata+ith-1));
      csAtInst{ith} = cs(indx,1:end-1);  % Create cell array for instance data
      nlAtInst{ith} = nl(indx,:);
      limiAtInst{ith} = limi(indx,:);
      probdensAtInst{ith} = probdens(indx,:);
    end
  else
    for ith=1:dataTimeSpan     
      csAtInst{ith} = [];
      nlAtInst{ith} = [];
      limiAtInst{ith} = [];
      probdensAtInst{ith} = [];
    end
  end
  for ith=1:dataTimeSpan     
    %indx = find(ck(:,end)==(minTdata+ith-1));
    %ckAtInst{ith} = ck(indx,1:end-1);    % Create cell array for instance coords
    ckAtInst{ith} = ckIn2D;               % Obtain grid net at all instances
  end
else             % Account for spatial-only investigations
  if hardDataPresent
    chAtInst{1} = ch;
    zhAtInst{1} = zh;
  else
    chAtInst{1} = [];
    zhAtInst{1} = [];
  end
  if softDataPresent
    csAtInst{1} = cs;
    nlAtInst{1} = nl;
    limiAtInst{1} = limi;
    probdensAtInst{1} = probdens;
  else
    csAtInst{1} = [];
    nlAtInst{1} = [];
    limiAtInst{1} = [];
    probdensAtInst{1} = [];
  end
  ckAtInst{1} = ck;
  set(handles.tInstanceEdit,'Enable','off');
  set(handles.tInstanceSlider,'Enable','off');
end

% Make copies of variables. The copies can be used for transformations later,
% if necessary. Spatial-only version code.
if hardDataPresent        % First, for hard data
  zhTemp = zh;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    indx = find(ch(:,end)==(minTdata+ith-1));
    zhTempAtInst{ith} = zhTemp(indx,:);
  end
else
  zhTemp = [];
  for ith=1:dataTimeSpan     
    zhTempAtInst{ith} = [];
  end
end

if softDataPresent        % Then, for soft data
  limiTemp = limi; 
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    indx = find(cs(:,end)==(minTdata+ith-1));
    limiTempAtInst{ith} = limiTemp(indx,:);
  end
  softApproxTemp = softApprox;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    indx = find(cs(:,end)==(minTdata+ith-1));
    softApproxTempAtInst{ith} = softApproxTemp(indx,:);
  end
else
  limiTemp = [];
  limiTempAtInst{1} = [];
  for ith=1:dataTimeSpan     
    limiTempAtInst{ith} = [];
    softApproxTempAtInst{ith} = [];
  end
end

% Gather all point data into a variable.
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesTemp = [zhTemp;softApproxTemp];
for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    cPtValuesTempAtInst{ith} = [zhTempAtInst{ith} ; softApproxTempAtInst{ith}];
end

displayString = ['Displaying distribution of ' num2str(size(cPtValuesTemp,1)) ' data'];
set(handles.feedbackEdit,'String',displayString);
set(handles.barsMenu,'Value',3);      % Begin by showing histogram w/ 15 bars.
set(handles.graphTypeMenu,'Value',6); % Begin by showing data distribuiton.

axes(handles.dataTrendAxes)
hist(cPtValuesTemp,15);      % Draw the data distr with 15 bars
hFig = findobj(gca,'Type','patch');
set(hFig,'FaceColor','y','EdgeColor','k');
xlabel('Data');
ylabel('Frequency');

% Initialize the maximum data search radius in space
%
% Arbitrarily, in space ask to look into a size of half the largest grid dimension
% Arbitrarily, in time ask to look into at least 2 t-instances
if totalCoordinatesUsed==3  
  if usingGrid
    maxSdataSearchRadius = max( (yMax-yMin)/2, (xMax-xMin)/2 );
  else
    maxSdataSearchRadius = (max(chcs,1)-min(chcs,1))/2;
  end
  if dataTimeSpan>2
    maxTdataSearchRadius = max(2,round((zMax-zMin)/2));
  else
    maxTdataSearchRadius = 2;
  end
elseif totalCoordinatesUsed==2
  if usingGrid
    maxSdataSearchRadius = (xMax-xMin)/2;
  else
    maxSdataSearchRadius = (max(chcs,1)-min(chcs,1))/2;
  end
  if dataTimeSpan>2
    maxTdataSearchRadius = max(2,round((yMax-yMin)/2));
  else
    maxTdataSearchRadius = 2;
  end
else
  errordlg({'ip404p2explorAnal:Preliminary settings:';...
            'There is only provision for 2 and 3 total dimension cases.';... 
            'An updated version is necessary to run a different case.'},... 
            'GUI software Error');
end

% Initialize the parameter for Space/Time metric. This parameter is such, that:
% [ST max distance] = [max spatial distance] + [max temporal distance]*[stMetricPar]
% The parameter has an initial value which may turn out to be small - in this
% case errors will occur at the estimation stage when BMElib may not be able to
% find closest neighbors. In such an event the user is allowed to adjust
% stMetricPar in the estimations screen later. Here, stMetricPar is used to
% obtain an estimate of the trend in the current screen.
if timePresent
  stMetricPar = 0.3;
else
  stMetricPar = [];
end

% Comment out by H-L -- The one might be useful for later numu
% implementation
% set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));  % Initialize
% set(handles.tDistEdit,'String',num2str(maxTdataSearchRadius));  % Initialize

% Initialize the time slider and edit box. Make provisions in case this is a
% spatial-only study: Make time slider and edit box unavailable to the user.
if timePresent
  set(handles.tInstanceSlider,'Value',0);                         % Initialize
  set(handles.tInstanceEdit,'String','All t');                    % Initialize
  set(handles.alltBox,'Value',1);          % Initialize
else
  set(handles.tInstanceSlider,'Value',0);                         % Initialize
  set(handles.tInstanceSlider,'Enable','off');                    % Initialize
  set(handles.tInstanceEdit,'String','');                         % Initialize
  set(handles.tInstanceEdit,'Enable','off');                      % Initialize
  set(handles.alltBox,'Value',1);                                 % Initialize
  set(handles.alltBox,'Enable','off');                            % Initialize
end

prevAlltState = 1;                       % Initialize. Map to show data in all t

set(handles.addMaskBox,'Value',0);       % Initialize
maskKnown = 0;                           % The mask file and its path are unknown 
prevMaskState = 0;                       % Initialize - no mask
prevExtFigState = 0;                     % Initialize - plots in GUI window

% Initial values with the entire data (hard and soft)

set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
if length(cPtValues)~=1
  set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
  set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
else
  set(handles.skewnessNoEdit,'String','N/A');
  set(handles.kurtosisNoEdit,'String','N/A');
end





function feedbackEdit_Callback(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of feedbackEdit as text
%        str2double(get(hObject,'String')) returns contents of feedbackEdit as a double
global displayString
set(handles.feedbackEdit,'String',displayString); 





% --- Executes during object creation, after setting all properties.
function feedbackEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function countNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to countNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of countNoEdit as text
%        str2double(get(hObject,'String')) returns contents of countNoEdit
%        as a double





% --- Executes during object creation, after setting all properties.
function countNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to countNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function minValNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minValNoEdit as text
%        str2double(get(hObject,'String')) returns contents of minValNoEdit as a double





% --- Executes during object creation, after setting all properties.
function minValNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function maxValNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxValNoEdit as text
%        str2double(get(hObject,'String')) returns contents of maxValNoEdit as a double





% --- Executes during object creation, after setting all properties.
function maxValNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function meanNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to meanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of meanNoEdit as text
%        str2double(get(hObject,'String')) returns contents of meanNoEdit as a double





% --- Executes during object creation, after setting all properties.
function meanNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function stDevNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stDevNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stDevNoEdit as text
%        str2double(get(hObject,'String')) returns contents of stDevNoEdit
%        as a double





% --- Executes during object creation, after setting all properties.
function stDevNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stDevNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function medianNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to medianNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of medianNoEdit as text
%        str2double(get(hObject,'String')) returns contents of medianNoEdit
%        as a double





% --- Executes during object creation, after setting all properties.
function medianNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function skewnessNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to skewnessNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skewnessNoEdit as text
%        str2double(get(hObject,'String')) returns contents of skewnessNoEdit as a double





% --- Executes during object creation, after setting all properties.
function skewnessNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skewnessNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function kurtosisNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdFinNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdFinNoEdit as a double


% --- Executes during object creation, after setting all properties.
function kurtosisNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in graphTypeMenu.
function graphTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphTypeMenu
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName

if get(handles.extFigureBox,'Value')  % Separate figure or not?
  axes(handles.dataTrendAxes)
  image(imread('guiResources/ithinkPic.jpg'));
  axis image
  axis off
  figure;
else
  axes(handles.dataTrendAxes)
end

displayString = ['Plotting map. Please wait...'];
set(handles.feedbackEdit,'String',displayString);
pause(0.01);

switch get(handles.graphTypeMenu,'Value')
  case 1     % Displays map of data locations
  	exploratoryAllDataMap(handles);             % Create map
  case 2     % Displays map of hard data locations
  	exploratoryHardDataMap(handles);            % Create map
  case 3     % Displays map of soft data locations
  	exploratorySoftDataMap(handles);            % Create map
  case 4     % Displays markerplots of hard data and soft data approximations
  	exploratoryMarkerPlot(handles);             % Create map
  case 5     % Displays colorplots of hard data and soft data approximations
  	exploratoryColorPlot(handles);              % Create map
  case 6     % Displays non-detrended data distribution
  	exploratoryDataDistrPlot(handles);          % Create map
end





% --- Executes during object creation, after setting all properties.
function graphTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    



% --- Executes on slider movement.
function tInstanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tInstanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global minThard maxThard minTsoft maxTsoft minTdata maxTdata dataTimeSpan
global minTout maxTout outputTimeSpan
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

set(handles.alltBox,'Value',0);  % Adjust alltBox parameters properly, just in case
prevAlltState = 0;

instanceSliderValue = get(handles.tInstanceSlider,'Value');
userSelectedInstance = minTdata + round(instanceSliderValue * (dataTimeSpan-1));
set(handles.tInstanceEdit,'String',num2str(userSelectedInstance));
% displayString = ['Displaying information at t=' num2str(userSelectedInstance)];
% set(handles.feedbackEdit,'String',displayString);    

if get(handles.extFigureBox,'Value')  % Separate figure or not?
  axes(handles.dataTrendAxes)
  image(imread('guiResources/ithinkPic.jpg'));
  axis image
  axis off
  figure;
else
  axes(handles.dataTrendAxes)
end

displayString = ['Plotting map. Please wait...'];
set(handles.feedbackEdit,'String',displayString);
pause(0.01);

switch get(handles.graphTypeMenu,'Value')
  case 1     % Displays map of data locations
  	exploratoryAllDataMap(handles);             % Create map
  case 2     % Displays map of hard data locations
  	exploratoryHardDataMap(handles);            % Create map
  case 3     % Displays map of soft data locations
  	exploratorySoftDataMap(handles);            % Create map
  case 4     % Displays markerplots of hard data and soft data approximations
  	exploratoryMarkerPlot(handles);             % Create map
  case 5     % Displays colorplots of hard data and soft data approximations
  	exploratoryColorPlot(handles);              % Create map
  case 6     % Displays non-detrended data distribution
  	exploratoryDataDistrPlot(handles);          % Create map
end





% --- Executes during object creation, after setting all properties.
function tInstanceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tInstanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





function tInstanceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tInstanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tInstanceEdit as text
%        str2double(get(hObject,'String')) returns contents of tInstanceEdit as a double
global minThard maxThard minTsoft maxTsoft minTdata maxTdata dataTimeSpan
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

inputValue = str2num(get(handles.tInstanceEdit,'String'));

% IF valid entry in edit box
if isempty(inputValue) | ...                     % Reject input if non-numeric,
  mod(inputValue,floor(inputValue)) | ...       % non-integer,
  inputValue<minTdata | inputValue>maxTdata     % or out of allowed values.
  errordlg({['Please enter an integer between '...
          num2str(minTdata) ' and ' num2str(maxTdata) ' for the time instance'];...
          'you would like a map to display.'},... 
          'Invalid input');
else  % If indeed the entry is valid
  
  set(handles.alltBox,'Value',0);  % Adjust alltBox parameters properly, just in case
  prevAlltState = 0;
  instanceSliderValue = (inputValue-minTdata)/(dataTimeSpan-1);
  set(handles.tInstanceSlider,'Value',instanceSliderValue);

  if get(handles.extFigureBox,'Value')  % Separate figure or not?
    axes(handles.dataTrendAxes)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    figure;
  else
    axes(handles.dataTrendAxes)
  end

  displayString = ['Plotting map. Please wait...'];
  set(handles.feedbackEdit,'String',displayString);
  pause(0.01);

  switch get(handles.graphTypeMenu,'Value')
    case 1     % Displays map of data locations
      exploratoryAllDataMap(handles);             % Create map
    case 2     % Displays map of hard data locations
      exploratoryHardDataMap(handles);            % Create map
    case 3     % Displays map of soft data locations
      exploratorySoftDataMap(handles);            % Create map
    case 4     % Displays markerplots of hard data and soft data approximations
      exploratoryMarkerPlot(handles);             % Create map
    case 5     % Displays colorplots of hard data and soft data approximations
      exploratoryColorPlot(handles);              % Create map
    case 6     % Displays non-detrended data distribution
      exploratoryDataDistrPlot(handles);          % Create map
  end

end



   

% --- Executes during object creation, after setting all properties.
function tInstanceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tInstanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in alltBox.
function alltBox_Callback(hObject, eventdata, handles)
% hObject    handle to alltBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alltBox
global prevAlltState
global minTdata maxTdata dataTimeSpan

if ~prevAlltState

  set(handles.alltBox,'Value',1);
  prevAlltState = 1;
  displayString = 'Eligible plots will portray t-aggregated maps';
  set(handles.feedbackEdit,'String',displayString); 
  set(handles.tInstanceSlider,'Value',0);                 % Adjust t-slider 
  set(handles.tInstanceEdit,'String','All t');            % Adjust t-edit
        
else

  set(handles.alltBox,'Value',0);
  prevAlltState = 0;
  displayString = 'De-activated t-aggregated maps';
  set(handles.feedbackEdit,'String',displayString);  
  set(handles.tInstanceSlider,'Value',0);                 % Adjust t-slider 
  set(handles.tInstanceEdit,'String',num2str(minTdata));  % Adjust t-edit

end    







% --- Executes on selection change in barsMenu.
function barsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to barsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns barsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from barsMenu
global zhTemp limiTemp softApproxTemp
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global firstTrendInst lastTrendInst

if get(handles.extFigureBox,'Value') & ...
      ( get(handles.graphTypeMenu,'Value')==6) % Separate figure or not?
  axes(handles.dataTrendAxes)
  image(imread('guiResources/ithinkPic.jpg'));
  axis image
  axis off
  figure;
else
  axes(handles.dataTrendAxes)
  displayString = ['Bars handle has no effect on selected map type'];
  set(handles.feedbackEdit,'String',displayString);
end

displayString = ['Plotting map. Please wait...'];
set(handles.feedbackEdit,'String',displayString);
pause(0.01);

switch get(handles.graphTypeMenu,'Value')
  case 6     % Displays non-detrended data distribution
    exploratoryDataDistrPlot(handles);          % Create map
end





% --- Executes during object creation, after setting all properties.
function barsMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to barsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in extFigureBox.
function extFigureBox_Callback(hObject, eventdata, handles)
% hObject    handle to extFigureBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extFigureBox
global prevExtFigState

if ~prevExtFigState
   
  set(handles.extFigureBox,'Value',1);
  prevExtFigState = 1;
  displayString = 'Plots to follow in separate windows';
  set(handles.feedbackEdit,'String',displayString);
        
else

  set(handles.extFigureBox,'Value',0);
  prevExtFigState = 0;
  displayString = 'Plots to follow in this window';
  set(handles.feedbackEdit,'String',displayString);  

end    




% --- Executes on button press in addMaskBox.
function addMaskBox_Callback(hObject, eventdata, handles)
% hObject    handle to addMaskBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
global displayString
global maskFilename maskPathname maskKnown
global prevMaskState

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
if ~prevMaskState
   
  if maskKnown
    set(handles.addMaskBox,'Value',1);
    prevMaskState = 1;
    displayString = 'Map mask will now be applied in plots to follow';
    set(handles.feedbackEdit,'String',displayString);     
  else                    % Prompt the user to find the file with map mask info
    initialDir = pwd;     % Save the current directory path
    [maskFilename,maskPathname] = uigetfile('*.m','Select masking M-file');
    if isequal([maskFilename,maskPathname],[0,0])  % If 'Cancel' selected
      cd (initialDir)     % Finally, return to where this function was evoked from
      displayString = 'Map masking cancelled';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.addMaskBox,'Value',0);
    else
      cd (initialDir)     % Finally, return to where this function was evoked from
      set(handles.addMaskBox,'Value',1);
      prevMaskState = 1;
      displayString = 'Map mask will now be applied in plots to follow';
      set(handles.feedbackEdit,'String',displayString);     
      maskKnown = 1;   
    end
  end     
else
  set(handles.addMaskBox,'Value',0);
  prevMaskState = 0;
  displayString = 'Map mask to be removed from plots to follow';
  set(handles.feedbackEdit,'String',displayString);  
end    





% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ip201helpMain('Title','BMElib Help');





% --- Executes on button press in mainButton.
function mainButton_Callback(hObject, eventdata, handles)
% hObject    handle to mainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = ip102back2mainDialog('Title','Confirm Action');
switch lower(user_response)
  case 'no'
    % take no action
  case 'yes'
    delete(handles.figure1);
    clear; clear all; clear memory;
    ip002chooseTask('Title','Choose a Task');
end





% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);                            % Close current window...
ip304p1explorAnal('Title','Exploratory Analysis');  % ...and procede to the previous unit.





% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);                                % Close current window...
ip406estimationsWiz('Title','GBME Estimations Wizard'); % ...and procede to following screen.





function exploratoryAllDataMap(handles)
%
% Plot map of hard and soft data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

if totalSpCoordinatesUsed==2 
      
  hdPopulation = 0;       % Initialize
  sdPopulation = 0;       % Initialize
  if get(handles.alltBox,'Value')        % If we want a t-aggregated map
    if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
      if hardDataPresent
        h1 = plot(ch(:,1),ch(:,2),'b.');
        hdPopulation = size(ch,1);
        legendhOk = 1;
        hold on;
      else
        legendhOk = 0;
      end
      if softDataPresent
        h2 = plot(cs(:,1),cs(:,2),'r.');
        sdPopulation = size(cs,1);
        legendsOk = 1;
        hold on;
      else
        legendsOk = 0;
      end
    else                                   % If using an external figure
      if hardDataPresent
        h1 = plot(ch(:,1),ch(:,2),'bv');
        hdPopulation = size(ch,1);
        legendhOk = 1;
        hold on;
      else
        legendhOk = 0;
      end
      if softDataPresent
        h2 = plot(cs(:,1),cs(:,2),'ro');
        sdPopulation = size(cs,1);
        legendsOk = 1;
        hold on;
      else
        legendsOk = 0;
      end
    end
    cPtValues=[zhTemp;softApproxTemp];
    set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
    set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
    set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
    set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
    set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
    set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
    if length(cPtValues)~=1
      set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
      set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
    else
      set(handles.skewnessNoEdit,'String','N/A');
      set(handles.kurtosisNoEdit,'String','N/A');
    end
    clear cPtValues;
  else                   % If we want a map at instance t
    tNowActual = str2num(get(handles.tInstanceEdit,'String'));
    tNowData = tNowActual-minTdata+1;
    if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
      if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
        h1 = plot(chAtInst{tNowData}(:,1),chAtInst{tNowData}(:,2),'b.');
        hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
        legendhOk = 1;
        hold on;
      else
        legendhOk = 0;
      end
      if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
        h2 = plot(csAtInst{tNowData}(:,1),csAtInst{tNowData}(:,2),'r.');
        sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
        legendsOk = 1;
        hold on;
      else
        legendsOk = 0;
      end
      zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
      set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
      set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
      set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
      set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
      set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
      set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
      if length(zallAtInst)>1
        set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
        set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
      else                     % If only 1 or 0 data at this instance
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');
      end
      clear zallAtInst;
    else                                   % If using an external figure
      if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
        h1 = plot(chAtInst{tNowData}(:,1),chAtInst{tNowData}(:,2),'bv');
        hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
        legendhOk = 1;
        hold on;
      else
        legendhOk = 0;
      end
      if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
        h2 = plot(csAtInst{tNowData}(:,1),csAtInst{tNowData}(:,2),'ro');
        sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
        legendsOk = 1;
        hold on;
      else
        legendsOk = 0;
      end
      zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
      set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
      set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
      set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
      set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
      set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
      set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
      if length(zallAtInst)>1
        set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
        set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
      else                     % If only 1 or 0 data at this instance
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');
      end
      clear zallAtInst;
    end
  end
      
  hold off;
  axis image;
  if usingGrid
    axis([xMin xMax yMin yMax]);
  end
  xlabel('x-Axis');
  ylabel('y-Axis');
  if get(handles.addMaskBox,'Value')==1
    % Mask adding code. Will execute if masking option is on.
    initialDir = pwd;               % Save the current directory path
    cd (maskPathname);              % Go where the masking file resides
    % Remove the ending ".m" from the filename and execute the contents
    eval(regexprep(maskFilename,'.m',''));
    cd (initialDir)                 % Return to initial directory
  end
  if legendhOk | legendsOk
    displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' data on the map'];
    set(handles.feedbackEdit,'String',displayString);
    if legendhOk & legendsOk
      legend([h1 h2],'Hard Data','Soft Data');
    elseif legendhOk & ~legendsOk
      legend([h1],'Hard Data');
    elseif ~legendhOk & legendsOk
      legend([h2],'Soft Data');
    end
  else
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    displayString = 'Data not available for this map';
    set(handles.feedbackEdit,'String',displayString);
    set(handles.countNoEdit,'String','0');
    set(handles.minValNoEdit,'String','N/A');
    set(handles.maxValNoEdit,'String','N/A');
    set(handles.meanNoEdit,'String','N/A');
    set(handles.stDevNoEdit,'String','N/A');
    set(handles.medianNoEdit,'String','N/A');
    set(handles.skewnessNoEdit,'String','N/A');
    set(handles.kurtosisNoEdit,'String','N/A');
  end
else
  storedString = get(handles.feedbackEdit,'String');
  set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
  pause(2);
  set(handles.feedbackEdit,'String',storedString);
end





function exploratoryHardDataMap(handles)
%
% Plot map of hard data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

if hardDataPresent
  if totalSpCoordinatesUsed==2
 
    hdPopulation = 0;       % Initialize
    if get(handles.alltBox,'Value')        % If we want a t-aggregated map
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        h1 = plot(ch(:,1),ch(:,2),'b.');
        hdPopulation = size(ch,1);
        legendOk = 1;
      else                                   % If using an external figure
        h1 = plot(ch(:,1),ch(:,2),'bv');
        hdPopulation = size(ch,1);
        legendOk = 1;
      end
      set(handles.countNoEdit,'String',num2str(size(zhTemp,1)));
      set(handles.minValNoEdit,'String',num2str(min(zhTemp)));
      set(handles.maxValNoEdit,'String',num2str(max(zhTemp)));
      set(handles.meanNoEdit,'String',num2str(mean(zhTemp)));
      set(handles.stDevNoEdit,'String',num2str(std(zhTemp)));
      set(handles.medianNoEdit,'String',num2str(median(zhTemp)));
      if length(zhTemp)~=1
        set(handles.skewnessNoEdit,'String',num2str(skewness(zhTemp)));
        set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zhTemp)));
      else
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');
      end
    else                   % If we want a map at instance t
      tNowActual = str2num(get(handles.tInstanceEdit,'String'));
      tNowData = tNowActual-minTdata+1;
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if ~isempty(chAtInst{tNowData})                      % Are there HD now?
          h1 = plot(chAtInst{tNowData}(:,1),chAtInst{tNowData}(:,2),'b.');
          hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
          legendOk = 1;
          set(handles.countNoEdit,'String',num2str(size(zhTempAtInst{tNowData},1)));
          set(handles.minValNoEdit,'String',num2str(min(zhTempAtInst{tNowData})));
          set(handles.maxValNoEdit,'String',num2str(max(zhTempAtInst{tNowData})));
          set(handles.meanNoEdit,'String',num2str(mean(zhTempAtInst{tNowData})));
          set(handles.stDevNoEdit,'String',num2str(std(zhTempAtInst{tNowData})));
          set(handles.medianNoEdit,'String',num2str(median(zhTempAtInst{tNowData})));
          if size(zhTempAtInst{tNowData},1)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(zhTempAtInst{tNowData})));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zhTempAtInst{tNowData})));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
        else
          legendOk = 0;
        end
      else                                   % If using an external figure
        if ~isempty(chAtInst{tNowData})                      % Are there HD now?
          h1 = plot(chAtInst{tNowData}(:,1),chAtInst{tNowData}(:,2),'bv');
          hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
          legendOk = 1;
          set(handles.countNoEdit,'String',num2str(size(zhTempAtInst{tNowData},1)));
          set(handles.minValNoEdit,'String',num2str(min(zhTempAtInst{tNowData})));
          set(handles.maxValNoEdit,'String',num2str(max(zhTempAtInst{tNowData})));
          set(handles.meanNoEdit,'String',num2str(mean(zhTempAtInst{tNowData})));
          set(handles.stDevNoEdit,'String',num2str(std(zhTempAtInst{tNowData})));
          set(handles.medianNoEdit,'String',num2str(median(zhTempAtInst{tNowData})));
          if size(zhTempAtInst{tNowData},1)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(zhTempAtInst{tNowData})));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zhTempAtInst{tNowData})));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
        else
          legendOk = 0;
        end
      end
    end
      
    hold off;
    axis image;
    if usingGrid
      axis([xMin xMax yMin yMax]);
    end
    xlabel('x-Axis');
    ylabel('y-Axis');
    if get(handles.addMaskBox,'Value')==1
      % Mask adding code. Will execute if masking option is on.
      initialDir = pwd;               % Save the current directory path
      cd (maskPathname);              % Go where the masking file resides
      % Remove the ending ".m" from the filename and execute the contents
      eval(regexprep(maskFilename,'.m',''));
      cd (initialDir)                 % Return to initial directory
    end
    if legendOk
      displayString = ['Showing ' num2str(hdPopulation) ' hard data on the map'];
      set(handles.feedbackEdit,'String',displayString);
      legend([h1],'Hard Data');
    else
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
      displayString = 'Data not available for this map';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.countNoEdit,'String','0');
      set(handles.minValNoEdit,'String','N/A');
      set(handles.maxValNoEdit,'String','N/A');
      set(handles.meanNoEdit,'String','N/A');
      set(handles.stDevNoEdit,'String','N/A');
      set(handles.medianNoEdit,'String','N/A');
      set(handles.skewnessNoEdit,'String','N/A');
      set(handles.kurtosisNoEdit,'String','N/A');                    
    end
  else
    storedString = get(handles.feedbackEdit,'String');
    set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
    pause(2);
    set(handles.feedbackEdit,'String',storedString);
  end
else
  displayString = 'Can not plot map: No hard data present';
  set(handles.feedbackEdit,'String',displayString);
  set(handles.countNoEdit,'String','0');
  set(handles.minValNoEdit,'String','N/A');
  set(handles.maxValNoEdit,'String','N/A');
  set(handles.meanNoEdit,'String','N/A');
  set(handles.stDevNoEdit,'String','N/A');
  set(handles.medianNoEdit,'String','N/A');
  set(handles.skewnessNoEdit,'String','N/A');
  set(handles.kurtosisNoEdit,'String','N/A');                    
end





function exploratorySoftDataMap(handles)
%
% Plot map of soft data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

if softDataPresent
  if totalSpCoordinatesUsed==2
   
    sdPopulation = 0;       % Initialize
    if get(handles.alltBox,'Value')        % If we want a t-aggregated map
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        h2 = plot(cs(:,1),cs(:,2),'r.');
        sdPopulation = size(cs,1);
        legendOk = 1;
      else                                   % If using an external figure
        h2 = plot(cs(:,1),cs(:,2),'ro');
        sdPopulation = size(cs,1);
        legendOk = 1;
      end
      set(handles.countNoEdit,'String',num2str(size(softApproxTemp,1)));
      set(handles.minValNoEdit,'String',num2str(min(softApproxTemp)));
      set(handles.maxValNoEdit,'String',num2str(max(softApproxTemp)));
      set(handles.meanNoEdit,'String',num2str(mean(softApproxTemp)));
      set(handles.stDevNoEdit,'String',num2str(std(softApproxTemp)));
      set(handles.medianNoEdit,'String',num2str(median(softApproxTemp)));
      if size(softApproxTemp,1)~=1
        set(handles.skewnessNoEdit,'String',num2str(skewness(softApproxTemp)));
        set(handles.kurtosisNoEdit,'String',num2str(kurtosis(softApproxTemp)));
      else
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');
      end
    else                   % If we want a map at instance t
      tNowActual = str2num(get(handles.tInstanceEdit,'String'));
      tNowData = tNowActual-minTdata+1;
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if ~isempty(csAtInst{tNowData})                      % Are there SD now?
          h2 = plot(csAtInst{tNowData}(:,1),csAtInst{tNowData}(:,2),'r.');
          sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
          legendOk = 1;
          set(handles.countNoEdit,'String',num2str(size(softApproxTempAtInst{tNowData},1)));
          set(handles.minValNoEdit,'String',num2str(min(softApproxTempAtInst{tNowData})));
          set(handles.maxValNoEdit,'String',num2str(max(softApproxTempAtInst{tNowData})));
          set(handles.meanNoEdit,'String',num2str(mean(softApproxTempAtInst{tNowData})));
          set(handles.stDevNoEdit,'String',num2str(std(softApproxTempAtInst{tNowData})));
          set(handles.medianNoEdit,'String',num2str(median(softApproxTempAtInst{tNowData})));
          if size(softApproxTempAtInst{tNowData},1)~=1
            set(handles.skewnessNoEdit,'String',...
              num2str(skewness(softApproxTempAtInst{tNowData})));
            set(handles.kurtosisNoEdit,'String',...
              num2str(kurtosis(softApproxTempAtInst{tNowData})));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
        else
          legendOk = 0;
        end
      else                                   % If using an external figure
        if ~isempty(csAtInst{tNowData})                      % Are there SD now?
          h2 = plot(csAtInst{tNowData}(:,1),csAtInst{tNowData}(:,2),'ro');
          sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
          legendOk = 1;
          set(handles.countNoEdit,'String',num2str(size(softApproxTempAtInst{tNowData},1)));
          set(handles.minValNoEdit,'String',num2str(min(softApproxTempAtInst{tNowData})));
          set(handles.maxValNoEdit,'String',num2str(max(softApproxTempAtInst{tNowData})));
          set(handles.meanNoEdit,'String',num2str(mean(softApproxTempAtInst{tNowData})));
          set(handles.stDevNoEdit,'String',num2str(std(softApproxTempAtInst{tNowData})));
          set(handles.medianNoEdit,'String',num2str(median(softApproxTempAtInst{tNowData})));
          if size(softApproxTempAtInst{tNowData},1)~=1
            set(handles.skewnessNoEdit,'String',...
              num2str(skewness(softApproxTempAtInst{tNowData})));
            set(handles.kurtosisNoEdit,'String',...
              num2str(kurtosis(softApproxTempAtInst{tNowData})));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
        else
          legendOk = 0;
        end
      end
    end

    hold off;
    axis image;
    if usingGrid
      axis([xMin xMax yMin yMax]);
    end
    xlabel('x-Axis');
    ylabel('y-Axis');
    if get(handles.addMaskBox,'Value')==1
      % Mask adding code. Will execute if masking option is on.
      initialDir = pwd;               % Save the current directory path
      cd (maskPathname);              % Go where the masking file resides
      % Remove the ending ".m" from the filename and execute the contents
      eval(regexprep(maskFilename,'.m',''));
      cd (initialDir)                 % Return to initial directory
    end
    if legendOk
      displayString = ['Showing ' num2str(sdPopulation) ' soft data on the map'];
      set(handles.feedbackEdit,'String',displayString);
      legend([h2],'Soft Data');
    else
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
      displayString = 'Data not available for this map';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.countNoEdit,'String',num2str(0));
      set(handles.minValNoEdit,'String','N/A');
      set(handles.maxValNoEdit,'String','N/A');
      set(handles.meanNoEdit,'String','N/A');
      set(handles.stDevNoEdit,'String','N/A');
      set(handles.medianNoEdit,'String','N/A');
      set(handles.skewnessNoEdit,'String','N/A');
      set(handles.kurtosisNoEdit,'String','N/A');                    
    end
  else
    storedString = get(handles.feedbackEdit,'String');
    set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
    pause(2);
    set(handles.feedbackEdit,'String',storedString);
  end
else
  displayString = 'Can not plot map: No soft data present';
  set(handles.feedbackEdit,'String',displayString);
  set(handles.countNoEdit,'String','0');
  set(handles.minValNoEdit,'String','N/A');
  set(handles.maxValNoEdit,'String','N/A');
  set(handles.meanNoEdit,'String','N/A');
  set(handles.stDevNoEdit,'String','N/A');
  set(handles.medianNoEdit,'String','N/A');
  set(handles.skewnessNoEdit,'String','N/A');
  set(handles.kurtosisNoEdit,'String','N/A');                    
end





function exploratoryMarkerPlot(handles)
%
% Plot markerplot of data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

if totalSpCoordinatesUsed==2 
     
  hdPopulation = 0;       % Initialize
  sdPopulation = 0;       % Initialize

  totalPopulation = size(ch,1) + size(cs,1);
  if totalPopulation>1    % Markerplots can not be created w/ only 1 point
     
    if prevAlltState        % If we want a t-aggregated map
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if hardDataPresent
          markerplot(ch(:,1:2),zhTemp,[4 30],'MarkerEdgeColor','blue');
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          markerplot(cs(:,1:2),softApproxTemp,[4 30],'MarkerEdgeColor','red');
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
        if legendhOk | legendsOk
          cPtValues=[zhTemp;softApproxTemp];
          set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
          set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
          set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
          set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
          set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
          set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
          if length(cPtValues)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
          clear cPtValues;
        end
      else                                   % If using an external figure
        if hardDataPresent
          markerplot(ch(:,1:2),zhTemp,[4 30],'MarkerEdgeColor','blue');
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          markerplot(cs(:,1:2),softApproxTemp,[4 30],'MarkerEdgeColor','red');
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
        if legendhOk | legendsOk
          cPtValues=[zhTemp;softApproxTemp];
          set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
          set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
          set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
          set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
          set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
          set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
          if length(cPtValues)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
          clear cPtValues;
        end
      end
      markerPlotOk = 1;
         
    else                   % If we want a map at instance t
      tNowActual = str2num(get(handles.tInstanceEdit,'String'));
      tNowData = tNowActual-minTdata+1;

      totalPopulationAtInst = ...
        size(chAtInst{tNowData}) + size(softApproxTempAtInst{tNowData});
      if totalPopulationAtInst>1    % Markerplots can not be created w/ only 1 point         

        if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
          if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
            markerplot(chAtInst{tNowData}(:,1:2),zhTempAtInst{tNowData},[4 30],...
                                            'MarkerEdgeColor','blue');
            hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
            markerplot(csAtInst{tNowData}(:,1:2),softApproxTempAtInst{tNowData},[4 30],...
                                             'MarkerEdgeColor','red');
            sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
          if legendhOk | legendsOk
            zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
            set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
            set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
            set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
            set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
            set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
            set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
            if length(zallAtInst)~=1
              set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
              set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
            else
              set(handles.skewnessNoEdit,'String','N/A');
              set(handles.kurtosisNoEdit,'String','N/A');
            end
            clear zallAtInst;
          end
        else                                   % If using an external figure
          if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
            markerplot(chAtInst{tNowData}(:,1:2),zhTempAtInst{tNowData},[4 30],...
                                             'MarkerEdgeColor','blue');
            hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
         if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
            markerplot(csAtInst{tNowData}(:,1:2),softApproxTempAtInst{tNowData},[4 30],...
                                             'MarkerEdgeColor','red');
            sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
          if legendhOk | legendsOk
            zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
            set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
            set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
            set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
            set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
            set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
            set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
            if length(zallAtInst)~=1
              set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
              set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
            else
              set(handles.skewnessNoEdit,'String','N/A');
              set(handles.kurtosisNoEdit,'String','N/A');
            end
            clear zallAtInst;
          end
        end
           
        markerPlotOk = 1;
      else
        displayString = ['Can not create markerplot with fewer than 2 data'];
        set(handles.feedbackEdit,'String',displayString);
        markerPlotOk = 0;
        zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
        if isempty(zallAtInst)   % 0 data at this instance
          set(handles.countNoEdit,'String','0');
          set(handles.minValNoEdit,'String','N/A');
          set(handles.maxValNoEdit,'String','N/A');
          set(handles.meanNoEdit,'String','N/A');
          set(handles.stDevNoEdit,'String','N/A');
          set(handles.medianNoEdit,'String','N/A');
          set(handles.skewnessNoEdit,'String','N/A');
          set(handles.kurtosisNoEdit,'String','N/A');                    
        else                     % 1 datum at this instance
          set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
          set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
          set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
          set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
          set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
          set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
          set(handles.skewnessNoEdit,'String','N/A');
          set(handles.kurtosisNoEdit,'String','N/A');
        end
        clear zallAtInst;
      end  % If totalPopulationAtInst>1
          
    end

    if markerPlotOk
      hold off;
      axis image;
      if usingGrid
        axis([xMin xMax yMin yMax]);
      end
      xlabel('x-Axis');
      ylabel('y-Axis');
      if get(handles.addMaskBox,'Value')==1
        % Mask adding code. Will execute if masking option is on.
        initialDir = pwd;               % Save the current directory path
        cd (maskPathname);              % Go where the masking file resides
        % Remove the ending ".m" from the filename and execute the contents
        eval(regexprep(maskFilename,'.m',''));
        cd (initialDir)                 % Return to initial directory
      end
      if legendhOk | legendsOk
        displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' markers on the map'];
        set(handles.feedbackEdit,'String',displayString);
      else
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
        set(handles.countNoEdit,'String','0');
        set(handles.minValNoEdit,'String','N/A');
        set(handles.maxValNoEdit,'String','N/A');
        set(handles.meanNoEdit,'String','N/A');
        set(handles.stDevNoEdit,'String','N/A');
        set(handles.medianNoEdit,'String','N/A');
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');                    
      end
    end % If markerPlotOk
      
  else
    displayString = ['Can not create markerplot with fewer than 2 data'];
    set(handles.feedbackEdit,'String',displayString);
  end   % If totalPopulation>1
              
else
  storedString = get(handles.feedbackEdit,'String');
  set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
  pause(2);
  set(handles.feedbackEdit,'String',storedString);
end





function exploratoryColorPlot(handles)
%
% Plot colorplot of data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

hotrev = hot;
hotrev = hotrev(end:-1:1,:);  % Change order in hot colormap
if totalSpCoordinatesUsed==2 
     
  totalPopulation = size(ch,1) + size(cs,1);
  if totalPopulation>1    % Colorplots can not be created w/ only 1 point
    
    hdPopulation = 0;       % Initialize
    sdPopulation = 0;       % Initialize
    if prevAlltState        % If we want a t-aggregated map
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if hardDataPresent
          colorplot(ch(:,1:2),zhTemp,hotrev,'MarkerSize',7); colorbar;
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          colorplot(cs(:,1:2),softApproxTemp,hotrev,'MarkerSize',7); colorbar;
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
        if legendhOk | legendsOk
          cPtValues=[zhTemp;softApproxTemp];
          set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
          set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
          set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
          set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
          set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
          set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
          if length(cPtValues)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
          clear cPtValues;
        end
      else                                   % If using an external figure
        if hardDataPresent
          colorplot(ch(:,1:2),zhTemp,hotrev); colorbar;
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          colorplot(cs(:,1:2),softApproxTemp,hotrev); colorbar;
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
        if legendhOk | legendsOk
          cPtValues=[zhTemp;softApproxTemp];
          set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
          set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
          set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
          set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
          set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
          set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
          if length(cPtValues)~=1
            set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
            set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
          else
            set(handles.skewnessNoEdit,'String','N/A');
            set(handles.kurtosisNoEdit,'String','N/A');
          end
          clear cPtValues;
        end
      end
      colorPlotOk = 1;
         
    else                   % If we want a map at instance t
      tNowActual = str2num(get(handles.tInstanceEdit,'String'));
      tNowData = tNowActual-minTdata+1;
         
      totalPopulationAtInst = ...
        size(chAtInst{tNowData}) + size(softApproxTempAtInst{tNowData});
      if totalPopulationAtInst>1    % Colorplots can not be created w/ only 1 point
         
        if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
          if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
            colorplot(chAtInst{tNowData}(:,1:2),zhTempAtInst{tNowData},hotrev,...
                                            'MarkerSize',7);
            colorbar;
            hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
            colorplot(csAtInst{tNowData}(:,1:2),softApproxTempAtInst{tNowData},hotrev,...
                                             'MarkerSize',7);
            colorbar;
            sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
          if legendhOk | legendsOk
            zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
            set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
            set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
            set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
            set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
            set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
            set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
            if length(zallAtInst)~=1
              set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
              set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
            else
              set(handles.skewnessNoEdit,'String','N/A');
              set(handles.kurtosisNoEdit,'String','N/A');
            end
            clear zallAtInst;
          end
        else                                   % If using an external figure
          if hardDataPresent & ~isempty(chAtInst{tNowData})      % Are there HD now?
            colorplot(chAtInst{tNowData}(:,1:2),zhTempAtInst{tNowData},hotrev);
            colorbar;
            hdPopulation = size(chAtInst{tNowData},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent & ~isempty(csAtInst{tNowData})      % Are there SD now?
            colorplot(csAtInst{tNowData}(:,1:2),softApproxTempAtInst{tNowData},hotrev);
            colorbar;
            sdPopulation = size(csAtInst{tNowData},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
          if legendhOk | legendsOk
            zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
            set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
            set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
            set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
            set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
            set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
            set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
            if length(zallAtInst)~=1
              set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
              set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
            else
              set(handles.skewnessNoEdit,'String','N/A');
              set(handles.kurtosisNoEdit,'String','N/A');
            end
            clear zallAtInst;
          end
        end
           
        colorPlotOk = 1;
      else
        displayString = ['Can not create colorplot with fewer than 2 data'];
        set(handles.feedbackEdit,'String',displayString);
        colorPlotOk = 0;
        zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
        if isempty(zallAtInst)   % 0 data at this instance
          set(handles.countNoEdit,'String','0');
          set(handles.minValNoEdit,'String','N/A');
          set(handles.maxValNoEdit,'String','N/A');
          set(handles.meanNoEdit,'String','N/A');
          set(handles.stDevNoEdit,'String','N/A');
          set(handles.medianNoEdit,'String','N/A');
          set(handles.skewnessNoEdit,'String','N/A');
          set(handles.kurtosisNoEdit,'String','N/A');                    
        else                     % 1 datum at this instance
          set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
          set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
          set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
          set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
          set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
          set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
          set(handles.skewnessNoEdit,'String','N/A');
          set(handles.kurtosisNoEdit,'String','N/A');
        end
        clear zallAtInst;
      end  % If totalPopulationAtInst>1
       
    end

    if colorPlotOk
      hold off;
      axis image;
      if usingGrid
        axis([xMin xMax yMin yMax]);
      end
      xlabel('x-Axis');
      ylabel('y-Axis');
      if get(handles.addMaskBox,'Value')==1
        % Mask adding code. Will execute if masking option is on.
        initialDir = pwd;               % Save the current directory path
        cd (maskPathname);              % Go where the masking file resides
        % Remove the ending ".m" from the filename and execute the contents
        eval(regexprep(maskFilename,'.m',''));
        cd (initialDir)                 % Return to initial directory
      end
      if legendhOk | legendsOk
        displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' data on the map'];
        set(handles.feedbackEdit,'String',displayString);
      else
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
        set(handles.countNoEdit,'String','0');
        set(handles.minValNoEdit,'String','N/A');
        set(handles.maxValNoEdit,'String','N/A');
        set(handles.meanNoEdit,'String','N/A');
        set(handles.stDevNoEdit,'String','N/A');
        set(handles.medianNoEdit,'String','N/A');
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');                    
      end
    end % If colorPlotOk
       
  else
    displayString = ['Can not create colorplot with fewer than 2 data'];
    set(handles.feedbackEdit,'String',displayString);
  end   % If totalPopulation>1
        
else
  storedString = get(handles.feedbackEdit,'String');
  set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
  pause(2);
  set(handles.feedbackEdit,'String',storedString);
end





function exploratoryDataDistrPlot(handles)
%
% Plot distribution of data, either at all instances or selected ones.
%
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global minTout maxTout outputTimeSpan
global minTdata maxTdata dataTimeSpan
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

barsOptions = get(handles.barsMenu,'String');
indexChoice = get(handles.barsMenu,'Value');
selectedBars = str2num(barsOptions{indexChoice});

dataPopulation = 0;
if get(handles.alltBox,'Value')        % If we want a t-aggregated map
  cPtValuesTemp = [zhTemp;softApproxTemp];
  dataPopulation = size(cPtValuesTemp,1);
  hist(cPtValuesTemp,selectedBars);
  hFig = findobj(gca,'Type','patch');
  set(hFig,'FaceColor','y','EdgeColor','k');
  figureOk = 1;
  cPtValues=[zhTemp;softApproxTemp];
  set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
  set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
  set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
  set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
  set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
  set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
  if length(cPtValues)~=1
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
  else
    set(handles.skewnessNoEdit,'String','N/A');
    set(handles.kurtosisNoEdit,'String','N/A');
  end
  clear cPtValues;
else                    % If we want a map at instance t
  tNowActual = str2num(get(handles.tInstanceEdit,'String'));
  tNowData = tNowActual-minTdata+1;
  if ~isempty(zhTempAtInst{tNowData}) | ~isempty(softApproxTempAtInst{tNowData})
    cPtValuesTempAtInst{tNowData} = ...
      [zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
    dataPopulation = size(cPtValuesTempAtInst{tNowData},1);
    hist(cPtValuesTempAtInst{tNowData},selectedBars);
    figureOk = 1;
    zallAtInst=[zhTempAtInst{tNowData};softApproxTempAtInst{tNowData}];
    set(handles.countNoEdit,'String',num2str(size(zallAtInst,1)));
    set(handles.minValNoEdit,'String',num2str(min(zallAtInst)));
    set(handles.maxValNoEdit,'String',num2str(max(zallAtInst)));
    set(handles.meanNoEdit,'String',num2str(mean(zallAtInst)));
    set(handles.stDevNoEdit,'String',num2str(std(zallAtInst)));
    set(handles.medianNoEdit,'String',num2str(median(zallAtInst)));
    if length(zallAtInst)~=1
      set(handles.skewnessNoEdit,'String',num2str(skewness(zallAtInst)));
      set(handles.kurtosisNoEdit,'String',num2str(kurtosis(zallAtInst)));
    else
      set(handles.skewnessNoEdit,'String','N/A');
      set(handles.kurtosisNoEdit,'String','N/A');
    end
    clear zallAtInst;
  else                                  % There are no data at this instance
    figureOk = 0;
  end
end

if figureOk
  displayString = ['Data used for the plot: ' num2str(dataPopulation)];
  set(handles.feedbackEdit,'String',displayString);
  hFig = findobj(gca,'Type','patch');
  set(hFig,'FaceColor','y','EdgeColor','k');
  xlabel('Data');
  ylabel('Frequency');
else
  image(imread('guiResources/ithinkPic.jpg'));
  axis image
  axis off
  displayString = 'Data not available for this map';
  set(handles.feedbackEdit,'String',displayString);
  set(handles.countNoEdit,'String',num2str(0));
  set(handles.minValNoEdit,'String','N/A');
  set(handles.maxValNoEdit,'String','N/A');
  set(handles.meanNoEdit,'String','N/A');
  set(handles.stDevNoEdit,'String','N/A');
  set(handles.medianNoEdit,'String','N/A');
  set(handles.skewnessNoEdit,'String','N/A');
  set(handles.kurtosisNoEdit,'String','N/A');
end
