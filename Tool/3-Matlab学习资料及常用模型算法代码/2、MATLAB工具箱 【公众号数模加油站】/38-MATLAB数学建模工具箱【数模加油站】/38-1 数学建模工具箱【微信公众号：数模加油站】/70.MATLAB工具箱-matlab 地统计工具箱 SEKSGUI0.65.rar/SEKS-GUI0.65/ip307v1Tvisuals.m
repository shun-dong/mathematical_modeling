function varargout = ip307v1Tvisuals(varargin)
%IP307V1TVISUALS M-file for ip307v1Tvisuals.fig
%      IP307V1TVISUALS, by itself, creates a new IP307V1TVISUALS or raises the existing
%      singleton*.
%
%      H = IP307V1TVISUALS returns the handle to a new IP307V1TVISUALS or the handle to
%      the existing singleton*.
%
%      IP307V1TVISUALS('Property','Value',...) creates a new IP307V1TVISUALS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip307v1Tvisuals_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP307V1TVISUALS('CALLBACK') and IP307V1TVISUALS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP307V1TVISUALS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE''s Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip307v1Tvisuals

% Last Modified by GUIDE v2.5 10-May-2006 12:45:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip307v1Tvisuals_OpeningFcn, ...
                   'gui_OutputFcn',  @ip307v1Tvisuals_OutputFcn, ...
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


% --- Executes just before ip307v1Tvisuals is made visible.
function ip307v1Tvisuals_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip307v1Tvisuals
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

% UIWAIT makes ip307v1Tvisuals wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip307v1Tvisuals_OutputFcn(hObject, eventdata, handles)
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
global displayString
global KSprocessType KSprocessTypeInit
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskKnown
global prevMaskState
global prevExtFigState
global outGrid totalCoordinatesUsed
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global cameFromMainMenu
global timePresent
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global colorScaleMin colorScaleMax
global mapDataText

axes(handles.bmeMapsAxes)
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off

% If there is no previous output information available when loading this
% screen, the user may or may not have arrived here from the main menu.
if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1} & ~gbmeMom{1,1}
  displayString = 'Please load BME output MAT-file to proceed';
  set(handles.feedbackEdit,'String',displayString);
  firstOutInst = [];
  lastOutInst = [];
% Instead, if there is information present when loading this screen, the
% user must have arrived here having been through the estimations. This
% menas the user must have made a choice on their type during the task
% selection screen.
else
  switch KSprocessType
    case 1     % BME estimations
      displayString=CheckBmeType(bmeMod,bmeMom,bmePdf,bmeCin);
    case 2     % GBME estimations
      if gbmeMom{1,1}
        displayString = ['Estimated Moments present'];
      end
    otherwise
      errordlg({'ip307v1Tvisuals.m:Preliminary settings:';...
       'KSprocessType = ' num2str(KSprocessType) ' somehow led here.'},...
       'GUI software Error')
  end
  if timePresent
    firstOutInst = outGrid{totalCoordinatesUsed}(1);
    lastOutInst = outGrid{totalCoordinatesUsed}(size(outGrid{totalCoordinatesUsed},2));
    tStr = [' in t=[' num2str(firstOutInst) ',' num2str(lastOutInst) ']'];
  else
    tStr = [];
    firstOutInst = [];
    lastOutInst = [];
  end
  set(handles.feedbackEdit,'String',[displayString tStr]);
end

BMEInit(handles);

set(handles.tInstanceSlider,'Value',0);                        % Initialize
if cameFromMainMenu   % There is no info on time if we get here from Main Menu
  set(handles.tInstanceEdit,'String','');                      % Initialize
  KSprocessTypeInit = [];            % Remember how we started for "Back" button
else                  % Otherwise we can proceed normally
  if timePresent
    set(handles.tInstanceSlider,'Enable','on');                % Initialize
    set(handles.tInstanceEdit,'String',num2str(firstOutInst)); % Initialize
    set(handles.tInstanceEdit,'Enable','on');                  % Initialize
  else
    set(handles.tInstanceSlider,'Enable','off');
    set(handles.tInstanceEdit,'String','N/A');                 % Initialize
    set(handles.tInstanceEdit,'Enable','off');
  end
  KSprocessTypeInit = KSprocessType; % Remember how we started for "Back" button
end


%%
% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadDataButton
global displayString
global bmeMod bmeMom bmePdf bmeCin gbmeMom 
global timePresent
global outGrid totalCoordinatesUsed totalSpCoordinatesUsed
global firstOutInst lastOutInst
global meanTrendAtkAtInst
global positiveDataOnly
global pdfScaleFactor pdfCutoff maxPdfs
global cameFromMainMenu
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global KSprocessType
global colorScaleMin colorScaleMax
global mapDataText
global maskKnown prevMaskState
global mapInOrigSpaceBme trsfMapIndxBme

initialDir = pwd;                 % Save the current directory path

[outFilename,outPathname] = uigetfile('*.mat','Select output Data MAT-file');
%
% If user presses 'Cancel' then 0 is returned.
% Should anything go wrong, we use the following criterion
%
if ~ischar(outFilename)
    
  if bmeMod{1,1} | bmeMom{1,1} | bmePdf{1,1} | bmeCin{1,1} | gbmeMom{1,1}
    displayString = 'Data already present. Proceed to choose a plot type';
    set(handles.feedbackEdit,'String',displayString);
  else
    displayString = 'No estimation data present';
    set(handles.feedbackEdit,'String',displayString);
  end
  
else
    
  cd (outPathname);                             % Go to where the file resides

  if ~isnan(str2double(textread(outFilename,'%s',1)))
    warndlg({'Required data are to be read from an existing MAT-file.';...
          'The selected file does not seem to be a Matlab MAT-file.';,...
          'Please check again your input';...
          'or you may choose to perform new estimations.'},...
          'Not a MAT-file!')
  else
    
    set(handles.feedbackEdit,'String',['Using estimation data in: ' outFilename]);
    tempLoad = load('-mat',outFilename);  % Load data from file into a temp
      
    if isfield(tempLoad,'validOutputData')   % Check the output file for valid information

      % The file contains valid information: Prepare to load data. 
      % First, clear existing outputvariables from the memory.
      % Then, define/initialize the main output cell variables.
      % Finally, load the new output file variables.
      clear tempLoad;                        % Dispose of the temp variable
      
      clear timePresent outGrid...
            totalCoordinatesUsed totalSpCoordinatesUsed minTout minTdata...
            meanTrendAtkAtInst positiveDataOnly validOutputData;
      bmeMod = [];            % Initialize cell array of BME Mode output.
      bmeMod{1,1} = [0];      % Indicator that estimation has not taken place.
      bmeMom = [];            % Initialize cell array of BME Moments output.
      bmeMom{1,1} = [0];      % Indicator that estimation has not taken place.
      bmePdf = [];            % Initialize cell array of BME PDF output.
      bmePdf{1,1} = [0];      % Indicator that estimation has not taken place.
      bmeCin = [];            % Initialize cell array of BME CI output.
      bmeCin{1,1} = [0];      % Indicator that estimation has not taken place.
      gbmeMom = [];           % Initialize cell array of BME Moments output.
      gbmeMom{1,1} = [0];     % Indicator that estimation has not taken place.

      load('-mat',outFilename);              % Properly load output information
      
      % Is there GBME information there?
      if gbmeMom{1,1}
        displayString = ['Estimated Moments present'];
        KSprocessType = 2;
      % Is there BME information there?
      elseif bmeMod{1,1} | ~bmeMom{1,1} | ~bmePdf{1,1} | ~bmeCin{1,1}
        displayString=CheckBmeType(bmeMod,bmeMom,bmePdf,bmeCin);
        KSprocessType = 1;
      else   % No acceptable information is there
        displayString = ['No SEKS-GUI estimation data in file.'...
                         ' Try loading a different file'];
        KSprocessType = 0;
      end
      if KSprocessType & timePresent
        firstOutInst = outGrid{totalCoordinatesUsed}(1);
        lastOutInst = outGrid{totalCoordinatesUsed}(size(outGrid{totalCoordinatesUsed},2));
        tStr = [' in t=[' num2str(firstOutInst) ',' num2str(lastOutInst) ']'];
        set(handles.tInstanceEdit,'String',num2str(firstOutInst));   % Initialize
        set(handles.tInstanceSlider,'Value',0);                      % Initialize
        set(handles.tInstanceEdit,'Enable','on');                   % Initialize
        set(handles.tInstanceSlider,'Enable','on');                 % Initialize
      else
        tStr = [];
        firstOutInst = [];
        lastOutInst = [];
        set(handles.tInstanceEdit,'String','N/A');                   % Initialize
        set(handles.tInstanceSlider,'Value',0);                      % Initialize
        set(handles.tInstanceEdit,'Enable','off');                   % Initialize
        set(handles.tInstanceSlider,'Enable','off');                 % Initialize
      end
      set(handles.feedbackEdit,'String',[displayString tStr]);

      if cameFromMainMenu
        if timePresent
          set(handles.tInstanceEdit,'String',num2str(firstOutInst)); % Initialize
          set(handles.tInstanceSlider,'Value',0);                    % Initialize
          set(handles.tInstanceEdit,'Enable','on');                  % Initialize
          set(handles.tInstanceSlider,'Enable','on');                % Initialize
        else
          set(handles.tInstanceEdit,'String','N/A');                 % Initialize
          set(handles.tInstanceSlider,'Value',0);                    % Initialize
          set(handles.tInstanceEdit,'Enable','off');                 % Initialize
          set(handles.tInstanceSlider,'Enable','off');               % Initialize
        end
      end

      BMEInit(handles);
      
    else               % Output file contains invalid information
      clear tempLoad;  % Dispose of the temp variable
      applyTransformVisBme = [];
      transformTypeStrVisBme = [];
      displayString = ['Invalid output file. No SEKS-GUI estimation data present'];
      set(handles.feedbackEdit,'String',displayString);
    end
    
  end
    
  cd (initialDir)      % Finally, return to where this function was evoked from
    
end



%%
% --- Executes on selection change in graphTypeMenu.
function graphTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphTypeMenu
global displayString
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global timePresent
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme

if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1} & ~gbmeMom{1,1}
  displayString = 'Please load BME output MAT-file to proceed';
  set(handles.feedbackEdit,'String',displayString);
  firstOutInst = [];
  lastOutInst = [];
  outputDataPresent = 0;
else
  outputDataPresent = 1;
end

if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection

  if get(handles.graphTypeMenu,'Value') == 1  % If the title shows

    axes(handles.bmeMapsAxes)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    displayString = 'Select a type of map from the menu below';
    set(handles.feedbackEdit,'String',displayString);

  else    % If a map choice is made

    if timePresent
      % Obtain the t-instance to display maps for. Check if output is available on
      % that instance. If not, then instanceIncluded will be an empty matrix.
      userSelectedInst = str2num(get(handles.tInstanceEdit,'String'));
      instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
    else
      userSelectedInst = 1;   % This is how output is stored in the S-only case
      instanceIncluded = 1;   % Provide a value so that the following condition is met
    end
    if ~isempty(instanceIncluded)

      displayString = ['Plotting map'];
      if timePresent
        tStr = [' at t=' num2str(userSelectedInst) '. Please wait...'];
      else
        tStr = ['. Please wait...'];
      end
      set(handles.feedbackEdit,'String',[displayString tStr]);
      tNowActual = userSelectedInst;
      tNowOut = instanceIncluded;
      
      CreateMap(handles,tNowActual,tNowOut);

    else

      displayString = ['Instance t=' num2str(userSelectedInst) ' is outside the output grid'];
      set(handles.feedbackEdit,'String',displayString);

    end    % If userSelectedInst

  end      % If a map choice is made

else     % IF outputDataPresent : In case of no data, just reset the menu
  set(handles.graphTypeMenu,'Value',1);
end      % IF outputDataPresent


%%
% --- Executes on slider movement.
function tInstanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tInstanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global usingGrid
global timePresent
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global meanTrendAtk meanTrendAtkAtInst
global maskFilename maskPathname maskKnown
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global displayString
global applyTransformVisBme transformTypeStrVisBme

if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1} & ~gbmeMom{1,1}
  outputDataPresent = 0;
else
  outputDataPresent = 1;
end

if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection
  
  if timePresent  % IF timePresent: Allow the slider to function

    outDataTimeSpan = lastOutInst-firstOutInst+1;
    timeStep = outGrid{totalCoordinatesUsed}(2)-outGrid{totalCoordinatesUsed}(1);   

    instanceSliderValue = get(handles.tInstanceSlider,'Value');
    % instanceSliderValue ranges in [0,1]. Based on the user choice, grab
    % one of the instances for which there exist results.    
    userSelectedInstIndx = round(instanceSliderValue * length(outGrid{totalCoordinatesUsed}));
    if userSelectedInstIndx==0
      userSelectedInstIndx = 1;      % Set it at the minimum allowed index
    end
    userSelectedInst = outGrid{totalCoordinatesUsed}(userSelectedInstIndx);
    set(handles.tInstanceEdit,'String',num2str(userSelectedInst));

    % If the instance selected by the user is included in the output grid proceed
    % with the map creation, otherwise let the user know.
    %
    instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
    if ~isempty(instanceIncluded)

      displayString = ['Plotting map at t=' ...
                       num2str(userSelectedInst) '. Please wait...'];
      set(handles.feedbackEdit,'String',displayString); 
      tNowActual = userSelectedInst;
      tNowOut = instanceIncluded;

      CreateMap(handles,tNowActual,tNowOut)

    else

      displayString = ['Instance t=' num2str(userSelectedInst) ' not in the output grid'];
      set(handles.feedbackEdit,'String',displayString);    

    end

  else   % IF timePresent: Disable the slider in the S-only case
    displayString = 'This is a spatial-only case: Choice of t instance not available';
    set(handles.feedbackEdit,'String',displayString);
    set(handles.tInstanceSlider,'Value',0);
    set(handles.tInstanceEdit,'String','N/A');
    pdfScaleFactor = 1;
  end    % IF timePresent
  
else     % IF outputDataPresent : No data present
  
  displayString1 = 'No data present. Can not set a time reference';
  set(handles.feedbackEdit,'String',displayString1);
  set(handles.tInstanceSlider,'Value',0);
  pause(2);
  set(handles.feedbackEdit,'String',displayString);

end
 


%%
function tInstanceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tInstanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tInstanceEdit as text
%        str2double(get(hObject,'String')) returns contents of tInstanceEdit as a double
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global usingGrid
global timePresent
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global meanTrendAtk meanTrendAtkAtInst
global maskFilename maskPathname maskKnown
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global displayString
global applyTransformVisBme transformTypeStrVisBme

if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1} & ~gbmeMom{1,1}
  outputDataPresent = 0;
else
  outputDataPresent = 1;
end

if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection
  
  if timePresent  % IF timePresent: Allow the tInstance box area to be edited

  outDataTimeSpan = lastOutInst-firstOutInst+1;
  inputValue = str2num(get(handles.tInstanceEdit,'String'));

    % IF valid entry in edit box
    if isempty(inputValue) | ...                     % Reject input if non-numeric,
      mod(inputValue,floor(inputValue)) | ...       % non-integer,
      inputValue<firstOutInst | inputValue>lastOutInst  % or out of allowed values.
      errordlg({'BME output is available for time instances';...
                ['between t=' num2str(firstOutInst) ' and t=' ...
                  num2str(lastOutInst) '.']; ...
                'Please type a valid value within these bounds';...
                'or use the slider to define an output instance.'},... 
                'Invalid input');
    else  % If indeed the entry is valid

      % The following line is valid if we start counting from minTdata
      % instanceSliderValue = (inputValue-minTdata)/(dataTimeSpan-1);
      % The following line is valid if we start counting from the earliest output t
      instanceSliderValue = (inputValue-firstOutInst)/(outDataTimeSpan-1);
      set(handles.tInstanceSlider,'Value',instanceSliderValue);

      userSelectedInst = inputValue;

      instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
      if ~isempty(instanceIncluded)

        displayString = ['Plotting map at t=' ...
                         num2str(userSelectedInst) '. Please wait...'];
        set(handles.feedbackEdit,'String',displayString); 
        tNowActual = userSelectedInst;
        tNowOut = instanceIncluded;

        CreateMap(handles,tNowActual,tNowOut)

      else

        displayString = ['Instance t=' num2str(userSelectedInst) ...
          ' not in output grid. Enter a valid one or use the slider'];
        set(handles.feedbackEdit,'String',displayString);    

      end

    end  % IF valid entry in edit box

  else   % IF timePresent: Disable the edit box in the S-only case
    displayString = 'This is a spatial-only case: Choice of t instance not available';
    set(handles.feedbackEdit,'String',displayString);
    set(handles.tInstanceSlider,'Value',0);
    set(handles.tInstanceEdit,'String','N/A');
    pdfScaleFactor = 1;
  end    % IF timePresent
  
else     % IF outputDataPresent : No data present
  
  displayString1 = 'No data present. Can not set a time reference';
  set(handles.feedbackEdit,'String',displayString1);
  set(handles.tInstanceEdit,'String','');
  pause(2);
  set(handles.feedbackEdit,'String',displayString);

end



%%
% --- Executes on slider movement.
function pdfScaleSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pdfScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global displayString
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtkAtInst
global totalCoordinatesUsed totalSpCoordinatesUsed
global outGrid
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global timePresent
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global displayString
global applyTransformVisBme transformTypeStrVisBme

if get(handles.graphTypeMenu,'Value') == 7  % If the graph is the one showing PDFs
  
  allowedOptions = [1e-7 1e-6 1e-5 1e-4 0.001 0.005 0.01 0.05 0.1 0.5 1 ...
                    5 10 50 100 500 1000 1e4 1e5 1e6 1e7];
  chosenIndex = round(get(handles.pdfScaleSlider,'Value'));
  pdfScaleFactor = allowedOptions(chosenIndex);
  set(handles.pdfScaleEdit,'String',num2str(pdfScaleFactor));


  if timePresent
    % Obtain the t-instance to display maps for. Check if output is available on
    % that instance. If not, then instanceIncluded will be an empty matrix.
    userSelectedInst = str2num(get(handles.tInstanceEdit,'String'));
    instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
  else
    userSelectedInst = 1;   % This is how output is stored in the S-only case
    instanceIncluded = 1;   % Provide a value so that the following condition is met
  end

  if ~isempty(instanceIncluded)
    tNowActual = userSelectedInst;
    tNowOut = instanceIncluded;
  	mapBmeEstimationSamplePdfs(handles,tNowActual,tNowOut);    % Create map
  else
    displayString = ['Instance t=' num2str(userSelectedInst) ' not in the output grid'];
    set(handles.feedbackEdit,'String',displayString);
  end    % If userSelectedInst
  
else
  displayString1 = 'Scaling slider can be used only with BME estimation PDFs graph';
  set(handles.feedbackEdit,'String',displayString1);
  set(handles.pdfScaleSlider,'Value',7);
  set(handles.pdfScaleEdit,'String','1');
  pdfScaleFactor = 1;
  pause(3);
  set(handles.feedbackEdit,'String',displayString);
end




%%
function pdfScaleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pdfScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pdfScaleEdit as text
%        str2double(get(hObject,'String')) returns contents of pdfScaleEdit as a double

allowedOptions = [1e-7 1e-6 1e-5 1e-4 0.001 0.005 0.01 0.05 0.1 0.5 1 ...
                  5 10 50 100 500 1000 1e4 1e5 1e6 1e7];
chosenIndex = round(get(handles.pdfScaleSlider,'Value'));
pdfScaleFactor = allowedOptions(chosenIndex);
set(handles.pdfScaleEdit,'String',num2str(pdfScaleFactor));

displayString = 'This area can not be edited. Please use the slider';
set(handles.feedbackEdit,'String',displayString);









%%
% --- Executes on button press in origSpaceButton.
function origSpaceButton_Callback(hObject, eventdata, handles)
% hObject    handle to origSpaceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of origSpaceButton
global mapInOrigSpaceBme trsfMapIndxBme
global displayString
global bmeMod bmeMom bmePdf bmeCin
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global firstOutInst lastOutInst
global timePresent
global applyTransformVisBme transformTypeStrVisBme

set(handles.origSpaceButton,'Value',1);
set(handles.trsfSpaceButton,'Value',0); 
mapInOrigSpaceBme = 1;
trsfMapIndxBme = 1;

% After making the proper settings above, proceed to update the current showing map,
% if any, and display it in the original space
if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
  outputDataPresent = 0;
else
  outputDataPresent = 1;
end

if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection

  if get(handles.graphTypeMenu,'Value') ~= 1  % If a map choice is made

    if timePresent
      % Obtain the t-instance to display maps for. Check if output is available on
      % that instance. If not, then instanceIncluded will be an empty matrix.
      userSelectedInst = str2num(get(handles.tInstanceEdit,'String'));
      instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
    else
      userSelectedInst = 1;   % This is how output is stored in the S-only case
      instanceIncluded = 1;   % Provide a value so that the following condition is met
    end
    if ~isempty(instanceIncluded)

      displayString = ['Displaying requested information'];
      if timePresent
        tStr = [' at t=' num2str(userSelectedInst)];
      else
        tStr = [];
      end
      set(handles.feedbackEdit,'String',[displayString tStr]);
      tNowActual = userSelectedInst;
      tNowOut = instanceIncluded;

      CreateMap(handles,tNowActual,tNowOut);

    else

      displayString = ['Instance t=' num2str(userSelectedInst) ' not in the output grid'];
      set(handles.feedbackEdit,'String',displayString);

    end    % If userSelectedInst

  end      % If a map choice is made

end      % IF outputDataPresent




%%
% --- Executes on button press in trsfSpaceButton.
function trsfSpaceButton_Callback(hObject, eventdata, handles)
% hObject    handle to trsfSpaceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trsfSpaceButton
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global displayString
global bmeMod bmeMom bmePdf bmeCin
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global firstOutInst lastOutInst
global timePresent

set(handles.origSpaceButton,'Value',0);
set(handles.trsfSpaceButton,'Value',1); 

% After making the proper settings above, proceed to update the current showing map,
% if any, and display it in the transformed space
if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
	outputDataPresent = 0;
else
	outputDataPresent = 1;
end

if applyTransformVisBme    % If there exist transformed data values
  mapInOrigSpaceBme = 0;
  trsfMapIndxBme = 2;
  displayString1 = ['Note: Variable is detrended in transformation space maps'];
  set(handles.feedbackEdit,'String',displayString1);     
  pause(3);
  set(handles.feedbackEdit,'String',displayString);     
	
	if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection

		if get(handles.graphTypeMenu,'Value') ~= 1  % If a map choice is made

			if timePresent
				% Obtain the t-instance to display maps for. Check if output is available on
				% that instance. If not, then instanceIncluded will be an empty matrix.
				userSelectedInst = str2num(get(handles.tInstanceEdit,'String'));
				instanceIncluded = find(userSelectedInst==outGrid{totalCoordinatesUsed});
			else
				userSelectedInst = 1;   % This is how output is stored in the S-only case
				instanceIncluded = 1;   % Provide a value so that the following condition is met
			end
			if ~isempty(instanceIncluded)

        displayString = ['Displaying requested information'];
        if timePresent
          tStr = [' at t=' num2str(userSelectedInst)];
        else
          tStr = [];
        end
        set(handles.feedbackEdit,'String',[displayString tStr]);
        tNowActual = userSelectedInst;
        tNowOut = instanceIncluded;

        CreateMap(handles,tNowActual,tNowOut);
        
			else

				displayString = ['Instance t=' num2str(userSelectedInst) ...
                         ' not in the output grid'];
				set(handles.feedbackEdit,'String',displayString);

			end    % If userSelectedInst

		end      % If a map choice is made

	end      % IF outputDataPresent
	
else                    % If no transformation has been applied to data
  mapInOrigSpaceBme = 1;
  trsfMapIndxBme = 1;

	if outputDataPresent    % IF outputDataPresent : Then proceed with the user selection
    displayString1 = ['No transformation present. '...
                      'Maps are available only in original space'];
    set(handles.feedbackEdit,'String',displayString1);
    pause(2);
    set(handles.feedbackEdit,'String',displayString);
    set(handles.origSpaceButton,'Value',1);
    set(handles.trsfSpaceButton,'Value',0); 
  end
end



%%
% --- Executes on button press in showTrsfInfoButton.
function showTrsfInfoButton_Callback(hObject, eventdata, handles)
% hObject    handle to showTrsfInfoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bmeMod bmeMom bmePdf bmeCin
global displayString

if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
  displayString1 = 'No data present. No information to display';
  set(handles.feedbackEdit,'String',displayString1);
  pause(2);
  set(handles.feedbackEdit,'String',displayString);
else
  if bmeMod{1,1}
    applyTransformVisBme = bmeMod{5,1}{1};
    transformTypeStrVisBme = bmeMod{5,1}{2};
    bcxLambdaVis = bmeMod{5,1}{3};
    nscMinAcceptOutputVis = bmeMod{5,1}{5}(1);
    nscMaxAcceptOutputVis = bmeMod{5,1}{5}(2);
  elseif  bmeMom{1,1}
    applyTransformVisBme = bmeMom{7,1}{1};
    transformTypeStrVisBme = bmeMom{7,1}{2};
    bcxLambdaVis = bmeMom{7,1}{3};
    nscMinAcceptOutputVis = bmeMom{7,1}{5}(1);
    nscMaxAcceptOutputVis = bmeMom{7,1}{5}(2);
  elseif  bmePdf{1,1}
    applyTransformVisBme = bmePdf{6,1}{1};
    transformTypeStrVisBme = bmePdf{6,1}{2};
    bcxLambdaVis = bmePdf{6,1}{3};
    nscMinAcceptOutputVis = bmePdf{6,1}{5}(1);
    nscMaxAcceptOutputVis = bmePdf{6,1}{5}(2);
  elseif  bmeCin{1,1}
    applyTransformVisBme = bmeCin{9,1}{1};
    transformTypeStrVisBme = bmeCin{9,1}{2};
    bcxLambdaVis = bmeCin{9,1}{3};
    nscMinAcceptOutputVis = bmeCin{9,1}{5}(1);
    nscMaxAcceptOutputVis = bmeCin{9,1}{5}(2);
  end
  switch applyTransformVisBme
    case 0       % None
      displayString = 'No transformation has been applied in present data';    
    case 1       % N-scores
      displayString = ['Type: ' transformTypeStrVisBme '. Detrended results allowed range: ['...
        num2str(nscMinAcceptOutputVis) ',' num2str(nscMaxAcceptOutputVis) ']'];    
    case 2       % Box-Cox
      displayString = ['Type: ' transformTypeStrVisBme ' with lambda='...
        num2str(bcxLambdaVis)];    
    otherwise    % Unspecified
      errordlg({'ip307v1Tvisuals.m:showTrsfInfoButton:';...
       'No provision in code for requested menu item.'},...
       'GUI software Error')
  end
  set(handles.feedbackEdit,'String',displayString);     
end




%%
% --- Executes on button press in fixColorscaleBox.
function fixColorscaleBox_Callback(hObject, eventdata, handles)
% hObject    handle to fixColorscaleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixColorscaleBox
global colorScaleMin colorScaleMax

if get(handles.fixColorscaleBox,'Value')
    set(handles.colorMaxEdit,'Enable','on');
    set(handles.colorMaxEdit,'String',num2str(colorScaleMax));
    set(handles.colorMinEdit,'Enable','on');
    set(handles.colorMinEdit,'String',num2str(colorScaleMin));
else
    set(handles.colorMaxEdit,'String','');
    set(handles.colorMaxEdit,'Enable','off');
    set(handles.colorMinEdit,'String','');
    set(handles.colorMinEdit,'Enable','off');
end;




%%
function colorMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colorMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorMinEdit as text
%        str2double(get(hObject,'String')) returns contents of colorMinEdit
%        as a double
global colorScaleMin colorScaleMax
global displayString

colorScaleMin = str2num(get(handles.colorMinEdit,'String'));
if isnan(colorScaleMin) | isinf(colorScaleMin) ...
                        | ~isreal(colorScaleMin)
  colorScaleMin = [];
  set(handles.colorMinEdit,'String','');
  set(handles.feedbackEdit,'String','Please use real numbers for the scale bounds');
  pause(2.5);
  set(handles.feedbackEdit,'String',displayString);       
elseif ~isempty(colorScaleMax) & colorScaleMax<=colorScaleMin
  colorScaleMax = [];
  set(handles.colorMaxEdit,'String','');
  set(handles.feedbackEdit,'String','The lower bound must be smaller than the upper bound');
  pause(2.5);
  set(handles.feedbackEdit,'String',displayString);
end









%%
function colorMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colorMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of colorMaxEdit as a double
global colorScaleMin colorScaleMax
global displayString

colorScaleMax = str2num(get(handles.colorMaxEdit,'String'));
if isnan(colorScaleMax) | isinf(colorScaleMax) ...
                        | ~isreal(colorScaleMax)
  colorScaleMax = [];
  set(handles.colorMaxEdit,'String','');
  set(handles.feedbackEdit,'String','Please use real numbers for the scale bounds');
  pause(2.5);
  set(handles.feedbackEdit,'String',displayString);
elseif ~isempty(colorScaleMin) & colorScaleMax<=colorScaleMin
  colorScaleMax = [];
  set(handles.colorMaxEdit,'String','');
  set(handles.feedbackEdit,'String','The upper bound must be larger than the lower bound');
  pause(2.5);
  set(handles.feedbackEdit,'String',displayString);
end








%%
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




%%
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
    [maskFilename,maskPathname] = uigetfile({'*.m';'*.shp'},'Select masking M-file');
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
  displayString = 'Map mask will now be removed from plots to follow';
  set(handles.feedbackEdit,'String',displayString);  

end




%%
% --- Executes on button press in saveMapDataAsTextButton.
function saveMapDataAsTextButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveMapDataAsTextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mapDataText displayString

if ~isempty(mapDataText) % If there is material to save

  hasNaNs = sum(isnan(mapDataText(:,end)));
  hasImaginaries = ~isreal(mapDataText);
  
  % Check the data to be exported in a text file for NaNs or imaginary
  % numbers. Neither type can be saved in a text file. If either is found,
  % proceed to resolve the situation and let the user know.
  if hasNaNs
    mapDataText(isnan(mapDataText(:,end)),end) = 0;  % Replace any NaNs with 0.
    strNa = {'';'Non number quantities found in the output.';...
             'Replacing them with 0 before saving.';''};
  else
    strNa = [];
  end
  if hasImaginaries
    mapDataText = real(mapDataText);                 % Use only real part
    strIm = {'';'Imaginary numbers found in the output.';...
             'Will be considering only their real part when saving.';''};
  else
    strIm = [];
  end
  if hasNaNs | hasImaginaries
    warndlg([strNa; strIm],'Warning on exporting data');
  end
  
  % Continue saving process
  %
  initialDir = pwd;     % Save the current directory path

  mapInfoOutFilename = 'mapData.txt';
  % Prompt user to save trend information data in a MAT-file for future use
  %
  [mapInfoOutFilename,mapInfoOutPathname] = ...
    uiputfile('*.txt','Save current map data as a text file:');	

  if ~isequal([mapInfoOutFilename,mapInfoOutPathname],[0,0])  
    % Construct the full path and save
    validOutputData = 1;  % Control variable. Validates this as an output file
    File = fullfile(mapInfoOutPathname,mapInfoOutFilename);
    save(File,'mapDataText','-ascii');
    displayString = ['Current map data saved as text in: ' mapInfoOutFilename];
    set(handles.feedbackEdit,'String',displayString);
  end

  cd (initialDir);      % Finally, return to where this function was evoked from
  
  mapDataText = [];                               % Reset 
else
    
  if get(handles.graphTypeMenu,'Value')==7
    displayString1 = ['Sample PDF map not eligible for data save.'...
                      ' Please choose other map'];
    set(handles.feedbackEdit,'String',displayString1);
    pause(2.5);
    set(handles.feedbackEdit,'String',displayString);
  else
    displayString = ['No map information to save. Please plot a map first'];
    set(handles.feedbackEdit,'String',displayString1);
    pause(2.5);
    set(handles.feedbackEdit,'String',displayString);
  end
  
end




%%
% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ip201helpMain('Title','BMElib Help');




%%
% --- Executes on button press in mainButton.
function mainButton_Callback(hObject, eventdata, handles)
% hObject    handle to mainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bmeMod bmeMom bmePdf bmeCin

if ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1} % No data present
  user_response = 'yes';
else
  user_response = ip102back2mainDialog('Title','Confirm Action');
end
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
	delete(handles.figure1);
  clear; clear all; clear memory;
  ip002chooseTask('Title','Choose a Task');
end




%%
% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cameFromMainMenu
global KSprocessType KSprocessTypeInit

if cameFromMainMenu
  user_response = ip102back2mainDialog('Title','Confirm Action');
  switch lower(user_response)
    case 'no'
      % take no action
    case 'yes'
      delete(handles.figure1);
      clear; clear all; clear memory;
      ip002chooseTask('Title','Choose a Task');
  end
else
  % The user may have not loaded a different output file inbetween.
  % In this case, if the user wants to go back, allow the user to return to 
  % the proper screen based on the type of analysis that was performed.
  if KSprocessType==KSprocessTypeInit
    delete(handles.figure1);                                 % Close current window...
    switch KSprocessType
      case 1     % If using BME processing
        ip306estimationsWiz('Title','BME Estimations Wizard'); % ...or procede to the previous unit.
      case 2     % If using GBME processing
        ip406estimationsWiz('Title','GBME Estimations Wizard');% ...or procede to the previous unit.
      otherwise
        errordlg({'ip307viTvisuals.m:previousButton_Callback Function:';...
              'The switch commands detected more options';...
              'than currently available (2) for KSprocessType.'},...
              'GUI software Error');
    end
  % Otherwise, the user may have loaded a different output file inbetween.
  % In this case, if the user wants to go back, variable inconsistencies
  % may occur. Prevent potential errors by prompting the user to return to 
  % the main menu.
  else
    user_response = ip102back2mainDialog('Title','Back to Main?');
    switch lower(user_response)
      case 'no'
        % take no action
      case 'yes'
        delete(handles.figure1);
        clear; clear all; clear memory;
        ip002chooseTask('Title','Choose a Task');
    end
  end
end





% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = ip101exitDialog('Title','Confirm Exit');
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
	delete(handles.figure1)
end




%%
function mapBmeEstimationMean(handles,tNowActual,tNowOut);
%
% Plots estimation BMEmean in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeMom{1,1} | bmePdf{1,1} | bmeCin{1,1} | gbmeMom{1,1}

  if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First, select the residual mean output, put it into a matrix and
		% resize the output matrix into the pre-selected grid dimensions
		if bmeMom{1,1}       % Then mean is stored in cell 3
			meanDetrended = reshape(bmeMom{3,tNowOut}{trsfMapIndxBme},...
															size(xMesh,1),size(xMesh,2));
		elseif bmePdf{1,1}   % Then mean is stored in cell 7
			meanDetrended = reshape(bmePdf{7,tNowOut}{trsfMapIndxBme},...
															size(xMesh,1),size(xMesh,2));
    elseif bmeCin{1,1}   % Then mean is stored in cell 10
			meanDetrended = reshape(bmeCin{10,tNowOut}{trsfMapIndxBme},...
															size(xMesh,1),size(xMesh,2));
    elseif gbmeMom{1,1}  % Then mean is stored in cell 3 
			meanDetrended = reshape(gbmeMom{3,tNowOut},size(xMesh,1),size(xMesh,2));
      % GBMElib may return numbers with an imaginary part. Matlab can not
      % plot non-real numbers. Prevent the case of mapping imaginary numbers  
      if ~isreal(meanDetrended)
        meanDetrended = real(meanDetrended);
      end
    end
    
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    meanDetrended(find(isinf(meanDetrended))) = NaN;
    % Cope with potential negative numbers in GBME results in a positive-only case.
    if positiveDataOnly & gbmeMom{1,1}
      meanDetrended(find(meanDetrended<0))=NaN;
    end;
     
    if ~gbmeMom{1,1}
      if mapInOrigSpaceBme
        % Add mean trend back to estimations of residuals
        % Remember: Mean trend is calculated at all instances where data
        % exist. Therefore the translation of tNowActual to tNow depends 
        % on minTdata rather than the minimum output instance minTout mark.
        tNowData = tNowActual-minTdata+1;
        meanAtk = meanDetrended + meanTrendAtkAtInst{tNowData};
        % Is this a positive values only quantity?
        if positiveDataOnly
          meanAtk(find(meanAtk<0)) = 0;
        end
        displayString = 'Displaying variable: Mean';
      else
        meanAtk = meanDetrended;   % Plot raw BME output
        displayString = ['Displaying variable: Mean (' ...
                        transformTypeStrVisBme ' space, no trend)'];
      end
    else
      meanAtk = meanDetrended;   % Plot raw BME output
      displayString = ['Displaying variable: Mean'];
    end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
      axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
    end
    
    
		% Plot the graph
		%
    
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(meanAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    
    contourmap(handles,xMesh,yMesh,meanAtk,displayString,maskFilename,maskPathname);
        

  
  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
  displayString = 'Can not plot: BME/GBME moments, BME PDF or CI results required';
  set(handles.feedbackEdit,'String',displayString);
end




%%
function mapBmeEstimationMode(handles,tNowActual,tNowOut);
%
% Plots estimation BMEmode in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeMod{1,1}

  if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First locate the mode values, put them into a matrix and
		% resize the output matrix into the pre-selected grid dimensions
		modeDetrended = reshape(bmeMod{3,tNowOut}{trsfMapIndxBme}(:,1),...
														size(xMesh,1),size(xMesh,2));
                          
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    modeDetrended(find(isinf(modeDetrended))) = NaN;
    
  	if mapInOrigSpaceBme
			% Add mean trend back to estimations of residuals
      % Remember: Mean trend is calculated at all instances where data
      % exist. Therefore the translation of tNowActual to tNow depends 
      % on minTdata rather than the minimum output instance minTout mark.
      tNowData = tNowActual-minTdata+1;
			modeAtk = modeDetrended + meanTrendAtkAtInst{tNowData};
			% Is this a positive values only quantity?
			if positiveDataOnly
				modeAtk(find(modeAtk<0)) = 0;
			end
			displayString = 'Displaying variable: Mode';
		else
			modeAtk = modeDetrended;   % Plot raw BME output
			displayString = ['Displaying variable: Mode (' ...
												transformTypeStrVisBme ' space, no trend)'];
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
	
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(modeAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,modeAtk,displayString,maskFilename,maskPathname);                   

	else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
  end

	set(handles.feedbackEdit,'String',displayString);

else
	displayString = 'Can not plot: BME mode results required';
	set(handles.feedbackEdit,'String',displayString);
end



%%
function mapBmeEstimationVariance(handles,tNowActual,tNowOut);
%
% Plots BME estimation error variance in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout
global colorScaleMin colorScaleMax
global mapDataText

if bmeMom{1,1} | bmePdf{1,1} | bmeCin{1,1} | gbmeMom{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First locate the residual mean, then put it into a matrix and
		% resize the output matrix into the pre-selected grid dimensions
		if bmeMom{1,1}       % Then var is stored in cell 4
			varAtk = reshape(bmeMom{4,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
		elseif bmePdf{1,1}   % Then var is stored in cell 8
			varAtk = reshape(bmePdf{8,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
		elseif bmeCin{1,1}   % Then var is stored in cell 11
			varAtk = reshape(bmeCin{11,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
    elseif gbmeMom{1,1}  % Then var is stored in cell 4 
			varAtk = reshape(gbmeMom{4,tNowOut},size(xMesh,1),size(xMesh,2));
      % GBMElib may return numbers with an imaginary part. Matlab can not
      % plot non-real numbers. Prevent the case of mapping imaginary numbers  
      if ~isreal(varAtk)
        varAtk = real(varAtk);
      end
    end

    % Cope with potential infinite numbers in results: Convert them to NaNs.
    varAtk(find(isinf(varAtk))) = NaN;
    
    if mapInOrigSpaceBme | gbmeMom{1,1}
			displayString = 'Displaying estimation error variance';
		else
			displayString = ['Displaying estimation error variance (' ...
												transformTypeStrVisBme ' space)'];
		end

	  if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
		
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(varAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,varAtk,displayString,maskFilename,maskPathname); 

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME/GBME moments, BME PDF or CI results required';
	set(handles.feedbackEdit,'String',displayString);
end




%%
function mapBmeEstimationStDeviation(handles,tNowActual,tNowOut);
%
% Plots BME estimation standard deviation in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout
global colorScaleMin colorScaleMax
global mapDataText

if bmeMom{1,1} | bmePdf{1,1} | bmeCin{1,1} | gbmeMom{1,1}

  if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First locate the variance, then put it into a matrix and
		% resize the output matrix into the pre-selected grid dimensions
		if bmeMom{1,1}       % Then var is stored in cell 4
			varAtk = reshape(bmeMom{4,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
		elseif bmePdf{1,1}   % Then var is stored in cell 8
			varAtk = reshape(bmePdf{8,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
		elseif bmeCin{1,1}   % Then var is stored in cell 11
			varAtk = reshape(bmeCin{11,tNowOut}{trsfMapIndxBme},...
											 size(xMesh,1),size(xMesh,2));
    elseif gbmeMom{1,1}  % Then var is stored in cell 4 
			varAtk = reshape(gbmeMom{4,tNowOut},size(xMesh,1),size(xMesh,2));
      if ~isreal(varAtk)
        varAtk = real(varAtk);
      end
		end
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    varAtk(find(isinf(varAtk))) = NaN;
    
		stdAtk = sqrt(varAtk);    % Obtain the standard deviation

		if mapInOrigSpaceBme | gbmeMom{1,1}
			displayString = 'Displaying estimation standard deviation';
		else
			displayString = ['Displaying estimation standard deviation (' ...
												transformTypeStrVisBme ' space)'];
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(stdAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,stdAtk,displayString,maskFilename,maskPathname); 

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
	  set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME/GBME moments, BME PDF or CI results required';
	set(handles.feedbackEdit,'String',displayString);
end




%%
function mapBmeEstimationSkewness(handles,tNowActual,tNowOut);
%
% Plots BME estimation skewness coefficient in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout
global colorScaleMin colorScaleMax
global mapDataText

if bmeMom{1,1} | bmePdf{1,1} | bmeCin{1,1} | gbmeMom{1,1}
  
  if ~(bmeMom{1,1} & applyTransformVisBme & mapInOrigSpaceBme)

    if totalSpCoordinatesUsed==2

      set(handles.fixColorscaleBox,'Enable','on');
      set(handles.saveMapDataAsTextButton,'Enable','on');

      [xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
      % First locate the coefficient, then put it into a matrix and
      % resize the output matrix into the pre-selected grid dimensions
      if bmeMom{1,1}       % Then skewness is stored in cell 5
        skewAtk = reshape(bmeMom{5,tNowOut}{trsfMapIndxBme},...
                          size(xMesh,1),size(xMesh,2));
      elseif bmePdf{1,1}   % Then skewness is stored in cell 9
        skewAtk = reshape(bmePdf{9,tNowOut}{trsfMapIndxBme},...
                          size(xMesh,1),size(xMesh,2));
      elseif bmeCin{1,1}   % Then skewness is stored in cell 12
        skewAtk = reshape(bmeCin{12,tNowOut}{trsfMapIndxBme},...
                          size(xMesh,1),size(xMesh,2));
      elseif gbmeMom{1,1}  % Then skewness is stored in cell 5 
        skewAtk = reshape(gbmeMom{5,tNowOut},size(xMesh,1),size(xMesh,2));
        if ~isreal(skewAtk)
          skewAtk = real(skewAtk);
        end
      end

      % Cope with potential infinite numbers in results: Convert them to NaNs.
      skewAtk(find(isinf(skewAtk))) = NaN;

      if mapInOrigSpaceBme | gbmeMom{1,1}
        displayString = 'Displaying estimation skewness coefficient';
      else
        displayString = ['Displaying estimation skewness coefficient (' ...
                          transformTypeStrVisBme ' space)'];
      end

      if get(handles.extFigureBox,'Value')  % Separate figure or not?
        axes(handles.bmeMapsAxes)
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.bmeMapsAxes)
      end
      % Plot the graph
      %
      mapDataText = [xMesh(:) yMesh(:) ...
                     tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                     reshape(skewAtk,size(xMesh,1)*size(xMesh,2),1)];
                   
      contourmap(handles,xMesh,yMesh,skewAtk,displayString,maskFilename,maskPathname);              

    else
      set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
      pause(2);
      set(handles.feedbackEdit,'String',displayString);
    end

  else
		set(handles.feedbackEdit,'String','Skewness unavailable in BME moments w/ transformation');
	  pause(2.5);
	  set(handles.feedbackEdit,'String','Select a map from the menu to plot');
	end

else
	displayString = 'Can not plot: BME/GBME moments, BME PDF or CI results required';
	set(handles.feedbackEdit,'String',displayString);
end
					



%%
function mapBmeEstimationSamplePdfs(handles,tNowActual,tNowOut);
%
% Plots BME estimation PDFs at selected locations in the specified space 
% at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global pdfScaleFactor maxPdfs pdfCutoff
global minTout minTdata

maxPdfs = 4;       % Initialize. May become user-adjustable in future versions

if bmePdf{1,1} | bmeCin{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','off');
    set(handles.colorMinEdit,'Enable','off');
    set(handles.colorMaxEdit,'Enable','off');
    set(handles.saveMapDataAsTextButton,'Enable','off');

		% Create a mesh of outGrid{1} points in horizontal (# of columns)
		%              and outGrid{2} points in vertical   (# of rows)
		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		xOutPts = size(outGrid{2},2);    % Points in the vertical refer to rows
		yOutPts = size(outGrid{1},2);    % Points in the horizontal refer to columns
		distInA = floor((xOutPts-1)/maxPdfs);
		aPts = 1:distInA:xOutPts;        % Points for PDFs in vertical   (rows)
		distInB = floor((yOutPts-1)/maxPdfs);
		bPts = 1:distInB:yOutPts;        % Points for PDFs in horizontal (columns)
		[aMesh,bMesh] = meshgrid(outGrid{1}(bPts),outGrid{2}(aPts));

		% First find the PDF points, put the points for each PDF into matrices and
		% resize the matrices into the pre-selected grid dimensions
		if bmePdf{1,1}
		  zCell = reshape(bmePdf{3,tNowOut}{trsfMapIndxBme},size(xMesh,1),size(xMesh,2));
			pdfCell = reshape(bmePdf{4,tNowOut},size(xMesh,1),size(xMesh,2));
		elseif bmeCin{1,1}
			zCell = reshape(bmeCin{7,tNowOut}{trsfMapIndxBme},size(xMesh,1),size(xMesh,2));
			pdfCell = reshape(bmeCin{8,tNowOut},size(xMesh,1),size(xMesh,2));
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end

		if mapInOrigSpaceBme
			displayString = 'Displaying estimation PDFs at selected points';
		else
			displayString = ['Displaying estimation PDFs at selected points (' ...
												transformTypeStrVisBme ' space)'];
		end

		% Plot the graph in the requested domain
		for i1=1:size(aMesh,1)
			for i2=1:size(aMesh,2)
				% Single out the PDF data we will be using
				currPdfCell = pdfCell{aPts(i1),bPts(i2)};
				currzCellDetrended = zCell{aPts(i1),bPts(i2)};

				if mapInOrigSpaceBme
    			% Add mean trend back to estimation PDFs
          % Remember: Mean trend is calculated at all instances where data
          % exist. Therefore the translation of tNowActual to tNow depends 
          % on minTdata rather than the minimum output instance minTout mark.
          tNowData = tNowActual-minTdata+1;
					currzCell = currzCellDetrended + ...
						meanTrendAtkAtInst{tNowData}(aPts(i1),bPts(i2));
					if positiveDataOnly
						indToDelete = find(currPdfCell<pdfCutoff); % Remove low ends of PDF
						currPdfCell(indToDelete) = [];             % tails that may correspond
						currzCell(indToDelete) = [];               % to high variable values
					end
				else
					currzCell = currzCellDetrended;
        end
				
        % Prevent error messages in case there are locations where there are
        % potentially no estimates or NaNs: Just assign there minimal-sized PDFs 
        if isempty(currzCell)
				  currzCell = 0;
				  currPdfCell = 0;
        end
        
				% Plot the PDF x-axis vertically
				plot3([aMesh(i1,i2),aMesh(i1,i2)],[bMesh(i1,i2),bMesh(i1,i2)],...
					[min(currzCell) max(currzCell)],':','linewidth',1.5);
				hold on;
				% Plot the PDF
				plot3(aMesh(i1,i2)+currPdfCell*pdfScaleFactor,...
					bMesh(i1,i2)*ones(1,size(currPdfCell,1)),...
					currzCell','-','linewidth',1.5);
				hold on
			end
		end
		hold off;
		grid on;
		xlabel('x-Axis');
		ylabel('y-Axis');

	  set(handles.feedbackEdit,'String',displayString);

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME PDF or CI results required';
	set(handles.feedbackEdit,'String',displayString);
end




%%
function mapBmeConfIntervalSize(handles,tNowActual,tNowOut);
%
% Plots the width of the selected BME estimation confidence interval in 
% the specified space at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeCin{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First find the CI limits, put them into matrices and
		% resize the matrices into the pre-selected grid dimensions
		ciLow = reshape(bmeCin{3,tNowOut}{trsfMapIndxBme},size(xMesh,1),size(xMesh,2));
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    ciLow(find(isinf(ciLow))) = NaN;

    ciUpp = reshape(bmeCin{4,tNowOut}{trsfMapIndxBme},size(xMesh,1),size(xMesh,2));
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    ciUpp(find(isinf(ciUpp))) = NaN;

    ciSize = ciUpp-ciLow;
		ciValue = round(100*bmeCin{6,1});

		if mapInOrigSpaceBme
			displayString = ['Displaying size of the ' num2str(ciValue) '% CI'];
		else
			displayString = ['Displaying size of the ' num2str(ciValue) '% CI (' ...
											  transformTypeStrVisBme ' space)'];
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(ciSize,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,ciSize,displayString,maskFilename,maskPathname);              

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME CI results required';
	set(handles.feedbackEdit,'String',displayString);
end




%%
function mapBmeConfIntervalLowerLimits(handles,tNowActual,tNowOut);
%
% Plots the lower limits of the selected BME estimation confidence interval 
% in the specified space at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeCin{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First find the lower CI limits, put them into a matrix and
		% resize the matrices into the pre-selected grid dimensions
		ciLowDetrended = reshape(bmeCin{3,tNowOut}{trsfMapIndxBme},...
                             size(xMesh,1),size(xMesh,2));
		ciValue = round(100*bmeCin{6,1});

    % Cope with potential infinite numbers in results: Convert them to NaNs.
    ciLowDetrended(find(isinf(ciLowDetrended))) = NaN;

    if mapInOrigSpaceBme
      % Add mean trend back to estimation PDF low CI limits.
      % Remember: Mean trend is calculated at all instances where data
      % exist. Therefore the translation of tNowActual to tNow depends 
      % on minTdata rather than the minimum output instance minTout mark.
      tNowData = tNowActual-minTdata+1;
			ciLowAtk = ciLowDetrended + meanTrendAtkAtInst{tNowData};
			% Is this a positive values only quantity?
			if positiveDataOnly
				ciLowAtk(find(ciLowAtk<0)) = 0;
			end
			displayString = ['Lower limits of the ' num2str(ciValue) '% CI'];
		else
			ciLowAtk = ciLowDetrended;   % Plot raw BME PDF low CI limits
			displayString = ['Lower limits of the ' num2str(ciValue) '% CI (' ...
											  transformTypeStrVisBme ' space)'];
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(ciLowAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,ciLowAtk,displayString,maskFilename,maskPathname);              

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME CI results required';
	set(handles.feedbackEdit,'String',displayString);
end



%%
function mapBmeConfIntervalUpperLimits(handles,tNowActual,tNowOut);
%
% Plots the upper limits of the selected BME estimation confidence interval 
% in the specified space at the requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeCin{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First find the upper CI limits, put them into a matrix and
		% resize the matrices into the pre-selected grid dimensions
		ciUppDetrended = reshape(bmeCin{4,tNowOut}{trsfMapIndxBme}, ...
                             size(xMesh,1),size(xMesh,2));
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    ciUppDetrended(find(isinf(ciUppDetrended))) = NaN;
		
    ciValue = round(100*bmeCin{6,1});

		if mapInOrigSpaceBme
      % Add mean trend back to estimation PDF low CI limits.
      % Remember: Mean trend is calculated at all instances where data
      % exist. Therefore the translation of tNowActual to tNow depends 
      % on minTdata rather than the minimum output instance minTout mark.
      tNowData = tNowActual-minTdata+1;
			ciUppAtk = ciUppDetrended + meanTrendAtkAtInst{tNowData};
			% Is this a positive values only quantity?
			if positiveDataOnly
				ciUppAtk(find(ciUppAtk<0)) = 0;
			end
			displayString = ['Upper limits of the ' num2str(ciValue) '% CI'];
		else
			ciUppAtk = ciUppDetrended;   % Plot raw BME PDF low CI limits
			displayString = ['Upper limits of the ' num2str(ciValue) '% CI (' ...
											  transformTypeStrVisBme ' space)'];
		end

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(ciUppAtk,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,ciUppAtk,displayString,maskFilename,maskPathname);              

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME CI results required';
	set(handles.feedbackEdit,'String',displayString);
end



%%
function mapBmeConfIntervalPdfValues(handles,tNowActual,tNowOut);
%
% Plots for each output node the value of the BME estimation PDF at 
% the selected confidence interval in the specified space at the 
% requested temporal instance tNowActual
%
global bmeMod bmeMom bmePdf bmeCin
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if bmeCin{1,1}

	if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','on');
    set(handles.saveMapDataAsTextButton,'Enable','on');

		[xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First find the PDF values at the CI limits, put them into a matrix and
		% resize the matrices into the pre-selected grid dimensions
		pdfAtCIlim = reshape(bmeCin{5,tNowOut},size(xMesh,1),size(xMesh,2));
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    pdfAtCIlim(find(isinf(pdfAtCIlim))) = NaN;

    ciValue = round(100*bmeCin{6,1});

  	if applyTransformVisBme
      displayString = ['PDF value at the limits of the ' num2str(ciValue) ...
                       '% CI (from the ' transformTypeStrVisBme ' space PDF)'];
    else
      displayString = ['PDF value at the limits of the ' num2str(ciValue) ...
                       '% CI'];
    end      

		if get(handles.extFigureBox,'Value')  % Separate figure or not?
			axes(handles.bmeMapsAxes)
			image(imread('guiResources/ithinkPic.jpg'));
			axis image
			axis off
			figure;
		else
			axes(handles.bmeMapsAxes)
		end

		% Plot the graph
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(pdfAtCIlim,size(xMesh,1)*size(xMesh,2),1)];
    
    contourmap(handles,xMesh,yMesh,pdfAtCIlim,displayString,maskFilename,maskPathname);             

  else
		set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
		pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
	displayString = 'Can not plot: BME CI results required';
	set(handles.feedbackEdit,'String',displayString);
end


%%
function mapGbmeNu(handles,tNowActual,tNowOut);
%
% Plots GBME estimation spatial order nu in the specified space 
% at the requested temporal instance tNowActual
%
global gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpace trsfMapIndx
global applyTransformVis transformTypeStrVis
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if gbmeMom{1,1}

  if totalSpCoordinatesUsed==2

    set(handles.fixColorscaleBox,'Enable','off');
    set(handles.colorMinEdit,'Enable','off');
    set(handles.colorMaxEdit,'Enable','off');
    set(handles.saveMapDataAsTextButton,'Enable','on');

    [xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
		% First, select the proper output, put it into a matrix and
		% resize the output matrix into the pre-selected grid dimensions
        
    numuNu = reshape(gbmeMom{7,tNowOut}(:,1),size(xMesh,1),size(xMesh,2));
    % Cope with potential infinite numbers in results: Convert them to NaNs.
    numuNu(find(isinf(numuNu))) = NaN;

    if get(handles.extFigureBox,'Value')  % Separate figure or not?
      axes(handles.bmeMapsAxes)
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
      figure;
    else
			axes(handles.bmeMapsAxes)
    end
		% Plot the graph
		%
    mapDataText = [xMesh(:) yMesh(:) ...
                   tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                   reshape(numuNu,size(xMesh,1)*size(xMesh,2),1)];
                 
    contourmap(handles,xMesh,yMesh,numuNu,displayString,maskFilename,maskPathname,1);              

  else
    set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
    pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
  displayString = 'Can not plot: GBME Estimates Required';
  set(handles.feedbackEdit,'String',displayString);
end


%%
function mapGbmeMu(handles,tNowActual,tNowOut);
%
% Plots GBME estimation temporal order mu in the specified space 
% at the requested temporal instance tNowActual
%
global gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpace trsfMapIndx
global applyTransformVis transformTypeStrVis
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if gbmeMom{1,1}

  if totalSpCoordinatesUsed==2

    if timePresent
      
      set(handles.fixColorscaleBox,'Enable','off');
      set(handles.colorMinEdit,'Enable','off');
      set(handles.colorMaxEdit,'Enable','off');
      set(handles.saveMapDataAsTextButton,'Enable','on');

      [xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
      % First, select the proper output, put it into a matrix and
      % resize the output matrix into the pre-selected grid dimensions

      numuMu = reshape(gbmeMom{7,tNowOut}(:,2),size(xMesh,1),size(xMesh,2));
      % Cope with potential infinite numbers in results: Convert them to NaNs.
      numuMu(find(isinf(numuMu))) = NaN;

      if get(handles.extFigureBox,'Value')  % Separate figure or not?
        axes(handles.bmeMapsAxes);
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.bmeMapsAxes);
      end
      % Plot the graph
      %
      mapDataText = [xMesh(:) yMesh(:) ...
                     tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                     reshape(numuMu,size(xMesh,1)*size(xMesh,2),1)];
                   
      contourmap(handles,xMesh,yMesh,numuMu,displayString,maskFilename,maskPathname,1);               
    
    else
      set(handles.feedbackEdit,'String',...
        'Temporal order mu not available in spatial-only case');
      axes(handles.bmeMapsAxes);
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end

  else
    set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
    pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
  displayString = 'Can not plot: GBME Estimates Required';
  set(handles.feedbackEdit,'String',displayString);
end


%%
function mapGbmeNuMinusMu(handles,tNowActual,tNowOut);
%
% Plots GBME estimation temporal order mu in the specified space 
% at the requested temporal instance tNowActual
%
global gbmeMom
global maskFilename maskPathname maskKnown
global meanTrendAtk meanTrendAtkAtInst
global totalSpCoordinatesUsed totalCoordinatesUsed
global outGrid
global timePresent
global positiveDataOnly
global displayString
global mapInOrigSpace trsfMapIndx
global applyTransformVis transformTypeStrVis
global minTout minTdata
global colorScaleMin colorScaleMax
global mapDataText

if gbmeMom{1,1}

  if totalSpCoordinatesUsed==2

    if timePresent
      
      set(handles.fixColorscaleBox,'Enable','off');
      set(handles.colorMinEdit,'Enable','off');
      set(handles.colorMaxEdit,'Enable','off');
      set(handles.saveMapDataAsTextButton,'Enable','on');

      [xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
      % First, select the proper output, put it into a matrix and
      % resize the output matrix into the pre-selected grid dimensions

      numuNu = reshape(gbmeMom{7,tNowOut}(:,1),size(xMesh,1),size(xMesh,2));
      % Cope with potential infinite numbers in results: Convert them to NaNs.
      numuNu(find(isinf(numuNu))) = NaN;
      numuMu = reshape(gbmeMom{7,tNowOut}(:,2),size(xMesh,1),size(xMesh,2));
      % Cope with potential infinite numbers in results: Convert them to NaNs.
      numuMu(find(isinf(numuMu))) = NaN;
      nuMinusMu = numuNu - numuMu;          % Ranges between -2 and 2

      if get(handles.extFigureBox,'Value')  % Separate figure or not?
        axes(handles.bmeMapsAxes);
        image(imread('guiResources/ithinkPic.jpg'));
        axis image
        axis off
        figure;
      else
        axes(handles.bmeMapsAxes);
      end
      % Plot the graph
      %
      mapDataText = [xMesh(:) yMesh(:) ...
                     tNowActual*ones(size(xMesh,1)*size(xMesh,2),1) ...
                     reshape(nuMinusMu,size(xMesh,1)*size(xMesh,2),1)];
      
      contourmap(handles,xMesh,yMesh,nuMinusMu,displayString,maskFilename,maskPathname,1);              
    
    else
      set(handles.feedbackEdit,'String',...
        'Map of difference nu-mu not available in spatial-only case');
      axes(handles.bmeMapsAxes);
      image(imread('guiResources/ithinkPic.jpg'));
      axis image
      axis off
    end

  else
    set(handles.feedbackEdit,'String','Only 2-D in space plots supported');
    pause(2);
		set(handles.feedbackEdit,'String',displayString);
	end

else
  displayString = 'Can not plot: GBME Estimates Required';
  set(handles.feedbackEdit,'String',displayString);
end

%%
function displayString=CheckBmeType(bmeMod,bmeMom,bmePdf,bmeCin)
if bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
  displayString = ['Estimated Mode present'];
elseif ~bmeMod{1,1} & bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
  displayString = ['Estimated Moments present'];
elseif ~bmeMod{1,1} & ~bmeMom{1,1} & bmePdf{1,1} & ~bmeCin{1,1}
  displayString = ['Estimated PDF present'];
elseif ~bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & bmeCin{1,1}
  displayString = ['Estimated CI present'];
elseif bmeMod{1,1} & bmeMom{1,1} & ~bmePdf{1,1} & ~bmeCin{1,1}
	displayString = ['Estimated Mode, Moments present'];
elseif bmeMod{1,1} & ~bmeMom{1,1} & bmePdf{1,1} & ~bmeCin{1,1}
	displayString = ['Estimated Mode, PDF present'];
elseif bmeMod{1,1} & ~bmeMom{1,1} & ~bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Mode, CI present'];
elseif ~bmeMod{1,1} & bmeMom{1,1} & bmePdf{1,1} & ~bmeCin{1,1}
	displayString = ['Estimated Moments, PDF present'];
elseif ~bmeMod{1,1} & bmeMom{1,1} & ~bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Moments, CI present'];
elseif ~bmeMod{1,1} & ~bmeMom{1,1} & bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated PDF, CI present'];
elseif bmeMod{1,1} & bmeMom{1,1} & bmePdf{1,1} & ~bmeCin{1,1}
	displayString = ['Estimated Mode, Moments, PDF present'];
elseif bmeMod{1,1} & bmeMom{1,1} & ~bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Mode, Moments, CI present'];
elseif bmeMod{1,1} & ~bmeMom{1,1} & bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Mode, PDF, CI present'];
elseif ~bmeMod{1,1} & bmeMom{1,1} & bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Moments, PDF, CI present'];
elseif bmeMod{1,1} & bmeMom{1,1} & bmePdf{1,1} & bmeCin{1,1}
	displayString = ['Estimated Mode, Moments, PDF, CI present'];
end



%% 
function BMEInit(handles)

global displayString
global KSprocessType KSprocessTypeInit
global bmeMod bmeMom bmePdf bmeCin gbmeMom
global maskKnown
global prevMaskState
global prevExtFigState
global outGrid totalCoordinatesUsed
global pdfScaleFactor maxPdfs pdfCutoff
global firstOutInst lastOutInst
global cameFromMainMenu
global timePresent
global positiveDataOnly
global mapInOrigSpaceBme trsfMapIndxBme
global applyTransformVisBme transformTypeStrVisBme
global colorScaleMin colorScaleMax
global mapDataText

if KSprocessType==0 | KSprocessType==1 % Initializations in BME case

        % Find information on transformation type, if applicable
        % 0: No transformation, 1: N-scores, 2: Box-Cox
  if bmeMod{1,1}
    applyTransformVisBme = bmeMod{5,1}{1};
    transformTypeStrVisBme = bmeMod{5,1}{2};
	elseif  bmeMom{1,1}
    applyTransformVisBme = bmeMom{7,1}{1};
    transformTypeStrVisBme = bmeMom{7,1}{2};
	elseif  bmePdf{1,1}
    applyTransformVisBme = bmePdf{6,1}{1};
    transformTypeStrVisBme = bmePdf{6,1}{2};
  elseif  bmeCin{1,1}
    applyTransformVisBme = bmeCin{9,1}{1};
    transformTypeStrVisBme = bmeCin{9,1}{2};
  end

	% The following initialize the buttons on the screen regarding the space
	% for the visualization. 
	% Based on the format the results are stored in the output files, the index
	% trsfMapIndxBme = 1, if the map is in the original space, or 
	% trsfMapIndxBme = 2, if the map is in the transformation space.
	set(handles.origSpaceButton,'Enable','on');  % Initialize
	set(handles.origSpaceButton,'Value',1);      % Initialize
	set(handles.trsfSpaceButton,'Enable','on');  % Initialize
	set(handles.trsfSpaceButton,'Value',0);      % Initialize

	set(handles.showTrsfInfoButton,'Enable','on');
	mapInOrigSpaceBme = 1;                       % Initialize
	trsfMapIndxBme = 1;                          % Initialize

	set(handles.pdfScaleSlider,'Enable','on');
	set(handles.pdfScaleEdit,'Enable','on');
	pdfScaleFactor = 1;                          % Initialize
	maxPdfs = 4;         % Initilize - may become adjustable in coming versions
        % Initialize - define a probability density cutoff limit.
        % If the user is mapping a non-negative quantity, do not allow the estimation
        % PDFs to show their lower tails spanning in the negative range in the plots.
	if positiveDataOnly
    pdfCutoff = 0; 
  else
    pdfCutoff = [];
  end

	gbmeMom{1,1} = [0];     % Indicate that GBME results are not present.

elseif KSprocessType==2                         % Initializations in GBME case

  applyTransformVisBme = [];                    % Initialize
  transformTypeStrVisBme = [];                  % Initialize
  set(handles.origSpaceButton,'Enable','on');   % Initialize
  set(handles.origSpaceButton,'Value',1);       % Initialize
  set(handles.trsfSpaceButton,'Enable','off');  % Initialize
  set(handles.trsfSpaceButton,'Value',0);       % Initialize

  set(handles.showTrsfInfoButton,'Enable','off');
  mapInOrigSpaceBme = 1;                        % Initialize
  trsfMapIndxBme = 1;                           % Initialize

  set(handles.pdfScaleSlider,'Enable','off');
  set(handles.pdfScaleEdit,'Enable','off');

  bmeMod{1,1} = [0];      % Indicate that BME results are not present.
  bmeMom{1,1} = [0];      % Indicate that BME results are not present.
  bmePdf{1,1} = [0];      % Indicate that BME results are not present.
  bmeCin{1,1} = [0];      % Indicate that BME results are not present.
        
end

colorScaleMin = [];                             % Reset 
colorScaleMax = [];                             % Reset 
set(handles.fixColorscaleBox,'Value',0)
set(handles.colorMaxEdit,'Enable','off');
set(handles.colorMaxEdit,'String','');
set(handles.colorMinEdit,'Enable','off');
set(handles.colorMinEdit,'String','');

mapDataText = [];                               % Reset 
set(handles.saveMapDataAsTextButton,'Enable','on');

set(handles.addMaskBox,'Value',0);              % Reset
maskKnown = 0;                                  % Reset
prevMaskState = 0;                              % Reset
      
set(handles.graphTypeMenu,'Value',1);    % Reset the map choice menu
axes(handles.bmeMapsAxes)
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off

%%
function CreateMap(handles,tNowActual,tNowOut)

switch get(handles.graphTypeMenu,'Value')
	case 2     % Displays BMEmean. Requires moments or pdf results.
    mapBmeEstimationMean(handles,tNowActual,tNowOut);          % Create map
	case 3    % Displays BMEmode. Requires mode results
    mapBmeEstimationMode(handles,tNowActual,tNowOut);          % Create map
	case 4    % Displays BME estimation error var. Requires moments or pdf results
    mapBmeEstimationVariance(handles,tNowActual,tNowOut);      % Create map         
	case 5    % Displays BME estimation error standard dev. Requires moments results
    mapBmeEstimationStDeviation(handles,tNowActual,tNowOut);   % Create map
	case 6    % Displays BME skewness coefficient. Requires moments or pdf results.
    mapBmeEstimationSkewness(handles,tNowActual,tNowOut);      % Create map
	case 7    % Displays BME posterior PDFs at selected points
    mapBmeEstimationSamplePdfs(handles,tNowActual,tNowOut);    % Create map
	case 8    % Displays size of selected BME estimation confidence interval
    mapBmeConfIntervalSize(handles,tNowActual,tNowOut);        % Create map
	case 9    % Displays lower limits of estimation confidence intervals
    mapBmeConfIntervalLowerLimits(handles,tNowActual,tNowOut); % Create map
	case 10   % Displays upper limits of estimation confidence intervals
    mapBmeConfIntervalUpperLimits(handles,tNowActual,tNowOut); % Create map
	case 11    % Displays value of estimation PDF at the CI limits
    mapBmeConfIntervalPdfValues(handles,tNowActual,tNowOut);   % Create map
	case 12    % Displays value of estimation PDF at the CI limits
    mapGbmeNu(handles,tNowActual,tNowOut);                     % Create map
	case 13    % Displays value of estimation PDF at the CI limits
    mapGbmeMu(handles,tNowActual,tNowOut);                     % Create map
	case 14    % Displays value of estimation PDF at the CI limits
    mapGbmeNuMinusMu(handles,tNowActual,tNowOut);              % Create map
end    % End switch


%% Contourmap with Mask
function contourmap(handles,xMesh,yMesh,zMesh,displayString,maskFilename,maskPathname,poption)    
global colorScaleMin colorScaleMax;
if nargin<8
  poption=0;
end;

if get(handles.addMaskBox,'Value')==1      
			% Mask adding code. Will execute if masking option is on.
  initialDir = pwd;               % Save the current directory path
  cd (maskPathname);              % Go where the masking file resides
  finddot=findstr(maskFilename,'.');      
  if strcmp(maskFilename(finddot+1:end),'m')
    contourmap0(handles,xMesh,yMesh,zMesh,displayString,poption);
        % Remove the ending ".m" from the filename and execute the contents
    eval(regexprep(maskFilename,'.m',''));
	elseif strcmp(maskFilename(finddot+1:end),'shp')
    boundata=shaperead(maskFilename);
    inidx=zeros(size(xMesh(:),1),1);
    for i=1:size(boundata,1)
      [in bnd]=inpoly([xMesh(:) yMesh(:)],[(boundata(i).X)' (boundata(i).Y)']);
      inidx(in,1)=1;
    end;
    idxnan=find(inidx==0);
    mom1msk=zMesh;
    mom1msk(idxnan)=NaN;
    contourmap0(handles,xMesh,yMesh,mom1msk,displayString,poption);        
	end;                
	cd (initialDir)                 % Return to initial directory
else
	contourmap0(handles,xMesh,yMesh,meanAtk,displayString,poption);
end     

%% Contourmap without mask
function contourmap0(handles,xMesh,yMesh,zMesh,displayString,poption)   
global colorScaleMin colorScaleMax;

if poption==0
  [trash1,hh] = contourf(xMesh,yMesh,zMesh);
  if get(handles.fixColorscaleBox,'Value')
    if ~isempty(colorScaleMin) & ~isempty(colorScaleMax)
      set(hh,'LevelList',[colorScaleMin:...
        (colorScaleMax-colorScaleMin)/5:colorScaleMax]);
    else
      displayString1 = ['Fixed color scale bounds not set. Using default'];
      set(handles.feedbackEdit,'String',displayString1);
      pause(2);
    end
  end;
  colormap('default');
  cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
  colorbar;  
elseif poption==1
  [hh] = pcolor(xMesh,yMesh,nuMinusMu);
  caxis([-2 2]);
      % Contours are not used: If the value of Mu is the same everywhere, 
      % then the plot will appear blank! We use pcolor for the mu map
      % in the 2 preceding lines, instead.                 
      %[trash1,hh] = contourf(xMesh,yMesh,numuMu);
      %set(hh,'LevelList',[-2 -1 0 1 2],'TextList',[-2 -1 0 1 2],'LevelStep',1);
  shading flat
  colormap('default');
  h = colormap(bone(5));
  cmap = h(end:-1:1,:);
  colormap(cmap);
  hc = colorbar;
  hold off;
end;
axis image;
xlabel('x-Axis');
ylabel('y-Axis');
set(handles.feedbackEdit,'String',displayString);

%% Useless functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function feedbackEdit_Callback(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of feedbackEdit as text
%        str2double(get(hObject,'String')) returns contents of feedbackEdit as a double
global displayString

% Disregard any editing by the user
set(handles.feedbackEdit,'String',displayString); 


%%
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

%%
% --- Executes during object creation, after setting all properties.
function pdfScaleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pdfScaleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%
% --- Executes during object creation, after setting all properties.
function tInstanceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tInstanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%
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

%%
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

%%
% --- Executes during object creation, after setting all properties.
function pdfScaleEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pdfScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes during object creation, after setting all properties.
function colorMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
% --- Executes during object creation, after setting all properties.
function colorMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
