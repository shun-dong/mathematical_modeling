function varargout = ip406estimationsWiz(varargin)
%IP406ESTIMATIONSWIZ M-file for ip406estimationsWiz.fig
%      IP406ESTIMATIONSWIZ, by itself, creates a new IP406ESTIMATIONSWIZ or raises the existing
%      singleton*.
%
%      H = IP406ESTIMATIONSWIZ returns the handle to a new IP406ESTIMATIONSWIZ or the handle to
%      the existing singleton*.
%
%      IP406ESTIMATIONSWIZ('Property','Value',...) creates a new IP406ESTIMATIONSWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip406estimationsWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP406ESTIMATIONSWIZ('CALLBACK') and IP406ESTIMATIONSWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP406ESTIMATIONSWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip406estimationsWiz

% Last Modified by GUIDE v2.5 17-Apr-2006 17:09:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip406estimationsWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip406estimationsWiz_OutputFcn, ...
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


% --- Executes just before ip406estimationsWiz is made visible.
function ip406estimationsWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip406estimationsWiz
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

% UIWAIT makes ip406estimationsWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip406estimationsWiz_OutputFcn(hObject, eventdata, handles)
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
global displayString
global confIntSliderValue
global ck ch cs zh nl limi probdens
global ck4est ch4est cs4est zh4est nl4est limi4est probdens4est
global covmodel covparam dmax nhmax nsmax order bmeoptions
global bmeMod bmeMom bmePdf bmeCin
global covModelS covParamS maxCorrRangeS
global covModelST covParamST maxCorrRangeT
global correlationFactor
global xMin dx xMax yMin dy yMax zMin dz zMax usingGrid
global timePresent dataTimeSpan minTdata maxTdata 
global minTout maxTout outputTimeSpan
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar
global outGrid totalCoordinatesUsed
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhDataToProcessAtInst limiDataToProcessAtInst
global softApproxDataToProcessAtInst probdensFromDetrendedAtInst
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global softpdftype nl probdens
global initialNhmax initialNsmax
global nMin nMinInit stRIR stRIRinit stRIRacceptMin

axes(handles.estScreenAxes)
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off

% VERY IMPORTANT
% The output cell matrix gbmeMom
% is initialized in :ip002chooseTask.m".
% Should any changes occur in their size the programmer must update the above.
% Also, in the above file the elements {1,1} are all set to 0 initially.

if size(ch,1)<50      % This value is first set here. Allow for enough HD
  initialNhmax = size(ch,1);
else
  initialNhmax = 50;   
end
initialNsmax = 10;      % This value is first set here
nhmax = initialNhmax;  % Initialize: Consider the closest nhmax hard data for estimations
nsmax = initialNsmax;  % Initialize: Consider the closest nsmax soft data for estimations
order = NaN;           % Zero mean trend
if hardDataPresent
  set(handles.maxHdEdit,'String',num2str(initialNhmax));
else
  set(handles.maxHdEdit,'String','N/A');
end
if softDataPresent
  set(handles.maxSdEdit,'String',num2str(initialNsmax));
else
  set(handles.maxSdEdit,'String','N/A');
end
    
% The following initializations handle BMElib options.
% We make them as general as possible. In later versions some/all could
% be added to the screen for custom configuration.
%
% This one handles BMElib options(20) (default: 0.68) 
% For future versions: More than 1 confid. intervals can be estimated at a time.
% BMElib options(20:29) handle this. FOr added functionality, there can be more
% sliders, or additional levels could be stored in a variable.
confIntSliderValue = 0.68;                                    % Initialize
bmeoptions(20) = confIntSliderValue;

bmeoptions(3) = 200000; % BMElib integral calcs allowed. Default: 50000.
bmeoptions(4) = 0.005;  % BMElib max relative error allowed in above. Default: 0.0001.

bmeoptions(6) = 30;     % BMElib bins for output PDF. Default: 25.
bmeoptions(7) = 0.001;  % BMElib controller of the output grid range. Default: 0.001.
bmeoptions(8) = 3;      % BMElib controller: Calculate all moments.

% Initialize the maximum correlation radii in space and time based on the
% grid used.
%
% Arbitrarily, in space ask to look for the smaller 1/3 of grid dimensions
% Arbitrarily, in time ask to look into at least 2 t-instances
if totalCoordinatesUsed==3  
  if usingGrid
    maxCorrRangeS = min([(xMax-xMin)/3,(yMax-yMin)/3]);
  else
    maxCorrRangeS = (max(chcs,1)-min(chcs,1))/2;
  end
elseif totalCoordinatesUsed==2
  if usingGrid
    maxCorrRangeS = (xMax-xMin)/3;
  else
    maxCorrRangeS = (max(chcs,1)-min(chcs,1))/2;
  end
else
  errordlg({'ip406estimationsWiz:Preliminary settings:';...
            'There is only provision for 2 and 3 total dimension cases.';... 
            'An updated version is necessary to run a different case.'},... 
            'GUI software Error');
end
if timePresent
  if dataTimeSpan>2
    maxCorrRangeT = max(2,round((zMax-zMin)/2));
  else
    maxCorrRangeT = 2;
  end
end

correlationFactor = 1.25; % For search: Use correlationFactor*100% of the ranges

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

% Prepare the BME parameters to enter the estimation functions.
ch4est = [];            % Initialize
cs4est = [];            % Initialize
ck4est = [];            % Initialize
zh4est = [];            % Initialize
nl4est = [];            % Initialize
limi4est = [];          % Initialize
probdens4est = [];      % Initialize

if timePresent

  % Search for data as far away in S/T as correlation goes
  dmax(1) = correlationFactor*maxCorrRangeS;                  % Initialize
  dmax(2) = floor(correlationFactor*maxCorrRangeT);           % Initialize
  dmax(3) = stMetricPar;                                      % Initialize
  set(handles.sRangeEdit,'String',num2str(dmax(1)));          % Initialize
  set(handles.tRangeEdit,'String',num2str(dmax(2)));          % Initialize
  set(handles.stMetricEdit,'String',num2str(dmax(3)));        % Initialize
  
  %covmodel = covModelST;                        % Set covariance models
  %covparam = covParamST;                        % Set covariance parameters

  for iInst=1:dataTimeSpan                      % Use data at all t
    % Make use of BMElib function to assign proper probability densities
    % to transformed limits. Eventually, the limiDataToProcessAtInst values
    % will be used for the BME estimations, and these are employed to get
    % the updated, normalized prob densities in probdensFromDetrendedAtInst.
    if ~isempty(nlAtInst{iInst})  % Soft data may or may not be available at instance
      [tempVariable,norm] = proba2probdens(softpdftype,nlAtInst{iInst},...
        limiTempAtInst{iInst},probdensAtInst{iInst});
      probdensFromDataToProcessAtInst{iInst} = tempVariable;
    else                          % If no SD at instance, provide appropriately
      probdensFromDataToProcessAtInst{iInst} = [];
    end

    % Aggregate all input data in the format BMElib needs them
    ch4est = [ch4est; chAtInst{iInst} ...
             (minTdata+iInst-1)*ones(size(chAtInst{iInst},1),1)];
    cs4est = [cs4est; csAtInst{iInst} ...
             (minTdata+iInst-1)*ones(size(csAtInst{iInst},1),1)];
    zh4est = [zh4est; zhTempAtInst{iInst}];
    nl4est = [nl4est; nlAtInst{iInst}];
    limi4est = [limi4est; limiTempAtInst{iInst}];
    probdens4est = [probdens4est; probdensFromDataToProcessAtInst{iInst}];
  end
 
  for iInst=1:outputTimeSpan       % Obtain output at designated t
    tIndx = outGrid{totalCoordinatesUsed}(iInst);
    % Aggregate output locations in the format BMElib needs them
    ck4est = [ck4est; ckAtInst{iInst} ones(size(ckAtInst{iInst},1),1)*tIndx];
  end

else
    
  % Search for data as far away in S/T as correlation goes
  dmax = correlationFactor*maxCorrRangeS;                     % Initialize
  set(handles.sRangeEdit,'String',num2str(dmax));             % Initialize
  set(handles.tRangeEdit,'String','N/A');                     % Initialize
  set(handles.stMetricEdit,'String','N/A');                   % Initialize

  %covmodel = covModelS;                         % Set covariance models
  %covparam = covParamS;                         % Set covariance parameters

  % Make use of BMElib function to assign proper probability densities
  % to transformed limits. Eventually, the limiDataToProcess values
  % will be used for the BME estimations, and these are employed to get
  % the updated, normalized prob densities in probdensFromDetrended.
  if ~isempty(nl)  % Soft data may or may not be available at instance
    [tempVariable,norm] = proba2probdens(softpdftype,nl,...
                          limi,probdens);
    probdensFromDataToProcess = tempVariable;
  else                          % If no SD at instance, provide appropriately
    probdensFromDataToProcess = [];
  end

  ch4est = ch;
  cs4est = cs;
  ck4est = ck;
  zh4est = zh;
  nl4est = nl;
  limi4est = limi;
  probdens4est = probdensFromDataToProcess;
      
end

nMinInit = 7;                                       % Initialize
nMin = nMinInit;
set(handles.mindEdit,'String',num2str(nMin));

% Any acceptable stRIR value must be greater than stRIRacceptMin. 
stRIRacceptMin = 1;
stRIRinit = 1.2;                                    % Initialize
stRIR = stRIRinit;
set(handles.stRirEdit,'String',num2str(stRIR));    

displayString='Modify as desired the following parameters before estimations';
set(handles.feedbackEdit,'String',displayString);





function feedbackEdit_Callback(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of feedbackEdit as text
%        str2double(get(hObject,'String')) returns contents of feedbackEdit as a double
global displayString

% Disregard any editing by the user
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





function maxHdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxHdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxHdEdit as text
%        str2double(get(hObject,'String')) returns contents of maxHdEdit as a double
global initialNhmax
global hardDataPresent
global displayString
global nhmax

if hardDataPresent
  inputValue = str2num(get(handles.maxHdEdit,'String'));
  if ~isnan(inputValue)    
    switch 1
      case ( inputValue<=0 | mod(inputValue,floor(inputValue)) ) 
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer for';...
                  'max hard data to consider in estimation.';...
                  'The value is reset.'},'Invalid input!')        
        nhmax = initialNhmax;
        set(handles.maxHdEdit,'String',num2str(nhmax));
      case ( inputValue>500) % Over 500... Is this correct input?
        warndlg({['You asked to consider ' num2str(inputValue) ' hard data neighbors.'];...
                 'This seems like a large amount of data to consider.';,...
                 'Proceed, if this was correct, or review your input.'},...
                'Warning about large input')
        nhmax = inputValue;
        displayString = ['Closest ' num2str(nhmax) ...
                         ' hard data to be now used for estimation'];
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        nhmax = inputValue;
        displayString = ['Closest ' num2str(nhmax) ...
                         ' hard data to be now used for estimation'];
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if isempty(inputValue) | ~isnumeric(inputValue)
      errordlg({'Please provide a positive integer for';...
                'max hard data to consider in estimation.';...
                'The value is reset.'},'Invalid input!')        
      nhmax = initialNhmax;
      set(handles.maxHdEdit,'String',num2str(nhmax));
    end
  end
else
  nhmax = [];
  set(handles.maxHdEdit,'String','N/A');
  displayString = 'Hard data not present: Max hard data input ignored';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function maxHdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxHdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function maxSdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxSdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxSdEdit as text
%        str2double(get(hObject,'String')) returns contents of maxSdEdit as a double
global initialNsmax
global softDataPresent
global displayString
global nsmax

if softDataPresent
  inputValue = str2num(get(handles.maxSdEdit,'String'));
  if ~isnan(inputValue)    
    switch 1
      case ( inputValue<=0 | mod(inputValue,floor(inputValue)) ) 
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer for';...
                  'max soft data to consider in estimation.';...
                  'The value is reset.'},'Invalid input!')        
        nsmax = initialNsmax;
        set(handles.maxSdEdit,'String',num2str(nsmax));
      % In GBME we want the maximum amount of data to better define the
      % local neighborhood. However, a warning is issued to the user 
      % in case more than 15 soft data are asked for the calculations
      % to prevent potential typos. Of course, in the posterior stage 
      % a large number of soft data will render the calculations slower.
      %
      case ( inputValue>15)   % Over 15... Warn the user on time cost
        warndlg({['You asked to consider ' num2str(inputValue) ' soft data neighbors.'];...
                 'Please be advised that the time required for computations';...
                 'increases, in general, exponentially with the amount of';...
                 'soft data used. Depending on your available data,';...
                 'a number of up to 15 soft data would be suggested.';...
                 'Proceed, if you wish to continue, or review your input.'},...
                 'Warning about number of soft data')
        nsmax = inputValue;
        displayString = ['Closest ' num2str(nsmax) ...
                         ' soft data to be now used for estimation'];
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        nsmax = inputValue;
        displayString = ['Closest ' num2str(nsmax) ...
                         ' soft data to be now used for estimation'];
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if isempty(inputValue) | ~isnumeric(inputValue)
      errordlg({'Please provide a positive integer for';...
                'max soft data to consider in estimation.';...
                'The value is reset.'},'Invalid input!')        
      nsmax = initialNsmax;
      set(handles.maxSdEdit,'String',num2str(nsmax));
    end
  end
else
  nsmax = [];
  set(handles.maxSdEdit,'String','N/A');
  displayString = 'Soft data not present: Max soft data input ignored';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function maxSdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of sRangeEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global timePresent
global displayString

inputValue = str2num(get(handles.sRangeEdit,'String'));
if ~isnan(inputValue)    
  switch 1
    case ( inputValue<=0 ) % If negative or 0
      errordlg({'Please provide a positive value for the';...
                'max spatial range to search for data in the estimation.';...
                'The value is reset.'},'Invalid input!')        
      if timePresent
        dmax(1) = correlationFactor*maxCorrRangeS;
      else
        dmax = correlationFactor*maxCorrRangeS;
      end
      set(handles.sRangeEdit,'String',...
          num2str(correlationFactor*maxCorrRangeS));
    case totalSpCoordinatesUsed==1 & inputValue>1.5*(xMax-xMin)
      warndlg({'The input value exceeds by more than 150%';...
        'the output grid size';...
        ['(currently: ' num2str(xMax-xMin) ' spatial units).'];...
        'You may consider providing a smaller value for the';...
        'max spatial range to search for data in the estimation.';
        'Input is accepted but not recommended.'},...
        'Large input number');
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
    case totalSpCoordinatesUsed==2 & inputValue>1.5*(max((xMax-xMin),(yMax-yMin)))
      warndlg({'The input value exceeds by more than 150%';...
        'the output grid maximum side size';...
        ['(currently: ' num2str(max((xMax-xMin),(yMax-yMin))) ' spatial units).'];...
        'You may consider providing a smaller value for the';...
        'max spatial range to search for data in the estimation.';
        'Input is accepted but not recommended.'},...
        'Large input number');
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
    otherwise              % Accept input
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
  end
else              % A NaN conversion may result either from a letter or no input
  if isempty(inputValue) | ~isnumeric(inputValue)
    errordlg({'Please provide a positive value for the';...
              'max spatial range to search for data in the estimation.';...
              'The value is reset.'},'Invalid input!')        
    if timePresent
      dmax(1) = correlationFactor*maxCorrRangeS;
    else
      dmax = correlationFactor*maxCorrRangeS;
    end
    set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
  end
end



% --- Executes during object creation, after setting all properties.
function sRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of tRangeEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global dataTimeSpan
global timePresent
global displayString

if timePresent
  inputValue = str2num(get(handles.tRangeEdit,'String'));
  if ~isnan(inputValue)
    switch 1
      case ( inputValue<=0 | mod(inputValue,floor(inputValue)) )
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer value for the';...
          'max temporal range to search for data in the estimation.';...
          'The value is reset.'},'Invalid input!')        
        dmax(2) = correlationFactor*maxCorrRangeT;
        set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
      case inputValue>dataTimeSpan
        warndlg({'The input value exceeds the current data time span';...
          ['(currently: ' num2str(dataTimeSpan) ' temporal units).'];...
          'You may consider providing a smaller value for the';...
          'max temporal range to search for data in the estimation.';
          'Input is accepted but not recommended.'},...
          'Large input number');
        dmax(2) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        dmax(2) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if isempty(inputValue) | ~isnumeric(inputValue)
      errordlg({'Please provide a positive integer value for the';...
        'max temporal range to search for data in the estimation.';...
        'The value is reset.'},'Invalid input!')        
      dmax(2) = correlationFactor*maxCorrRangeT;
      set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
    end
  end
else
  set(handles.tRangeEdit,'String','N/A');
  displayString = 'Temporal parameter available only in S/T cases';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function tRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function stMetricEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stMetricEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stMetricEdit as text
%        str2double(get(hObject,'String')) returns contents of stMetricEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global timePresent
global displayString

if timePresent
  inputValue = str2num(get(handles.stMetricEdit,'String'));
  if ~isnan(inputValue)
    switch 1
      case ( inputValue<=0 ) % If negative, 0, or non-integer
        errordlg({'Please provide a positive value for the';...
          'spatiotemporal metric parameter in this estimation.';...
          'The value is reset.'},'Invalid input!')        
        dmax(3) = stMetricPar;
        set(handles.stMetricEdit,'String',num2str(stMetricPar));
      otherwise              % Accept input
        dmax(3) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
    end
  else                       % A NaN conversion may result either from a letter or no input
    if isempty(inputValue) | ~isnumeric(inputValue)
      errordlg({'Please provide a positive value for the';...
        'spatiotemporal metric parameter in this estimation.';...
        'The value is reset.'},'Invalid input!')        
      dmax(3) = stMetricPar;
      set(handles.stMetricEdit,'String',num2str(stMetricPar));
    end
  end
else
  set(handles.stMetricEdit,'String','N/A');
  displayString = 'S/T parameter available only in S/T cases';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function stMetricEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stMetricEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function mindEdit_Callback(hObject, eventdata, handles)
% hObject    handle to mindEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mindEdit as text
%        str2double(get(hObject,'String')) returns contents of mindEdit as a double
global nMin nMinInit

inputValue = str2num(get(handles.mindEdit,'String'));
if ~isnan(inputValue)
  switch 1
    case (inputValue <= 0) % If negative, 0, or non-integer
      errordlg({'Please provide a positive value for the';...
               'minimum number of data considered in the neighborhood.';...
               'The value is reset to the last valid one.'},'Invalid input!')        
      set(handles.mindEdit,'String',num2str(nMin));
    case (inputValue < nMinInit)
      warndlg({'The minimum number of data is too small.';... 
              'This may result in an unsufficient number';...
              'of nu-mu models to be considered.';...
              'The value is reset to the last valid one.'},...
              'Too small input number');
      set(handles.mindEdit,'String',num2str(nMin));
    otherwise              % Accept input
      nMin = inputValue;
      displayString = 'New value for minimum amount of data';
      set(handles.feedbackEdit,'String',displayString);
  end
else                       % A NaN conversion may result either from a letter or no input
  if isempty(inputValue) | ~isnumeric(inputValue)
    errordlg({'Please provide a positive value for the';...
             'minimum number of data considered in the neighborhood.';...
             'The value is reset.'},'Invalid input!')        
    set(handles.mindEdit,'String',num2str(nMin));        
  end
end





% --- Executes during object creation, after setting all properties.
function mindEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mindEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function stRirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stRirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stRirEdit as text
%        str2double(get(hObject,'String')) returns contents of stRirEdit as a double
global stRIR stRIRacceptMin

inputValue = str2num(get(handles.stRirEdit,'String'));
if ~isnan(inputValue)
  switch 1
    case (inputValue <= stRIRacceptMin) % If lower than acceptable minimum
      errordlg({['Please provide a rate greater than ' ...
               num2str(stRIRacceptMin)]; ...
               'for the radius increase';...
               'in case the insufficient data criterion is not met.';...
               'The value is reset to the last valid one.'},'Invalid input!')        
      set(handles.stRirEdit,'String',num2str(stRIR));
    otherwise              % Accept input
      stRIR = inputValue;
      displayString = 'New value for the S/T search radius increase rate';
      set(handles.feedbackEdit,'String',displayString);
  end
else                       % A NaN conversion may result either from a letter or no input
  if isempty(inputValue) | ~isnumeric(inputValue)
    errordlg({['Please provide a rate greater than ' ...
             num2str(stRIRacceptMin)]; ...
             'for the radius increase';...
             'in case the insufficient data criterion is not met.';...
             'The value is reset to the last valid one.'},'Invalid input!')        
    set(handles.stRirEdit,'String',num2str(stRIR));        
  end
end





% --- Executes during object creation, after setting all properties.
function stRirEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stRirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in resetOptionsButton.
function resetOptionsButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetOptionsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global nhmax nsmax
global initialNhmax initialNsmax
global nMinInit stRIRinit
global hardDataPresent softDataPresent
global timePresent
global displayString

if hardDataPresent
  nhmax = initialNhmax;
  set(handles.maxHdEdit,'String',num2str(initialNhmax));
else
  set(handles.maxHdEdit,'String','N/A');
end
if softDataPresent
  nsmax = initialNsmax;
  set(handles.maxSdEdit,'String',num2str(initialNsmax));
else
  set(handles.maxSdEdit,'String','N/A');
end

if timePresent
  dmax(1) = correlationFactor*maxCorrRangeS;
  dmax(2) = correlationFactor*maxCorrRangeT;
  dmax(3) = stMetricPar;
  set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
  set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
  set(handles.stMetricEdit,'String',num2str(stMetricPar));
else
  dmax = correlationFactor*maxCorrRangeS;
  set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
end

nMin = nMinInit;
set(handles.mindEdit,'String',num2str(nMin));

stRIR = stRIRinit;
set(handles.stRirEdit,'String',num2str(stRIR));

displayString = 'GBME estimation parameters set to initial values';
set(handles.feedbackEdit,'String',displayString);





% --- Executes on button press in beginEstimationButton.
function beginEstimationButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginEstimationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ck ch cs softpdftype
global covmodel covparam dmax nhmax nsmax order bmeoptions
global ck4est ch4est cs4est zh4est nl4est limi4est probdens4est
global gbmeMom
global displayString
global timePresent dataTimeSpan minTdata maxTdata
global minTout maxTout outputTimeSpan
global applyTransform transformTypeStr
global ntransfTable                          % To be used in backtransformations
global nscMinAcceptOutput nscMaxAcceptOutput % To be used in backtransformations
global bcxLambda bcxDataShiftConst           % To be used in backtransformations
global outGrid
global totalCoordinatesUsed totalSpCoordinatesUsed
global meanTrendAtkAtInst
global positiveDataOnly
global stRIR nMin

% VERY IMPORTANT
% The output cell matrix gbmeMom
% is initialized in :ip002chooseTask.m".
% Should any changes occur in their size the programmer must update the above.
% Also, in the above file the elements {1,1} are all set to 0 initially.

displayString = 'Estimations may take a while. Please wait until done';
set(handles.feedbackEdit,'String',displayString);
axes(handles.estScreenAxes)
%for waitFrame=1:5
%[iwait(:,:,:,waitFrame),map] = imread('guiResources/iWait.gif',waitFrame);
%waitMovie(waitFrame) = im2frame(iwait(:,:,:,waitFrame),map);
%end
%movie(waitMovie,3,5);
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off
  
pause(0.1);

%addpath guiLibs/GBMELIB1.0/
%addpath guiLibs/GBMELIB1.0/models
%addpath guiLibs/GBMELIB1.0/mvnlib
  
totEstPts = size(ck4est,1);        % At how many points do we obtain estimates?
 
for iRep=1:totEstPts            % BEGIN: For all the estimation points
  percentDone = floor(100*iRep/totEstPts);  % Where are we standing?
  displayString = ['GBME Moments: Estimation at point ' num2str(iRep) '/' ...
                   num2str(totEstPts) '. Progress: About '...
                   num2str(percentDone) '%'];
  set(handles.feedbackEdit,'String',displayString);
  pause(0.01);                  % Necessary to display msg. Min burden
  ckPoint = ck4est(iRep,:);     % Isolate current estimation point
  [numuMom(iRep,1:3),numu(iRep,1:2),info(iRep,1:3)] = BMEnumuMoments...
        (ckPoint,ch4est,cs4est,zh4est,softpdftype,nl4est,limi4est,...
        probdens4est,nhmax,nsmax,dmax,nMin,stRIR,bmeoptions);
end
if timePresent
  for iInst=1:outputTimeSpan % Iterate over the output instances
    tNowActual = outGrid{totalCoordinatesUsed}(iInst);
    indx = find(ck4est(:,end)==tNowActual);
    gbmeMom{1,iInst} = [];
    gbmeMom{2,iInst} = [iInst tNowActual]; % Temporal instance we refer to
    gbmeMom{3,iInst} = [numuMom(indx,1)];
    gbmeMom{4,iInst} = [numuMom(indx,2)];
    gbmeMom{5,iInst} = [numuMom(indx,3)];
    gbmeMom{6,iInst} = info(indx,:);
    gbmeMom{7,iInst} = numu(indx,:);
  end  
  gbmeMom{1,1} = [1];            % To verify estimation has been performed
else
  iInst = 1;
  gbmeMom{1,iInst} = [1];        % To verify estimation has been performed
  gbmeMom{2,iInst} = [iInst iInst];        % Temporal instance we refer to
  gbmeMom{3,iInst} = numuMom(:,1);
  gbmeMom{4,iInst} = numuMom(:,2);
  gbmeMom{5,iInst} = numuMom(:,3);
  gbmeMom{6,iInst} = info;
  gbmeMom{7,iInst} = numu;
end

displayString = 'GBME estimations completed. GBME Moments data present';
set(handles.feedbackEdit,'String',displayString);
pause(0.01);

% Prompt the user to save the data. User can save them later while on the
% same screen, too.
initialDir = pwd;     % Save the current directory path

gbmeOutFilename = 'GBMEestimationOut.mat';
% Prompt user to save trend information data in a MAT-file for future use
%
[gbmeOutFilename,gbmeOutPathname] = uiputfile( '*.mat', 'Save GBME output info as MAT-file:');	

if isequal([gbmeOutFilename,gbmeOutPathname],[0,0])  % If 'Cancel' selected, give second chance
  user_response = ip103fileSaveDialog('Title','Skip Saving GBME output Data?');
  switch lower(user_response)
    case 'no'                 % If user changes his/her mind, prompt to save
      [gbmeOutFilename,gbmeOutPathname] = uiputfile( '*.mat', 'Save GBME output info as MAT-file:');	
      if ~isequal([gbmeOutFilename,gbmeOutPathname],[0,0])  % If other than 'Cancel' was selected
        % Construct the full path and save
        validOutputData = 1;  % Control variable. Validates this as an output file
        File = fullfile(gbmeOutPathname,gbmeOutFilename);
        save(File,'gbmeMom',...
                  'timePresent','outGrid','totalCoordinatesUsed',...
                  'totalSpCoordinatesUsed','minTout','minTdata',...
                  'positiveDataOnly','validOutputData');
        displayString1 = ['GBME output in: ' gbmeOutFilename];
      end
    case 'yes'
      % Do nothing
      gbmeOutFilename = [];
      displayString1 = 'GBME output data present but not saved';
  end
else                  % If other than 'Cancel' was selected at first
  % Construct the full path and save
  validOutputData = 1;  % Control variable. Validates this as an output file
  File = fullfile(gbmeOutPathname,gbmeOutFilename);
  save(File,'gbmeMom',...
            'timePresent','outGrid','totalCoordinatesUsed',...
            'totalSpCoordinatesUsed','minTout','minTdata',...
            'positiveDataOnly','validOutputData');
  displayString1 = ['GBME output in: ' gbmeOutFilename];
end

cd (initialDir);      % Finally, return to where this function was evoked from

set(handles.feedbackEdit,'String',displayString1);
pause(2.5);
displayString = 'GBME estimations completed. GBME Moments data present';
set(handles.feedbackEdit,'String',displayString);





% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gbmeMom
global displayString
global timePresent
global outGrid
global totalCoordinatesUsed totalSpCoordinatesUsed
global meanTrendAtkAtInst
global positiveDataOnly
global minTout minTdata

if gbmeMom{1,1} % If there is material to save
    
  initialDir = pwd;     % Save the current directory path

  gbmeOutFilename = 'GBMEestimationOut.mat';
  % Prompt user to save trend information data in a MAT-file for future use
  %
  [gbmeOutFilename,gbmeOutPathname] = uiputfile( '*.mat', 'Save GBME output info as MAT-file:');	

  if isequal([gbmeOutFilename,gbmeOutPathname],[0,0])  % If 'Cancel' selected, give second chance
    user_response = ip103fileSaveDialog('Title','Skip Saving GBME output Data?');
    switch lower(user_response)
      case 'no'                 % If user changes his/her mind, prompt to save
        [gbmeOutFilename,gbmeOutPathname] = uiputfile( '*.mat', 'Save GBME output info as MAT-file:');	
        if ~isequal([gbmeOutFilename,gbmeOutPathname],[0,0])  % If other than 'Cancel' was selected
          % Construct the full path and save
          validOutputData = 1;  % Control variable. Validates this as an output file
          File = fullfile(gbmeOutPathname,gbmeOutFilename);
          save(File,'gbmeMom',...
                    'timePresent','outGrid','totalCoordinatesUsed',...
                    'totalSpCoordinatesUsed','minTout','minTdata',...
                    'positiveDataOnly','validOutputData');
          displayString = ['GBME output in: ' gbmeOutFilename];
          set(handles.feedbackEdit,'String',displayString);
        end
      case 'yes'
        % Do nothing
        gbmeOutFilename = [];
        displayString = 'GBME output data present but not saved';
        set(handles.feedbackEdit,'String',displayString);
    end
  else                  % If other than 'Cancel' was selected at first
    % Construct the full path and save
    validOutputData = 1;  % Control variable. Validates this as an output file
    File = fullfile(gbmeOutPathname,gbmeOutFilename);
    save(File,'gbmeMom',...
              'timePresent','outGrid','totalCoordinatesUsed',...
              'totalSpCoordinatesUsed','minTout','minTdata',...
              'positiveDataOnly','validOutputData');
    displayString = ['GBME output in: ' gbmeOutFilename];
    set(handles.feedbackEdit,'String',displayString);
  end

  cd (initialDir);      % Finally, return to where this function was evoked from

else
    
  displayString = ['No GBME output is present to save'];
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
global timePresent

delete(handles.figure1);                            % Close current window...
ip404p2explorAnal('Title','Exploratory Analysis');





% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timePresent

% The same visualization screen applies to S/T and S-only cases.
delete(handles.figure1);                           % Close current window...
ip307v1Tvisuals('Title','Visualization Wizard');      % ...and procede to following screen.
