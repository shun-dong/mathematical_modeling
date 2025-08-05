function varargout = ip305p1covarAnal(varargin)
%IP305P1COVARANAL M-file for ip305p1covarAnal.fig
%      IP305P1COVARANAL, by itself, creates a new IP305P1COVARANAL or raises the existing
%      singleton*.
%
%      H = IP305P1COVARANAL returns the handle to a new IP305P1COVARANAL or the handle to
%      the existing singleton*.
%
%      IP305P1COVARANAL('Property','Value',...) creates a new IP305P1COVARANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip305p1covarAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP305P1COVARANAL('CALLBACK') and IP305P1COVARANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP305P1COVARANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip305p1covarAnal

% Last Modified by GUIDE v2.5 29-Jul-2005 13:55:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip305p1covarAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip305p1covarAnal_OutputFcn, ...
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


% --- Executes just before ip305p1covarAnal is made visible.
function ip305p1covarAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip305p1covarAnal
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

% UIWAIT makes ip305p1covarAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip305p1covarAnal_OutputFcn(hObject, eventdata, handles)
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
global timePresent
global ch zh cs totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory nl limi probdens softApprox
global cPt cPtValues
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covInputFile covInputPath
global covModelS covParamS
global maxCorrRangeS lagsNumberS lagsLimitsS
global covModS covExpS nestedScounter
global displayString
global prevExtFigState
global sillWithinBounds 
global rangeMin rangeMax rangeWithinBounds

axes(handles.spatialCovAxes)
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

if timePresent       % Define properly the distance between most remote data.
    maxEuclDistS = coord2dist( max(cPt(:,1:end-1)),min(cPt(:,1:end-1)) );
    % Fot t: maxEuclDistT = coord2dist( max(cPt(:,end)),min(cPt(:,end)) );
else
    maxEuclDistS = coord2dist( max(cPt(:,:)),min(cPt(:,:)) );
end

covExpS = struct('anisotropyString',...
                    {'All directions','East - West','North - South'},...
               'maxCorrRange',{[],[],[]},...   % 3 spots for info
               'lagsNumber',{[],[],[]},...     % on each of the 3
               'lagsLimits',{[],[],[]},...     % available directions.
               'covDistance',{[],[],[]},...
               'experimCov',{[],[],[]},...
               'pairsNumber',{[],[],[]},...
               'dirOk',{[0],[0],[0]});
covModS = struct('model',{[],[]},...           % 2 spots for up to 2
               'sill',{[],[]},...              % nested components. This
               'range',{[],[]},...             % can change in future versions.
               'modelName',{[],[]},...         % To store BMElib model names   
               'emptySpot',{[1],[1]},...       % An index for the struct
               'modIndex',{[0 0]},...          % Index of current model showing
               'modOk',{[0],[0]});

% Initialize max correlation range to half the dist between the most remote data
% This is arbitrary and may be modified
maxCorrRangeS = maxEuclDistS / 2;  
lagsNumberS = 10;                  % Initialize number of lags for covariance.
% Initialize the covariance lags based on the previous
% and space them out logarithmically.
lagsLimitsS = maxCorrRangeS * (1 - ...     
              log(lagsNumberS+1-[1:lagsNumberS])./log(lagsNumberS) );

set(handles.anisotropyMenu,'Value',1);  % Initialize using all-directions option.
set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
set(handles.lagNumberSlider,'Value',10);                         % Initialize.
set(handles.lagNumberEdit,'String',...
    num2str(get(handles.lagNumberSlider,'Value')));              % Initialize.
displayString = 'First, obtain the experimental covariance';
set(handles.feedbackEdit,'String',displayString);

covInputFile = [];                  % Initialize.
nestedScounter = 0;                 % Initialize.

covModelS = [];                     % Initialize.
covParamS = [];                     % Initialize.

sillWithinBounds = 1;               % Initialize. A flag used in edit boxes
rangeWithinBounds = 1;              % Initialize. A flag used in edit boxes

set(handles.modelsPresentEdit,'String',num2str(nestedScounter)); % Initialize.
set(handles.addModelMenu,'Value',1);     % Initialize using "exponential" option.
set(handles.currModelMenu,'Value',1);                            % Initialize to show 0.
set(handles.sillEdit,'String','');                               % Initialize.
set(handles.rangeEdit,'String','');                              % Initialize.

prevExtFigState = 0;                % Initialize - plots in GUI window




% --- Executes on selection change in anisotropyMenu.
function anisotropyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to anisotropyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns anisotropyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from anisotropyMenu
global covModS covExpS 
global zhDataToProcess softApproxDataToProcess
global displayString

% Choice of covariance in all-directions (1), E-W (2), or N-S (3).
choice = get(handles.anisotropyMenu,'Value');
if covExpS(choice).dirOk  % If choice info already stored, load info on screen
  displayString = 'Presenting stored data for this choice';
  set(handles.feedbackEdit,'String',displayString);
  set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
  set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
  set(handles.lagNumberEdit,'String',...
      num2str(get(handles.lagNumberSlider,'Value')));
  
  % Gather all point data (whether log-transformed or not).
  % Also provides correct set (HD only) in case where no SD approximations are used.
  cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

  set(handles.graphTypeMenu,'Value',choice);  
  % Plot the experimental covariance outcome
  % Include in the plot the distance at s=0 where the covariance is the data variance
  %
  if get(handles.extFigureBox,'Value')      % Separate figure or not?
    axes(handles.spatialCovAxes)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    figure;
  else
    axes(handles.spatialCovAxes)
  end  
  if choice == 1
    set(handles.graphTypeMenu,'Value',1)
    hCov = plot([0 covExpS(choice).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
  elseif choice == 2
    set(handles.graphTypeMenu,'Value',2)
    hCov = plot([0 covExpS(choice).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
  elseif choice == 3
    set(handles.graphTypeMenu,'Value',3)
    hCov = plot([0 covExpS(choice).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
  end
  legend(hCov,covExpS(choice).anisotropyString);
  xlabel('Lag (in distance units)');
  ylabel('Covariance');
else
  displayString = 'No information for this direction selection yet';
  set(handles.feedbackEdit,'String',displayString);
end
  



% --- Executes during object creation, after setting all properties.
function anisotropyMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anisotropyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function maxCorrRngEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxCorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxCorrRngEdit as text
%        str2double(get(hObject,'String')) returns contents of maxCorrRngEdit as a double
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global maxCorrRangeS

inputValue = str2num(get(handles.maxCorrRngEdit,'String'));
% The variable is empty, unless the user provides a numeric value.
if inputValue<=0
  errordlg({'Please provide only a non-zero positive value';...
            'to be the maximum correlation range.'},... 
            'Invalid input');
  set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif isempty(inputValue) | ~isnumeric(inputValue)
  errordlg({'Please enter a numeric value for your estimate';...
            'of the size of the maximum correlation range.'},... 
            'Invalid input');
  set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif totalSpCoordinatesUsed==1 & inputValue>1.5*(xMax-xMin)
  warndlg({'The input value exceeds by more than 150%';...
           'the output grid size';...
           ['(currently: ' num2str(xMax-xMin) ' spatial units).'];...
           'Please provide a smaller value and remember that';...
           'larger radii values result in smoother trends.'},... 
           'Input not recommended');
  set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif totalSpCoordinatesUsed==2 & inputValue>1.5*(max((xMax-xMin),(yMax-yMin)))
  warndlg({'The input value exceeds by more than 150%';...
           'the output grid maximum side size';...
           ['(currently: ' num2str(max((xMax-xMin),(yMax-yMin))) ' spatial units).'];...
           'Please provide a smaller value and remember that';...
           'larger radii values result in smoother trends.'},... 
           'Input not recommended');
  set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
else
  maxCorrRangeS = inputValue;
end




% --- Executes during object creation, after setting all properties.
function maxCorrRngEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxCorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function lagNumberSlider_Callback(hObject, eventdata, handles)
% hObject    handle to lagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global lagsNumberS 

lagsNumberS = round(get(handles.lagNumberSlider,'Value'));
set(handles.lagNumberEdit,'String',num2str(lagsNumberS));




% --- Executes during object creation, after setting all properties.
function lagNumberSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function lagNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lagNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lagNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of lagNumberEdit as a double
global lagsNumberS 

minLags = get(handles.lagNumberSlider,'Min');
maxLags = get(handles.lagNumberSlider,'Max');
inputValue = str2num(get(handles.lagNumberEdit,'String'));
if isempty(inputValue) | ...                     % Reject input if non-numeric,
   mod(inputValue,floor(inputValue)) | ...       % non-integer,
   inputValue<minLags | inputValue>maxLags       % or out of allowed values.
  errordlg({['Please enter an integer between '...
            num2str(minLags) ' and ' num2str(maxLags) ' for the number of lags'];...
            'to be used in the calculation of the experimental covariance.'},... 
            'Invalid input');
  set(handles.lagNumberEdit,'String',num2str(lagsNumberS))
else
  lagsNumberS = inputValue;
  set(handles.lagNumberSlider,'Value',lagsNumberS);
end




% --- Executes during object creation, after setting all properties.
function lagNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lagNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covInputFile covInputPath
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global maxCorrRangeS lagsNumberS lagsLimitsS
global covModS covExpS nestedCounter
global displayString

initialDir = pwd;                    % Save the current directory path

[covInputFileNew,covInputPath] = uigetfile('*.mat','Select covariance Data MAT-file');
%
% If user presses 'Cancel' then 0 is returned.
%
% If user cancels, we want to retain the information, if any present. 
% The following IF statement produces a warning if the user cancels AND 
% has no previous data, or otherwise loads the data from a valid file.
%
if ~ischar(covInputFileNew) & ~ischar(covInputFile) % If "Cancel" AND no previous data
    
  displayString = 'No covariance Data MAT-file present';
  set(handles.feedbackEdit,'String',displayString);
  
elseif ischar(covInputFileNew)                      % If new data to be entered
    
  covInputFile = covInputFileNew; % The new one replaces the existing one
  cd (covInputPath);              % Go where the covariance file resides

  if ~isnan(str2double(textread(covInputFile,'%s',1)))  % Is this a MAT-file?
    warndlg({'Covariance data are to be read from an existing MAT-file.';...
        'It seems that it is not a Matlab MAT-file.';,...
        'Please check again your input';...
        'or opt to calculate the covariance explicitly.'},...
        'Not a MAT-file!')
    displayString = 'No covariance Data MAT-file present';
    set(handles.feedbackEdit,'String',displayString);
  else    
    fileContents = load('-mat',covInputFile);           % Load data from file
    if ~isfield(fileContents,'covExpS')                 % Is this the right file?
      set(handles.feedbackEdit,'String','No covariance Data MAT-file present');
      errordlg({'This MAT-file that contains irrelevant information.';...
          'Please check again your input';...
          'or opt to calculate the covariance explicitly.'},...
          'Wrong file!')
      clear fileContents;
    else
      displayString = ['Using saved spatial covariance data in: ' covInputFile];
      set(handles.feedbackEdit,'String',displayString);

      clear fileContents;
      load('-mat',covInputFile);  % Load the covariance information into memory 
 
      cd (initialDir);            % Return to where this function was evoked from
      if covExpS(1).dirOk & ~covExpS(2).dirOk & ~covExpS(3).dirOk     % All-dir
        displayString = 'Data available for anisotropy option: All-dir';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display all of the available saved data
      elseif ~covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk % E-W
        displayString = 'Data available for anisotropy option: E-W';
        set(handles.feedbackEdit,'String',displayString);
        choice = 2;               % So as to display all of the available saved data
      elseif ~covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk % N-S
        displayString = 'Data available for anisotropy option: N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 3;               % So as to display all of the available saved data
      elseif covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk  % All-dir & E-W
        displayString = 'Data available for anisotropy options: All-dir & E-W';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      elseif covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk  % All-dir & N-S
        displayString = 'Data available for anisotropy options: All-dir & N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      elseif ~covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk  % E-W & N-S
        displayString = 'Data available for anisotropy options: E-W & N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 2;               % So as to display some of the available saved data
      elseif covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk   % All
        displayString = 'Data available for all anisotropy options.';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      else                                                            % No info
        errordlg({'ip305p1covarAnal.m:loadDataButton_Callback Function:';...
              'After loading saved data it is suggested that no information';...
              'is contained in the struct covExpS.dirOk index array:';...
              ['covExpS.dirOk=[' num2str(covExpS(1).dirOk) ' '...
              num2str(covExpS(2).dirOk) ' ' num2str(covExpS(3).dirOk) '].']},...
              'GUI software Error');
      end
      
      maxCorrRangeS = covExpS(choice).maxCorrRange;
      lagsNumberS = covExpS(choice).lagsNumber;
      
      set(handles.anisotropyMenu,'Value',choice);  
      set(handles.maxCorrRngEdit,'String',num2str(maxCorrRangeS));
      set(handles.lagNumberSlider,'Value',lagsNumberS);
      set(handles.lagNumberEdit,'String',num2str(lagsNumberS));

      % Gather all point data (whether log-transformed or not).
      % Also provides correct set (HD only) in case where no SD approximations are used.
      cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

      set(handles.graphTypeMenu,'Value',choice);  
      % Plot the experimental covariance outcome
      % If we deal with all-directions, include in the plot the distance at s=0 
      % where the covariance is the data variance. Otherwise do not include s=0
      % because the curve may range higher or lower than the average direction.
      %
      if get(handles.extFigureBox,'Value')      % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      if choice == 1
        set(handles.graphTypeMenu,'Value',1)
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
      elseif choice == 2
        set(handles.graphTypeMenu,'Value',2)
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
      elseif choice == 3
        set(handles.graphTypeMenu,'Value',3)
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
      end
      legend(hCov,covExpS(choice).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');

    end
  end    
  cd (initialDir);     % Finally, return to where this function was evoked from
    
end




% --- Executes on button press in experCovarianceButton.
function experCovarianceButton_Callback(hObject, eventdata, handles)
% hObject    handle to experCovarianceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cPt
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global maxCorrRangeS lagsNumberS lagsLimitsS
global experimentalCovOk covDataFilename
global covDistanceS experimCovS pairsNumberS
global covOutFile covOutPath
global covModS covExpS nestedCounter
global displayString

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Which direction is the covariance calculated in?
directionIndx = get(handles.anisotropyMenu,'Value');

if covExpS(directionIndx).dirOk   % It seems that the requested data are here.
  % Show on screen what is already available.
  if covExpS(1).dirOk & ~covExpS(2).dirOk & ~covExpS(3).dirOk     % All-dir
    displayString = 'Data available for anisotropy option: All-dir';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk % E-W
    displayString = 'Data available for anisotropy option: E-W';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk % N-S
    displayString = 'Data available for anisotropy option: N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk  % All-dir & E-W
    displayString = 'Data available for anisotropy options: All-dir & E-W';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk  % All-dir & N-S
    displayString = 'Data available for anisotropy options: All-dir & N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk  % E-W & N-S
    displayString = 'Data available for anisotropy options: E-W & N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk   % All
    displayString = 'Data available for all anisotropy options.';
    set(handles.feedbackEdit,'String',displayString);
  else                                                            % No info
    errordlg({'ip305p1covarAnal.m:loadDataButton_Callback Function:';...
          'After loading saved data it is suggested that no information';...
          'is contained in the struct covExpS.dirOk index array:';...
          ['covExpS.dirOk=[' num2str(covExpS(1).dirOk) ' '...
          num2str(covExpS(2).dirOk) ' ' num2str(covExpS(3).dirOk) '].']},...
          'GUI software Error');
  end
  % Check with user whether to continue with calculation or not.  
  user_response = ip105p1getCovWarning('Title','Confirm Action');
  switch lower(user_response)
    case 'no'
        proceedWithCalculation = 0;
    case 'yes'
        proceedWithCalculation = 1;
  end  
else                              % If not, prepare for calculations.
  proceedWithCalculation = 1;
end

if proceedWithCalculation

  % option(4)=1 removes the mean from the data to use for experim. covariance.
  % option(4)=0 assumes zero-mean data: This may not be the case when using
  % the Box-Cox transformation that may have added a constant to the data.
  switch directionIndx              % 1, 2, or 3.
    case 1
      options=[0 0 0 1] ;       % All directions
    case 2
      options=[0 -45 45 1];     % East-West
    case 3
      options=[0 45 -45 1];     % North-South
    otherwise
      errordlg({'ip305p1covarAnal.m:experCovarianceButton_Callback Function:';...
            'The switch command detected more options';...
            'than currently available (3) in the Anisotropy menu.'},...
            'GUI software Error')
  end

  % For the following two parameters, make sure they are not empty or invalid.
  % Currently, this check is performed at the corresponding UI handles functions.
  % Also, the handles are initialized whenever this screen is invoked.
  % So at this instance the two UI handles in use below have been assigned values.
  %
  maxCorrRangeS = str2num(get(handles.maxCorrRngEdit,'String'));
  lagsNumberS = get(handles.lagNumberSlider,'Value');

  lagsLimitsS = maxCorrRangeS * (1 - ... % Space out the lags logarithmically.
                log(lagsNumberS+1-[1:lagsNumberS])./log(lagsNumberS) );

  if lagsLimitsS(2) > maxCorrRangeS/100
    for i=length(lagsLimitsS):-1:2       % Shift lags by one position to the right
      lagsLimitsS(i+1) = lagsLimitsS(i);
    end
    lagsLimitsS(1) = 0;
    lagsLimitsS(2) = maxCorrRangeS/100;  % ...to make space for an additional one
  end

  covExpS(directionIndx).maxCorrRange = maxCorrRangeS;
  covExpS(directionIndx).lagsNumber = lagsNumberS;
  covExpS(directionIndx).lagsLimits = lagsLimitsS;

  displayString = 'Calculating experimental covariance. Please wait...';
  set(handles.feedbackEdit,'String',displayString);
  pause(0.1);

  [covDistanceS,experimCovS,pairsNumberS] = ...
      crosscovariogui(cPt,cPt,cPtValuesDataToProcess,cPtValuesDataToProcess,...
      lagsLimitsS,'loop',options);

  covExpS(directionIndx).covDistance = covDistanceS;
  covExpS(directionIndx).experimCov = experimCovS;
  covExpS(directionIndx).pairsNumber = pairsNumberS;
  covExpS(directionIndx).dirOk = 1;

  set(handles.graphTypeMenu,'Value',directionIndx);  
  % Plot the experimental covariance. At s=0 the covariance is the data variance. 
  if get(handles.extFigureBox,'Value')      % Separate figure or not?
    axes(handles.spatialCovAxes)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    figure;
  else
    axes(handles.spatialCovAxes)
  end  
  if directionIndx == 1
    set(handles.graphTypeMenu,'Value',1)
    hCov = plot([0 covExpS(directionIndx).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(directionIndx).experimCov'],'ro');
  elseif directionIndx == 2
    set(handles.graphTypeMenu,'Value',2)
    hCov = plot([0 covExpS(directionIndx).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(directionIndx).experimCov'],'m<');
  elseif directionIndx == 3
    set(handles.graphTypeMenu,'Value',3)
    hCov = plot([0 covExpS(directionIndx).covDistance'],...
                [var(cPtValuesDataToProcess) covExpS(directionIndx).experimCov'],'m^');
  end
  legend(hCov,covExpS(directionIndx).anisotropyString);
  xlabel('Lag (in distance units)');
  ylabel('Covariance');

  % Prompt user to save covariance information data in a MAT-file for future use
  %
  covDataFile = 'experimCovS.mat';
  displayString = ['Done. Saving results in ' covDataFile];
  set(handles.feedbackEdit,'String',displayString);

  initialDir = pwd;                     % Save the current directory path
  [covOutFile,covOutPath] = ...
      uiputfile(covDataFile,'Save covariance info as MAT-file:');	

  if isequal([covOutFile,covOutPath],[0,0]) % If 'Cancel' selected, give second chance
    displayString = 'Exper. covariance data present but not saved';
    set(handles.feedbackEdit,'String',displayString);
    user_response = ip103fileSaveDialog('Title','Skip Saving Covariance Data?');
    switch lower(user_response)
    case 'no'                           % If user changes his/her mind, prompt to save
      [covOutFile,covOutPath] = ...
          uiputfile(covDataFile,'Save covariance info as MAT-file:');	
      if ~isequal([covOutFile,covOutPath],[0,0]) % If other than 'Cancel' was selected
        % Construct the full path and save
        File = fullfile(covOutPath,covOutFile);
        save(File,'covExpS','covModS');
        displayString = ['Saved experimental results in ' covOutFile];
        set(handles.feedbackEdit,'String',displayString);
      end
    case 'yes'
      % Do nothing
    end
  else                                  % If other than 'Cancel' was selected at first
    % Construct the full path and save
    File = fullfile(covOutPath,covOutFile);
    save(File,'covExpS','covModS');
    displayString = ['Saved experimental results in ' covOutFile];
    set(handles.feedbackEdit,'String',displayString);
  end

  cd (initialDir);                          % Return to working directory

else
    % Do nothing
end




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




function modelsPresentEdit_Callback(hObject, eventdata, handles)
% hObject    handle to modelsPresentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelsPresentEdit as text
%        str2double(get(hObject,'String')) returns contents of modelsPresentEdit as a double
global nestedScounter

set(handles.modelsPresentEdit,'String',num2str(nestedScounter));




% --- Executes during object creation, after setting all properties.
function modelsPresentEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelsPresentEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in addModelMenu.
function addModelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to addModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns addModelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from addModelMenu
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS

% Define max allowed number of nested structures. Can change in future version.
% There should be at least maxModels slots in any the covModS struct fields.
%
maxModels = 2;

% Check whether the user has selected an experimental covariance for which
% information exists. If so, allow the construction of a fitting model.
% 
% Choice of covariance in all-directions (1), E-W (2), or N-S (3).
%
choice = get(handles.anisotropyMenu,'Value');

if covExpS(choice).dirOk
  % Proceed with a new nested model if allowed (models not maxed out)
  % AND if user has actually selected a model (modelType=1 is the menu title)
  %
  modelType = get(handles.addModelMenu,'Value');
  if nestedScounter<maxModels & modelType~=1
      
    % Update the counter at the modelsPresentEdit box...
    nestedScounter = nestedScounter + 1;
    set(handles.modelsPresentEdit,'String',num2str(nestedScounter));
    % Update the current model value display in the currModelMenu...
    currModel = get(handles.currModelMenu,'Value');
    set(handles.currModelMenu,'Value',currModel+1);
    % Update the current model type display in the modelTypeEdit box...
    switch modelType
      case 1
        % Do nothing - this is the label.
        % Should never reach here because of previous IF control statement.
      case 2
        covModS(nestedScounter).model = 1;
        covModS(nestedScounter).modelName = 'exponentialC';
        set(handles.modelTypeEdit,'String','EXP');  % Designate exponential model
        covModS(nestedScounter).emptySpot = 0;
      case 3
        covModS(nestedScounter).model = 2;
        covModS(nestedScounter).modelName = 'gaussianC';
        set(handles.modelTypeEdit,'String','GAU');  % Designate gaussian model
        covModS(nestedScounter).emptySpot = 0;
      case 4
        covModS(nestedScounter).model = 3;
        covModS(nestedScounter).modelName = 'sphericalC';
        set(handles.modelTypeEdit,'String','SPH');  % Designate spherical model
        covModS(nestedScounter).emptySpot = 0;
    end
    
    cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
    % Set the sill values to be between 0 and the data variance.
    sillMin = 0;
    sillMax = var(cPtValuesDataToProcess);
    % Set the range values to be between 0 and the current max correlation range.
    rangeMax = covExpS(choice).maxCorrRange; 
    rangeInit = rangeMax / 5;                       % A range initialization value.
    rangeSliderValueInit = rangeInit / rangeMax;    

    % The following line may be used in future BMElib GUI versions.
    % We look to find the index of the first lowest of the covModS.emptyspot field
    % values. It should be 0 and indicate there is no model stored in this index. 
    % This approach is helpful if the user is to delete models at will (and not
    % only offered to delete all of them together as in the early GUI version).
    %
    % structIndex = min(find(covModS.emptySpot));   % Available spot to add model.
    
    switch nestedScounter  % Current version accepts 2 nested models
      case 1               % The first model gets max sill and range.
        covModS(nestedScounter).sill = var(cPtValuesDataToProcess);
        set(handles.sillEdit,'String',num2str(var(cPtValuesDataToProcess)));
        set(handles.sillSlider,'Value',1);
        %
        % Initialize the model range to be 20% of the maximum correlation range.
        % We need to know which of the experimental covariances currently shows
        % so that we can use its maxCorrRange.
        %
        covModS(nestedScounter).range = rangeInit;
        set(handles.rangeEdit,'String',num2str(rangeInit));      % Update range box
        set(handles.rangeSlider,'Value',rangeSliderValueInit);   % ...and slider.
        covModelS = {covModS(1).modelName};                      % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
      case 2               % With a second nested model: Both sills initialized
        sillMax = var(cPtValuesDataToProcess);
        sillHalf = sillMax / 2;            % ...and equally set to half variance.
        covModS(1).sill = sillHalf; 
        covModS(2).sill = sillHalf; 
        set(handles.sillEdit,'String',num2str(sillHalf));
        sillSliderValue = sillHalf / sillMax;
        set(handles.sillSlider,'Value',sillSliderValue);
        covModS(nestedScounter).range = rangeInit;
        set(handles.rangeEdit,'String',num2str(rangeInit));      % Update range box
        set(handles.rangeSlider,'Value',rangeSliderValueInit);   % ...and slider.
        covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range],...
                     [covModS(2).sill covModS(2).range]};        % BMElib covparam
    end

    covModS(nestedScounter).emptySpot = 0; % This spot is now occupied.
    covModS(nestedScounter).modOk = 1;     % Model initialization is complete.
    
    set(handles.addModelMenu,'Value',1);   % Prompt user for next model.
    
    displayString = ['Added model ' num2str(nestedScounter) '/' ...
                     num2str(maxModels) '. You may now adjust its parameters'];
    set(handles.feedbackEdit,'String',displayString);

    % Produce plot based on the model that was just added
    %
    set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
    if get(handles.extFigureBox,'Value')   % Separate figure or not?
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
      figure;
    else
      axes(handles.spatialCovAxes)
    end  
    if choice == 1
      hCov = plot([0 covExpS(choice).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
      hold on;
    elseif choice == 2
      hCov = plot([0 covExpS(choice).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
      hold on;       
    elseif choice == 3
      hCov = plot([0 covExpS(choice).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
      hold on;
    end
    %
    maxDistance = covExpS(choice).maxCorrRange;
    modelPoints = 50;                      % Obtain model covariance at 50 points.
    distances = 0:round(maxDistance)/modelPoints:maxDistance;
    [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
    hmCov = plot(distances,mCov);
    hold off;
    %
    legend([hCov hmCov],[covExpS(choice).anisotropyString 'Experimental'],...
                        'Covariance Model');
    xlabel('Lag (in distance units)');
    ylabel('Covariance');
    
    
    
    
  else

    if modelType~=1

      errordlg({['The maximum allowed nested models ('...
                 num2str(maxModels) ') are currently used.'];...
                'Can not add further models unless existing ones are deleted.'},...
                'Invalid Action')
      set(handles.addModelMenu,'Value',1);

    end
  end
else
  errordlg({'There is no experimental covariance information present';...
            'to fit a model on.';...
            'Please load or generate this information first.'},...
            'Invalid Action')
end 




% --- Executes during object creation, after setting all properties.
function addModelMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in currModelMenu.
function currModelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to currModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns currModelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from currModelMenu
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global rangeMin rangeMax

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
% Set the sill values to be between 0 and the data variance.
sillMin = 0;
sillMax = var(cPtValuesDataToProcess);

currModel = get(handles.currModelMenu,'Value');

if nestedScounter    % If nestedScounter non-zero, then models are present
 
  if currModel ~= 1  % Values higher than 1 correspond to models

    modIndx = currModel - 1;
    modelType = covModS(modIndx).model;
    displayString = ['Showing model ' num2str(modIndx) ' of ' num2str(nestedScounter)];
    set(handles.feedbackEdit,'String',displayString);
    
    if ~isempty(modelType) % If this model slot contains a defined model
        
      switch modelType
        case 1
          set(handles.modelTypeEdit,'String','EXP');  % Designate exponential model
        case 2
          set(handles.modelTypeEdit,'String','GAU');  % Designate gaussian model
        case 3
          set(handles.modelTypeEdit,'String','SPH');  % Designate spherical model
      end
      currSill = covModS(modIndx).sill;
      set(handles.sillEdit,'String',num2str(currSill));
      set(handles.sillSlider,'Value',currSill/sillMax);
      currRange = covModS(modIndx).range;
      set(handles.rangeEdit,'String',num2str(currRange));
      set(handles.rangeSlider,'Value',currRange/rangeMax);
      
    else                   % This model slot is empty. Can not make current
        
      set(handles.currModelMenu,'Value',1);             % Make menu point back to 0
      displayString = 'No model defined in this slot to set as current';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.modelTypeEdit,'String','');
      set(handles.sillEdit,'String','');
      set(handles.sillSlider,'Value',0);
      set(handles.rangeEdit,'String','');
      set(handles.rangeSlider,'Value',0);
      
    end

  else               % Value 1 in the menu is the title

    set(handles.modelTypeEdit,'String','');
    set(handles.sillEdit,'String','');
    set(handles.sillSlider,'Value',0);
    set(handles.rangeEdit,'String','');
    set(handles.rangeSlider,'Value',0);
    displayString = 'Showing no model';
    set(handles.feedbackEdit,'String',displayString);
      
  end

else                 % nestedScounter = 0 and no models have been defined yet 

  set(handles.currModelMenu,'Value',1);             % Make menu point back to 0
  displayString = 'Can not set current model. No models defined yet';
  set(handles.feedbackEdit,'String',displayString);

end




% --- Executes during object creation, after setting all properties.
function currModelMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function modelTypeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to modelTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelTypeEdit as text
%        str2double(get(hObject,'String')) returns contents of modelTypeEdit as a double
global covModS

% The following is to prevent the user from typing random material in the box
%
currModel = get(handles.currModelMenu,'Value');  % Ranges from 1 to maxModels+1.
modIndx = currModel - 1;                         % Ranges from 0 to maxModels.
if modIndx    % If current model menu points to a defined model
  modelType = covModS(modIndx).model;
  switch modelType
    case 1
      set(handles.modelTypeEdit,'String','EXP');  % Designate exponential model
    case 2
      set(handles.modelTypeEdit,'String','GAU');  % Designate gaussian model
    case 3
      set(handles.modelTypeEdit,'String','SPH');  % Designate spherical model
  end
else         % If current model menu does not point to a defined model  
  set(handles.modelTypeEdit,'String','');
end




% --- Executes during object creation, after setting all properties.
function modelTypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function sillSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sillSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS
global sillWithinBounds

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Set the sill values to be between 0 and the data variance.
% The handle values range from 0 to 1, so a transformation is necessary. 
sillMin = 0;
sillMax = var(cPtValuesDataToProcess);

currModel = get(handles.currModelMenu,'Value');  % Ranges from 1 to maxModels+1.

% This function version is valid for a max number of two nested models.
% A proper adjustment is necessary to handle a larger number of models.
switch nestedScounter  
    
  case 0   % No models present

    set(handles.sillSlider,'Value',0);
    set(handles.sillEdit,'String','');
    displayString = 'No models defined yet. Can not set sill';
    set(handles.feedbackEdit,'String',displayString);
    sillWithinBounds = 1;

  case 1   % 1 model present: The sill is the value of data variance.
      
    switch currModel
        
      case 1
          
        set(handles.sillSlider,'Value',0);
        set(handles.sillEdit,'String','');
        displayString = 'Current model unspecified. Can not set sill';
        set(handles.feedbackEdit,'String',displayString); 
        sillWithinBounds = 1;
        
      case 2
          
        modIndx = currModel - 1;                         % Refers to model #1.
        set(handles.sillSlider,'Value',1);               % Set max sill
        set(handles.sillEdit,'String',num2str(sillMax)); % Adjust edit box
        covModS(modIndx).sill = sillMax;                 % Adjust model sill
        displayString = 'Only 1 model present. Sill set to max';
        set(handles.feedbackEdit,'String',displayString);
        
        sillWithinBounds = 1;
    
        % Update plot
        covModelS = {covModS(1).modelName};              % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range]};% BMElib covparam
        %
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');
       
    end

  case 2   % 2 models present: Their sills add up to the data variance.
  
    switch currModel
        
      case 1
          
        set(handles.sillSlider,'Value',0);
        set(handles.sillEdit,'String','');
        displayString = 'Current model unspecified. Can not set sill';
        set(handles.feedbackEdit,'String',displayString);   
        sillWithinBounds = 1;
        
      case 2
          
        modIndx = currModel - 1;
        sillSliderValue = get(handles.sillSlider,'Value');
        userSelectedSill = sillSliderValue * sillMax;
        set(handles.sillEdit,'String',num2str(userSelectedSill));
        % Set sill for current model #1 and adjust sill for model #2.
        covModS(modIndx).sill = userSelectedSill;               % Model #1
        covModS(modIndx+1).sill = sillMax - userSelectedSill;   % Model #2
        displayString = 'Sills adjusted for present models';
        set(handles.feedbackEdit,'String',displayString);    

        sillWithinBounds = 1;
        displayString = 'Sills adjusted for present models';
        set(handles.feedbackEdit,'String',displayString);   
        
        % Update plot
        covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range],...
                     [covModS(2).sill covModS(2).range]};        % BMElib covparam
        %
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');

      case 3
          
        modIndx = currModel - 1;
        sillSliderValue = get(handles.sillSlider,'Value');
        userSelectedSill = sillSliderValue * sillMax;
        set(handles.sillEdit,'String',num2str(userSelectedSill));
        % Set sill for current model #2 and adjust sill for model #1.
        covModS(modIndx).sill = userSelectedSill;               % Model #2
        covModS(modIndx-1).sill = sillMax - userSelectedSill;   % Model #1 
        displayString = 'Sills adjusted for present models';
        set(handles.feedbackEdit,'String',displayString);    

        sillWithinBounds = 1;
        displayString = 'Sills adjusted for present models';
        set(handles.feedbackEdit,'String',displayString);   

        % Update plot
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range],...
                     [covModS(2).sill covModS(2).range]};        % BMElib covparam
        %
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');

      end

    otherwise

      errordlg({'ip305p1covarAnal.m:sillSlider:';...
              'More than 2 nested models are available';...
              'and the sill slider function has not been properly updated.';...
              'GUI developer needs to correct the discrepancy.'},...
              'GUI software Error')

end




% --- Executes during object creation, after setting all properties.
function sillSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sillSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function sillEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sillEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sillEdit as text
%        str2double(get(hObject,'String')) returns contents of sillEdit as a double
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS
global sillWithinBounds

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Set the sill values to be between 0 and the data variance.
% The handle values range from 0 to 1, so a transformation is necessary. 
sillMin = 0;
sillMax = var(cPtValuesDataToProcess);

currModel = get(handles.currModelMenu,'Value');  % Ranges from 1 to maxModels+1.

% This function version is valid for a max number of two nested models.
% A proper adjustment is necessary to handle a larger number of models.
switch nestedScounter  
    
  case 0   % No models present

    set(handles.sillSlider,'Value',0);
    set(handles.sillEdit,'String','');
    displayString = 'No models defined yet. Can not set sill';
    set(handles.feedbackEdit,'String',displayString);
    sillWithinBounds = 1;

  case 1   % 1 model present: The sill is the value of data variance.
      
    switch currModel
      
      case 1
        
        set(handles.sillSlider,'Value',0);
        set(handles.sillEdit,'String','');
        displayString = 'Current model unspecified. Can not set sill';
        set(handles.feedbackEdit,'String',displayString);    
        sillWithinBounds = 1;
        
      case 2
        
        if isempty(str2num(get(handles.sillEdit,'String'))) % If empty or non-numeric
         
          set(handles.sillSlider,'Value',0);
          set(handles.sillEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Sill reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;
          set(handles.sillSlider,'Value',1);               % Set max sill
          set(handles.sillEdit,'String',num2str(sillMax)); % Adjust edit box
          covModS(modIndx).sill = sillMax;                 % Adjust model sill
          displayString = 'Only 1 model present. Sill set to max';
          set(handles.feedbackEdit,'String',displayString);

          sillWithinBounds = 1;

          % Update plot
          covModelS = {covModS(1).modelName};              % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range]};% BMElib covparam
          %
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
          
        end

    end

  case 2   % 2 models present: Their sills add up to the data variance.
  
    switch currModel
        
      case 1
          
        set(handles.sillSlider,'Value',0);
        set(handles.sillEdit,'String','');
        displayString = 'Current model unspecified. Can not set sill';
        set(handles.feedbackEdit,'String',displayString);
        sillWithinBounds = 1;
        
      case 2
          
        if isempty(str2num(get(handles.sillEdit,'String'))) % If empty or non-numeric
         
          set(handles.sillSlider,'Value',0);
          set(handles.sillEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Sill reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;
          userSelectedSill = str2num(get(handles.sillEdit,'String'));
          if userSelectedSill<0
            sillWithinBounds = 0;
            userSelectedSill = 0;         % Do not accept negative sills
            set(handles.sillSlider,'Value',0);
            set(handles.sillEdit,'String','0');
            displayString = 'Sill must be a non-negative value. Sill set to 0';
            set(handles.feedbackEdit,'String',displayString);
          elseif userSelectedSill>sillMax % If value in box exceeds variance
            sillWithinBounds = 0;
            userSelectedSill = sillMax;
            set(handles.sillSlider,'Value',1);
            set(handles.sillEdit,'String',num2str(sillMax));
            displayString = 'Value entered exceeds variance. Sill set to max';
            set(handles.feedbackEdit,'String',displayString);
          else
            sillWithinBounds = 1;
            sillSliderValue = userSelectedSill / sillMax;
            set(handles.sillSlider,'Value',sillSliderValue);
          end
          covModS(modIndx).sill = userSelectedSill;               % Model #1
          covModS(modIndx+1).sill = sillMax - userSelectedSill;   % Model #2

          if sillWithinBounds
            displayString = 'Sills adjusted for present models';
            set(handles.feedbackEdit,'String',displayString);
          end

          % Update plot
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range],...
            [covModS(2).sill covModS(2).range]};        % BMElib covparam
          %
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
          
        end

      case 3
          
        if isempty(str2num(get(handles.sillEdit,'String'))) % If empty or non-numeric
         
          set(handles.sillSlider,'Value',0);
          set(handles.sillEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Sill reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;
          userSelectedSill = str2num(get(handles.sillEdit,'String'));
          if userSelectedSill<0
            sillWithinBounds = 0;
            userSelectedSill = 0;
            set(handles.sillSlider,'Value',0);
            set(handles.sillEdit,'String','0');
            displayString = 'Sill must be a non-negative value. Sill set to 0';
            set(handles.feedbackEdit,'String',displayString);
          end
          if userSelectedSill>sillMax     % If value in box exceeds variance
            sillWithinBounds = 0;
            userSelectedSill = sillMax;
            set(handles.sillSlider,'Value',1);
            set(handles.sillEdit,'String',num2str(sillMax));
            displayString = 'Value entered exceeds variance. Sill set to max';
            set(handles.feedbackEdit,'String',displayString);
          else
            sillWithinBounds = 1;
            sillSliderValue = userSelectedSill / sillMax;
            set(handles.sillSlider,'Value',sillSliderValue);
          end
          covModS(modIndx).sill = userSelectedSill;               % Model #2
          covModS(modIndx-1).sill = sillMax - userSelectedSill;   % Model #1
          displayString = 'Sills adjusted for present models';
          set(handles.feedbackEdit,'String',displayString);

          if sillWithinBounds
            displayString = 'Sills adjusted for present models';
            set(handles.feedbackEdit,'String',displayString);
          end

          % Update plot
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range],...
            [covModS(2).sill covModS(2).range]};        % BMElib covparam
          %
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
        
        end
        
      end
    
    otherwise

      errordlg({'ip305p1covarAnal.m:sillEdit:';...
              'More than 2 nested models are available';...
              'and the silledit box function has not been properly updated.';...
              'GUI developer needs to correct the discrepancy.'},...
              'GUI software Error')

end




% --- Executes during object creation, after setting all properties.
function sillEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sillEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function rangeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS
global rangeMin rangeMax rangeWithinBounds

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Set the range values to be between 0 and the current max correlation range.
% The handle values range from 0 to 1, so a transformation is necessary. 
rangeMin = 1e-6;                % We do not want 0 in the denominator
rangeMax = covExpS(choice).maxCorrRange; 

currModel = get(handles.currModelMenu,'Value');  % Ranges from 1 to maxModels+1.

switch nestedScounter  
    
  case 0   % No models present

    set(handles.rangeSlider,'Value',0);
    set(handles.rangeEdit,'String','');
    displayString = 'No models defined yet. Can not set range';
    set(handles.feedbackEdit,'String',displayString);
    rangeWithinBounds = 1;

  case 1   % 1 model present
      
    switch currModel
        
      case 1
          
        set(handles.rangeSlider,'Value',0);
        set(handles.rangeEdit,'String','');
        displayString = 'Current model unspecified. Can not set range';
        set(handles.feedbackEdit,'String',displayString); 
        rangeWithinBounds = 1;
        
      case 2
          
        modIndx = currModel - 1;                         % Refers to model #1.
        rangeSliderValue = get(handles.rangeSlider,'Value');
        userSelectedRange = rangeSliderValue * rangeMax;
        set(handles.rangeEdit,'String',num2str(userSelectedRange));
        covModS(modIndx).range = userSelectedRange;      % Set range for current model.
        displayString = 'Range adjusted for present model';
        set(handles.feedbackEdit,'String',displayString);    
        
        rangeWithinBounds = 1;

        % Update plot
        covModelS = {covModS(1).modelName};              % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range]};% BMElib covparam
        %
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');
       
    end

  case 2   % 2 models present
  
    switch currModel
        
      case 1
          
        set(handles.rangeSlider,'Value',0);
        set(handles.rangeEdit,'String','');
        displayString = 'Current model unspecified. Can not set range';
        set(handles.feedbackEdit,'String',displayString);   
        rangeWithinBounds = 1;
        
      case 2
          
        modIndx = currModel - 1;                         % Refers to model #1.
        rangeSliderValue = get(handles.rangeSlider,'Value');
        userSelectedRange = rangeSliderValue * rangeMax;
        set(handles.rangeEdit,'String',num2str(userSelectedRange));
        covModS(modIndx).range = userSelectedRange;      % Set range for current model.
        
        rangeWithinBounds = 1;
        displayString = 'Range adjusted for present model';
        set(handles.feedbackEdit,'String',displayString);    

        % Update plot
        covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range],...
                     [covModS(2).sill covModS(2).range]};        % BMElib covparam
        %
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');

      case 3
          
        modIndx = currModel - 1;                         % Refers to model #2.
        rangeSliderValue = get(handles.rangeSlider,'Value');
        userSelectedRange = rangeSliderValue * rangeMax;
        set(handles.rangeEdit,'String',num2str(userSelectedRange));
        covModS(modIndx).range = userSelectedRange;      % Set range for current model.

        rangeWithinBounds = 1;
        displayString = 'Range adjusted for present model';
        set(handles.feedbackEdit,'String',displayString);    

        % Update plot
        set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
        covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
        covParamS = {[covModS(1).sill covModS(1).range],...
                     [covModS(2).sill covModS(2).range]};        % BMElib covparam
        %
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.spatialCovAxes)
          image(imread('guiResources/ithinkPic.jpg'));
          axis image
          axis off
          figure;
        else
          axes(handles.spatialCovAxes)
        end  
        if choice == 1
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
          hold on;
        elseif choice == 2
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
          hold on;
        elseif choice == 3
          hCov = plot([0 covExpS(choice).covDistance'],...
                      [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
          hold on;
        end
        %
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        %
        legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                            'Covariance Model');
        xlabel('Lag (in distance units)');
        ylabel('Covariance');

      end

    otherwise

      errordlg({'ip305p1covarAnal.m:rangeSlider:';...
              'More than 2 nested models are available';...
              'and the range slider function has not been properly updated.';...
              'GUI developer needs to correct the discrepancy.'},...
              'GUI software Error')

end




% --- Executes during object creation, after setting all properties.
function rangeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function rangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rangeEdit as text
%        str2double(get(hObject,'String')) returns contents of rangeEdit as a double
global zhDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS
global rangeMin rangeMax rangeWithinBounds

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Set the range values to be between 0 and the current max correlation range.
% The handle values range from 0 to 1, so a transformation is necessary. 
rangeMin = 1e-6;                % We do not want 0 in the denominator
rangeMax = covExpS(choice).maxCorrRange; 

rangeInit = rangeMax / 5;  % Use this initialization value for requests exceeding max.
rangeSliderValueInit = rangeInit / rangeMax;     % Subsequently to the slider.

currModel = get(handles.currModelMenu,'Value');  % Ranges from 1 to maxModels+1.

% This function version is valid for a max number of two nested models.
% A proper adjustment is necessary to handle a larger number of models.
switch nestedScounter  
    
  case 0   % No models present

    set(handles.rangeSlider,'Value',0);
    set(handles.rangeEdit,'String','');
    displayString = 'No models defined yet. Can not set range';
    set(handles.feedbackEdit,'String',displayString);
    rangeWithinBounds = 1;

  case 1   % 1 model present
      
    switch currModel
        
      case 1
          
        set(handles.rangeSlider,'Value',0);
        set(handles.rangeEdit,'String','');
        displayString = 'Current model unspecified. Can not set range';
        set(handles.feedbackEdit,'String',displayString); 
        rangeWithinBounds = 1;
       
      case 2
          
        if isempty(str2num(get(handles.rangeEdit,'String'))) % If empty or non-numeric
         
          set(handles.rangeSlider,'Value',0);
          set(handles.rangeEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Range reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;                         % Refers to model #1.
          userSelectedRange = str2num(get(handles.rangeEdit,'String'));
          if userSelectedRange<0
            rangeWithinBounds = 0;
            userSelectedRange = rangeMin;          % Do not accept negative ranges
            set(handles.rangeSlider,'Value',rangeMin);
            set(handles.rangeEdit,'String','0');
            displayString = 'Range must be a non-negative value. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          elseif userSelectedRange>rangeMax     % If value in box exceeds variance
            rangeWithinBounds = 0;
            userSelectedRange = rangeInit;
            set(handles.rangeSlider,'Value',rangeSliderValueInit);
            set(handles.rangeEdit,'String',num2str(rangeInit));
            displayString = 'Value entered exceeds max range. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          else
            rangeWithinBounds = 1;
            rangeSliderValue = userSelectedRange / rangeMax;
            set(handles.rangeSlider,'Value',rangeSliderValue);
          end
          covModS(modIndx).range = userSelectedRange;      % Set range for current model.

          if rangeWithinBounds
            displayString = 'Range adjusted for present model';
            set(handles.feedbackEdit,'String',displayString);
          end

          % Update plot
          covModelS = {covModS(1).modelName};              % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range]};% BMElib covparam
          %
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
          
        end

    end

  case 2   % 2 models present
  
    switch currModel
        
      case 1
          
        set(handles.rangeSlider,'Value',0);
        set(handles.rangeEdit,'String','');
        displayString = 'Current model unspecified. Can not set range';
        set(handles.feedbackEdit,'String',displayString);
        rangeWithinBounds = 1;
        
      case 2
          
        if isempty(str2num(get(handles.rangeEdit,'String'))) % If empty or non-numeric
         
          set(handles.rangeSlider,'Value',0);
          set(handles.rangeEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Range reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;                         % Refers to model #1.
          userSelectedRange = str2num(get(handles.rangeEdit,'String'));
          if userSelectedRange<0
            rangeWithinBounds = 0;
            userSelectedRange = rangeMin;          % Do not accept negative ranges
            set(handles.rangeSlider,'Value',rangeMin);
            set(handles.rangeEdit,'String','0');
            displayString = 'Range must be a non-negative value. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          elseif userSelectedRange>rangeMax     % If value in box exceeds variance
            rangeWithinBounds = 0;
            userSelectedRange = rangeInit;
            set(handles.rangeSlider,'Value',rangeSliderValueInit);
            set(handles.rangeEdit,'String',num2str(rangeInit));
            displayString = 'Value entered exceeds max range. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          else
            rangeWithinBounds = 1;
            rangeSliderValue = userSelectedRange / rangeMax;
            set(handles.rangeSlider,'Value',rangeSliderValue);
          end
          covModS(modIndx).range = userSelectedRange;      % Set range for current model.

          if rangeWithinBounds
            displayString = 'Range adjusted for present model';
            set(handles.feedbackEdit,'String',displayString);
          end

          % Update plot
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range],...
            [covModS(2).sill covModS(2).range]};        % BMElib covparam
          %
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
          
        end

      case 3
          
        if isempty(str2num(get(handles.rangeEdit,'String'))) % If empty or non-numeric
         
          set(handles.rangeSlider,'Value',0);
          set(handles.rangeEdit,'String','0');
          displayString = 'Invalid input: Enter only numeric values. Range reset';
          set(handles.feedbackEdit,'String',displayString);    
        
        else  
        
          modIndx = currModel - 1;                         % Refers to model #2.
          userSelectedRange = str2num(get(handles.rangeEdit,'String'));
          if userSelectedRange<0
            rangeWithinBounds = 0;
            userSelectedRange = rangeMin;          % Do not accept negative ranges
            set(handles.rangeSlider,'Value',rangeMin);
            set(handles.rangeEdit,'String','0');
            displayString = 'Range must be a non-negative value. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          elseif userSelectedRange>rangeMax     % If value in box exceeds variance
            rangeWithinBounds = 0;
            userSelectedRange = rangeInit;
            set(handles.rangeSlider,'Value',rangeSliderValueInit);
            set(handles.rangeEdit,'String',num2str(rangeInit));
            displayString = 'Value entered exceeds max range. Range initialized';
            set(handles.feedbackEdit,'String',displayString);
          else
            rangeWithinBounds = 1;
            rangeSliderValue = userSelectedRange / rangeMax;
            set(handles.rangeSlider,'Value',rangeSliderValue);
          end
          covModS(modIndx).range = userSelectedRange;      % Set range for current model.

          if rangeWithinBounds
            displayString = 'Range adjusted for present model';
            set(handles.feedbackEdit,'String',displayString);
          end

          % Update plot
          set(handles.graphTypeMenu,'Value',5);  % 5 refers to modelled covariance
          covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range],...
            [covModS(2).sill covModS(2).range]};        % BMElib covparam
          %
          if get(handles.extFigureBox,'Value')   % Separate figure or not?
            axes(handles.spatialCovAxes)
            image(imread('guiResources/ithinkPic.jpg'));
            axis image
            axis off
            figure;
          else
            axes(handles.spatialCovAxes)
          end
          if choice == 1
            hCov = plot([0 covExpS(choice).covDistance'],...
              [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
            hold on;
          elseif choice == 2
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
            hold on;
          elseif choice == 3
            hCov = plot([0 covExpS(choice).covDistance'],...
                        [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
            hold on;
          end
          %
          maxDistance = covExpS(choice).maxCorrRange;
          modelPoints = 50;                      % Obtain model covariance at 50 points.
          distances = 0:round(maxDistance)/modelPoints:maxDistance;
          [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
          hmCov = plot(distances,mCov);
          hold off;
          %
          legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
            'Covariance Model');
          xlabel('Lag (in distance units)');
          ylabel('Covariance');
          
        end

      end
    
    otherwise

      errordlg({'ip305p1covarAnal.m:rangeEdit:';...
              'More than 2 nested models are available';...
              'and the rangeedit box function has not been properly updated.';...
              'GUI developer needs to correct the discrepancy.'},...
              'GUI software Error')

end




% --- Executes during object creation, after setting all properties.
function rangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in saveModDataButton.
function saveModDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveModDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModelS covParamS
global maxCorrRangeS lagsNumberS lagsLimitsS
global covModS covExpS nestedScounter
global displayString
global covInputFile covInputPath

covModDataFile = 'covSmodelInfo.txt';
initialDir = pwd;              % Save the current directory path

if nestedScounter              % If models have been defined
    
  if ~ischar(covInputPath)              % If user has not shown where data is kept
    [covModDataFile,covOutPath] = ...
        uiputfile('*.txt','Save covariance model info in a text file:');	
    if ~isequal([covModDataFile,covOutPath],[0,0]) % If 'Cancel' selected, abort, else
      File = fullfile(covOutPath,covModDataFile);
      fid = fopen(File,'w');
      switch nestedScounter
        case 1
          mod1 = covModS(1).model;
          switch mod1
            case 1
              mod1Name = 'Exponential';
            case 2
              mod1Name = '  Gaussian ';
            case 3
              mod1Name = ' Spherical ';
          end
          fprintf(fid,'MODEL TYPE       SILL     RANGE\n%s%10.2f%10.2f',...
                      mod1Name,covModS(1).sill,covModS(1).range);
          fclose(fid);
        case 2
          mod1 = covModS(1).model;
          switch mod1
            case 1
              mod1Name = 'Exponential';
            case 2
              mod1Name = '  Gaussian ';
            case 3
              mod1Name = ' Spherical ';
          end
          mod2 = covModS(2).model;
          switch mod2
            case 1
              mod2Name = 'Exponential';
            case 2
              mod2Name = '  Gaussian ';
            case 3
              mod2Name = ' Spherical ';
          end
          fprintf(fid,'MODEL TYPE      SILL    RANGE\n%s%10.2f%10.2f\n%s%10.2f%10.2f',...
                      mod1Name,covModS(1).sill,covModS(1).range,...
                      mod2Name,covModS(2).sill,covModS(2).range);
          fclose(fid);
        otherwise
          errordlg({'ip305p1covarAnal.m:saveModDataButton:';...
              'More than 2 nested models are available';...
              'and the saveModDataButton function has not been properly updated.';...
              'GUI developer needs to correct the discrepancy.'},...
              'GUI software Error')
      end
      displayString = ['Saved model info in ' covModDataFile];
      set(handles.feedbackEdit,'String',displayString);
    end
  else                                  % If the user has made use of a path
    covOutPath = covInputPath;
    File = fullfile(covOutPath,covModDataFile);
    fid = fopen(File,'w');
    switch nestedScounter
      case 1
        mod1 = covModS(1).model;
        switch mod1
          case 1
            mod1Name = 'Exponential';
          case 2
            mod1Name = '  Gaussian ';
          case 3
            mod1Name = ' Spherical ';
        end
        fprintf(fid,'MODEL TYPE       SILL     RANGE\n%s%10.2f%10.2f',...
                    mod1Name,covModS(1).sill,covModS(1).range);
        fclose(fid);
      case 2
        mod1 = covModS(1).model;
        switch mod1
          case 1
            mod1Name = 'Exponential';
          case 2
            mod1Name = '  Gaussian ';
          case 3
            mod1Name = ' Spherical ';
        end
        mod2 = covModS(2).model;
        switch mod2
          case 1
            mod2Name = 'Exponential';
          case 2
            mod2Name = '  Gaussian ';
          case 3
            mod2Name = ' Spherical ';
        end
        fprintf(fid,'MODEL TYPE       SILL     RANGE\n%s%10.2f%10.2f\n%s%10.2f%10.2f',...
                    mod1Name,covModS(1).sill,covModS(1).range,...
                    mod2Name,covModS(2).sill,covModS(2).range);
        fclose(fid);
      otherwise
        errordlg({'ip305p1covarAnal.m:saveModDataButton:';...
            'More than 2 nested models are available';...
            'and the saveModDataButton function has not been properly updated.';...
            'GUI developer needs to correct the discrepancy.'},...
            'GUI software Error')
    end
    displayString = ['Saved model info in ' covModDataFile];
    set(handles.feedbackEdit,'String',displayString);
  end

  cd (initialDir);                          % Return to working directory

else
    
      displayString = 'No models defined yet. Save aborted';
      set(handles.feedbackEdit,'String',displayString);

end



% --- Executes on button press in eraseModelsButton.
function eraseModelsButton_Callback(hObject, eventdata, handles)
% hObject    handle to eraseModelsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModS covExpS nestedScounter
global displayString

user_response = ip105p2getModWarning('Title','Confirm Erasing Models');
switch lower(user_response)
  case 'no'
    % Do nothing
  case 'yes'
    covModS = struct('model',{[],[]},...        % 2 spots for up to 2
                     'sill',{[],[]},...         % nested components. This
                     'range',{[],[]},...        % can change in future versions.
                     'modelName',{[],[]},...    % To store BMElib model names   
                     'emptySpot',{[1],[1]},...  % An index for the struct
                     'modIndex',{[0 0]},...     % Index of current model showing
                     'modOk',{[0],[0]});
    nestedScounter = 0;    
    % Reset the counter at the modelsPresentEdit box...
    set(handles.modelsPresentEdit,'String',num2str(nestedScounter));
    % Reset the current add model value in the addModelMenu (1 shows title)...
    set(handles.addModelMenu,'Value',1);
    % Reset the current model value display in the currModelMenu (1 shows 0)...
    set(handles.currModelMenu,'Value',1);
    % Reset the current model type display in the modelTypeEdit box...
    set(handles.modelTypeEdit,'String','');
    % Reset the current model characteristics...
    set(handles.sillSlider,'Value',0);
    set(handles.sillEdit,'String','');
    set(handles.rangeSlider,'Value',0);
    set(handles.rangeEdit,'String','');
    % Reset the plot on display...
    set(handles.graphTypeMenu,'Value',1);

    displayString = 'All fitted models info has been cleared';
    set(handles.feedbackEdit,'String',displayString);
end  




% --- Executes on button press in startOverButton.
function startOverButton_Callback(hObject, eventdata, handles)
% hObject    handle to startOverButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global experimentalCovOk 
global covDistanceS experimCovS pairsNumberS

user_response = ip105p3startOverWarning('Title','Confirm Erasing Models');
switch lower(user_response)
  case 'no'
    % Do nothing
  case 'yes'
    clear experimentalCovOk covDistanceS experimCovS pairsNumberS
    delete(handles.figure1);                            % Close current window...
    ip305p1covarAnal('Title','Exploratory Analysis');   % ...and re-load screen.
end




% --- Executes on selection change in graphTypeMenu.
function graphTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphTypeMenu
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covModS covExpS nestedScounter
global displayString
global covModelS covParamS

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Plot the experimental covariance outcome
% If we deal with all-directions, include in the plot the distance at s=0 
% where the covariance is the data variance. Otherwise do not include s=0
% because the curve may range higher or lower than the average direction.
%
choice = get(handles.graphTypeMenu,'Value');
switch choice
  case 1     % Displays experimental all-directional spatial covariance
    if covExpS(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
       
      hCov = plot([0 covExpS(choice).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
      legend(hCov,covExpS(choice).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
  case 2     % Displays experimental E-W spatial covariance
    if covExpS(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
       
      hCov = plot([covExpS(choice).covDistance'],...
                  [covExpS(choice).experimCov'],'m<');
      legend(hCov,covExpS(choice).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
  case 3     % Displays experimental N-S spatial covariance
    if covExpS(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
       
      hCov = plot([covExpS(choice).covDistance'],...
                  [covExpS(choice).experimCov'],'m^');
      legend(hCov,covExpS(choice).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
  case 4     % Displays all experimental spatial covariances
    if covExpS(1).dirOk & ~covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      legend([hCov1],covExpS(1).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      legend([hCov2],covExpS(2).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 3;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      legend([hCov3],covExpS(3).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      hold off;
      legend([hCov1,hCov2],covExpS(1).anisotropyString...
                          ,covExpS(2).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold off;
      legend([hCov1,hCov3],covExpS(1).anisotropyString...
                          ,covExpS(3).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold off;
      legend([hCov2,hCov3],covExpS(2).anisotropyString...
                          ,covExpS(3).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold off;
      legend([hCov1,hCov2,hCov3],covExpS(1).anisotropyString...
                                ,covExpS(2).anisotropyString...
                                ,covExpS(3).anisotropyString);
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    else
      displayString = 'No data available for any plot';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
  case 5     % Displays experimental and modelled covariances.
    choice = get(handles.anisotropyMenu,'Value');
    if covExpS(choice).dirOk & nestedScounter           % If data are available
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      displayString = 'Plotting experimental and modelled covariances';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));  
      if choice == 1
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'ro');
        hold on;
      elseif choice == 2
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m<');
        hold on;
      elseif choice == 3
        hCov = plot([0 covExpS(choice).covDistance'],...
                    [var(cPtValuesDataToProcess) covExpS(choice).experimCov'],'m^');
        hold on;
      end
      switch nestedScounter  % Use appropriate data based on available models
        case 1
          covModelS = {covModS(1).modelName};                      % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
        case 2   
          covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
          covParamS = {[covModS(1).sill covModS(1).range],...
                       [covModS(2).sill covModS(2).range]};        % BMElib covparam
        otherwise
          errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                'More than 2 nested models are available';...
                'and the graphType Menu function has not been properly updated.';...
                'GUI developer needs to correct the discrepancy.'},...
                'GUI software Error')
      end
      maxDistance = covExpS(choice).maxCorrRange;
      modelPoints = 50;                      % Obtain model covariance at 50 points.
      distances = 0:round(maxDistance)/modelPoints:maxDistance;
      [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
      hmCov = plot(distances,mCov);
      hold off;
      %
      legend([hCov hmCov],[covExpS(choice).anisotropyString ' Experimental'],...
                          'Covariance Model');
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
    else
      displayString = 'Some data not available. Can not display plot';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
  case 6     % Displays modelled and all experimental covariances.
    if covExpS(1).dirOk & ~covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov1,hmCov],[covExpS(1).anisotropyString ' Experimental'],...
                             'Covariance Model');
      else
        hold off;
        legend([hCov1],covExpS(1).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov2 = plot([covExpS(2).covDistance'],...
                  [covExpS(2).experimCov'],'m<');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov2,hmCov],[covExpS(2).anisotropyString ' Experimental'],...
                             'Covariance Model');
      else
        hold off;
        legend([hCov2],covExpS(2).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 3;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov3 = plot([covExpS(3).covDistance'],...
                  [covExpS(3).experimCov'],'m^');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov3,hmCov],[covExpS(3).anisotropyString ' Experimental'],...
                             'Covariance Model');
      else
        hold off;
        legend([hCov3],covExpS(3).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & covExpS(2).dirOk & ~covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov2 = plot([covExpS(2).covDistance'],...
                  [covExpS(2).experimCov'],'m<');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov1,hCov2,hmCov],[covExpS(1).anisotropyString ' Experimental'],...
                                   [covExpS(2).anisotropyString ' Experimental'],...
                                   'Covariance Model');
      else
        hold off;
        legend([hCov1,hCov2],covExpS(1).anisotropyString...
                            ,covExpS(2).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & ~covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov1,hCov3,hmCov],[covExpS(1).anisotropyString ' Experimental'],...
                                   [covExpS(3).anisotropyString ' Experimental'],...
                                   'Covariance Model');
      else
        hold off;
        legend([hCov1,hCov3],covExpS(1).anisotropyString...
                            ,covExpS(3).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov2,hCov3,hmCov],[covExpS(2).anisotropyString ' Experimental'],...
                                   [covExpS(3).anisotropyString ' Experimental'],...
                                   'Covariance Model');
      else
        hold off;
        legend([hCov2,hCov3],covExpS(2).anisotropyString...
                            ,covExpS(3).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpS(1).dirOk & covExpS(2).dirOk & covExpS(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.spatialCovAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.spatialCovAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxCorrRngEdit,'String',num2str(covExpS(choice).maxCorrRange));
      set(handles.lagNumberSlider,'Value',covExpS(choice).lagsNumber);
      set(handles.lagNumberEdit,'String',...
        num2str(get(handles.lagNumberSlider,'Value')));
      hCov1 = plot([0 covExpS(1).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(1).experimCov'],'ro');
      hold on;
      hCov2 = plot([0 covExpS(2).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(2).experimCov'],'m<');
      hold on;
      hCov3 = plot([0 covExpS(3).covDistance'],...
                  [var(cPtValuesDataToProcess) covExpS(3).experimCov'],'m^');
      hold on;
      if nestedScounter
        switch nestedScounter  % Use appropriate data based on available models
          case 1
            covModelS = {covModS(1).modelName};                      % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range]};        % BMElib covparam
          case 2   
            covModelS = {covModS(1).modelName,covModS(2).modelName}; % BMElib covmodel
            covParamS = {[covModS(1).sill covModS(1).range],...
                         [covModS(2).sill covModS(2).range]};        % BMElib covparam
          otherwise
            errordlg({'ip305p1covarAnal.m:graphTypeMenu:';...
                  'More than 2 nested models are available';...
                  'and the graphType Menu function has not been properly updated.';...
                  'GUI developer needs to correct the discrepancy.'},...
                  'GUI software Error')
        end
        maxDistance = covExpS(choice).maxCorrRange;
        modelPoints = 50;                      % Obtain model covariance at 50 points.
        distances = 0:round(maxDistance)/modelPoints:maxDistance;
        [mCov] = modelplot(distances,covModelS,covParamS); % Model covariance calcs.
        hmCov = plot(distances,mCov);
        hold off;
        legend([hCov1,hCov2,hCov3,hmCov],...
                                  [covExpS(1).anisotropyString ' Experimental'],...
                                  [covExpS(2).anisotropyString ' Experimental'],...
                                  [covExpS(3).anisotropyString ' Experimental'],...
                                  'Covariance Model');
      else
        hold off;
        legend([hCov1,hCov2,hCov3],covExpS(1).anisotropyString...
                                  ,covExpS(2).anisotropyString...
                                  ,covExpS(3).anisotropyString);
      end
      xlabel('Lag (in distance units)');
      ylabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    else
      displayString = 'No data available for any plot';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.spatialCovAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end
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




% --- Executes on button press in extFigureBox.
function extFigureBox_Callback(hObject, eventdata, handles)
% hObject    handle to extFigureBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extFigureBox
global prevExtFigState

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
if ~prevExtFigState
   
  set(handles.extFigureBox,'Value',1);
  prevExtFigState = 1;
  displayString = 'Plots to follow will display in separate windows';
  set(handles.feedbackEdit,'String',displayString);
        
else

  set(handles.extFigureBox,'Value',0);
  prevExtFigState = 0;
  displayString = 'Plots to follow will display in this window';
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
ip304p3TexplorAnal('Title','Exploratory Analysis');  % ...and procede to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModelS covParamS
global maxCorrRangeS lagsNumberS lagsLimitsS
global covModS covExpS nestedScounter
global displayString

if nestedScounter     % User can only proceed when done with covariance modelling
    displayString = [];
    delete(handles.figure1);                               % Close current window...
    ip306estimationsWiz('Title','BME Estimations Wizard'); % ...and procede to following screen.
else
  errordlg({'No covariance models have been defined.';...
           'BMElib needs covariance model information';...
           'in order to advance to the estimation stage.'},...
           'Can not proceed further');
end
