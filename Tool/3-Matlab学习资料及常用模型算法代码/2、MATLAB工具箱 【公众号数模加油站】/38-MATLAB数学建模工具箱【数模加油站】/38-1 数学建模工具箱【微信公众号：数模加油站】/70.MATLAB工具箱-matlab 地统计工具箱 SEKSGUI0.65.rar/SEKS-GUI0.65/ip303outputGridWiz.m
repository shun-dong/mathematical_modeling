function varargout = ip303outputGridWiz(varargin)
%IP303OUTPUTGRIDWIZ M-file for ip303outputGridWiz.fig
%      IP303OUTPUTGRIDWIZ, by itself, creates a new IP303OUTPUTGRIDWIZ or raises the existing
%      singleton*.
%
%      H = IP303OUTPUTGRIDWIZ returns the handle to a new IP303OUTPUTGRIDWIZ or the handle to
%      the existing singleton*.
%
%      IP303OUTPUTGRIDWIZ('Property','Value',...) creates a new IP303OUTPUTGRIDWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip303outputGridWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP303OUTPUTGRIDWIZ('CALLBACK') and IP303OUTPUTGRIDWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP303OUTPUTGRIDWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip303outputGridWiz

% Last Modified by GUIDE v2.5 28-Feb-2006 09:22:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip303outputGridWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip303outputGridWiz_OutputFcn, ...
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


% --- Executes just before ip303outputGridWiz is made visible.
function ip303outputGridWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip303outputGridWiz
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

% UIWAIT makes ip303outputGridWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create soft data types pictures
axes(handles.gridFigAxes)
image(imread('guiResources/grid.png'));
axis off

% --- Outputs from this function are returned to the command line.
function varargout = ip303outputGridWiz_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% PRELIMINARY SETTINGS
%
% Are we returning to the output grid wizard? If so, an output style of the
% 3 available is already chosen. If appropriate, an input filename has been
% provided, too. Display the filename or the proper message in the box.
%
% Notice that we choose not to remember 
%
global chosenOutputStyle
global grdFilename 
global hardDataPresent softDataPresent
global ch cs zh limi
global chOrig zhOrig csOrig
global minThard maxThard minTsoft maxTsoft minTdata maxTdata dataTimeSpan
global timePresent
global positiveDataOnly

chOrig = ch;
zhOrig = zh;
csOrig = cs;

chosenOutputStyle = 0;
% Begin with no output grid selection as default
set(handles.outgridFormatMenu, 'Value',1); 

grdFilename = [];
set(handles.fileChoiceEdit,'String','No Output Info file present');

if timePresent           % Get some general information on the data time span
  
  if hardDataPresent & softDataPresent
    timeColumn = size(ch,2);            % Temporal coords stored in this one
    minThard = min(ch(:,timeColumn));   % Earliest time for which we have SD
    maxThard = max(ch(:,timeColumn));   % Latest time for which we have SD

    timeColumn = size(cs,2);            % Temporal coords stored in this one
    minTsoft = min(cs(:,timeColumn));   % Earliest time for which we have SD
    maxTsoft = max(cs(:,timeColumn));   % Latest time for which we have SD

    minTdata = min(minThard,minTsoft);
    maxTdata = max(maxThard,maxTsoft);
    dataTimeSpan = maxTdata-minTdata+1; % Total period in appropriate time units
  elseif hardDataPresent & ~softDataPresent
    minTsoft = [];
    maxTsoft = [];
    timeColumn = size(ch,2);            % Temporal coords stored in this one
    minThard = min(ch(:,timeColumn));   % Earliest time for which we have HD
    maxThard = max(ch(:,timeColumn));   % Latest time for which we have HD
    minTdata = minThard;
    maxTdata = maxThard;
    dataTimeSpan = maxTdata-minTdata+1; % Total period in appropriate time units
  elseif ~hardDataPresent & softDataPresent
    minThard = [];
    maxThard = [];
    timeColumn = size(cs,2);            % Temporal coords stored in this one
    minTsoft = min(cs(:,timeColumn));   % Earliest time for which we have SD
    maxTsoft = max(cs(:,timeColumn));   % Latest time for which we have SD
    minTdata = minTsoft;
    maxTdata = maxTsoft;
    dataTimeSpan = maxTdata-minTdata+1; % Total period in appropriate time units
  else
    errordlg({'ip303outputGridWiz.m:PRELIMINARY SETTINGS:';...
              'The program suggests no hard or soft data are present.'},...
              'GUI software Error')
  end
else
  minThard = 1;
  maxThard = 1;
  minTsoft = 1;
  maxTsoft = 1;
  minTdata = 1;
  maxTdata = 1;
  dataTimeSpan = 1;
end

% Does the data set contain positive values only, or not?
% We need to know so that the estimation stage produces appropriate output.
% Search the data for negative values to provide an initial assessment.
% The users will provide their informed input by choosing the right button.
if hardDataPresent
  [hdNegRowIndx,hdNegColIndx] = find(zh<0);        % Scan hard data
else
  hdNegRowIndx = [];
end
if softDataPresent
  [sdNegRowIndx,sdNegColIndx] = find(limi<0);      % Scan soft data
else
  sdNegRowIndx = [];
end
if ~isempty(hdNegRowIndx) | ~isempty(sdNegRowIndx) % There are negats in data
  set(handles.posYesButton, 'Value', 0);           % Initialize
  set(handles.posNoButton, 'Value', 1);            % Initialize
  positiveDataOnly = 0;                            % Initialize
else                                               % Only positive data
  set(handles.posYesButton, 'Value', 1);           % Initialize
  set(handles.posNoButton, 'Value', 0);            % Initialize
  positiveDataOnly = 1;                            % Initialize
end





% --- Executes on selection change in outgridFormatMenu.
function outgridFormatMenu_Callback(hObject, eventdata, handles)
% hObject    handle to outgridFormatMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns outgridFormatMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outgridFormatMenu
global grdFilename chosenOutputStyle 

outFormChoice = get(handles.outgridFormatMenu, 'Value');
switch outFormChoice
  case 1
    chosenOutputStyle = 0; % Do nothing. This is the title.
  case 2
    chosenOutputStyle = 1; % The user will provide limits and spacing
  case 3
    chosenOutputStyle = 2; % The user will provide limits and # of nodes
  case 4
    chosenOutputStyle = 3; % The user will provide limits, # of nodes and spacing
  otherwise
    errordlg({'ip303outputGridWiz.m:outgridFormatMenu:';...
             'The switch commands detected that the outgridFormatMenu';...
             ['returns a value of outFormChoice = ' num2str(outFormChoice)];...
             'whereas currently only values 1, 2, 3 and 4 are charted.'},...
             'GUI software Error')
end
grdFilename = [];       % If a choice is made, reset the given information.
set(handles.fileChoiceEdit,'String','No Output Info file present');





% --- Executes during object creation, after setting all properties.
function outgridFormatMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outgridFormatMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function fileChoiceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileChoiceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileChoiceEdit as text
%        str2double(get(hObject,'String')) returns contents of fileChoiceEdit as a double
global grdFilename

if ~ischar(grdFilename)
    set(handles.fileChoiceEdit,'String','No Output Points/Grid file present');
    return
else
    set(handles.fileChoiceEdit,'String',grdFilename);
end





% --- Executes during object creation, after setting all properties.
function fileChoiceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileChoiceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in getDataPushbutton.
function getDataPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to getDataPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grdFilename grdPathname;

[grdFilename,grdPathname] = uigetfile({'*.txt';'*.xls'},'Select Output Grid Data file');
if ~ischar(grdFilename)
  set(handles.fileChoiceEdit,'String','No Output Info file present');
  return
else
  set(handles.fileChoiceEdit,'String',grdFilename);
end





% --- Executes on button press in posYesButton.
function posYesButton_Callback(hObject, eventdata, handles)
% hObject    handle to posYesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of posYesButton
global positiveDataOnly

set(handles.posYesButton, 'Value', 1); 
set(handles.posNoButton, 'Value', 0); 
positiveDataOnly = 1;





% --- Executes on button press in posNoButton.
function posNoButton_Callback(hObject, eventdata, handles)
% hObject    handle to posNoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of posNoButton
global positiveDataOnly

set(handles.posYesButton, 'Value', 0); 
set(handles.posNoButton, 'Value', 1); 
positiveDataOnly = 0;






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

delete(handles.figure1);                          % Close the splash window...
ip302p1softDataWiz('Title','Soft Data Wizard');  % ...and procede to the previous unit.





% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global grdFilename grdPathname totalCoordinatesUsed
global outGrid ch cs ck ckIn2D usingGrid
global dataCoordMin dataCoordMax
global chosenOutputStyle

ckIn2D = [];                  % Initialize (to be used only in 3 total coordinates)

% Perform some preparatory work to save the span of all the input data
allLoci = [ch;cs];
for iCoord=1:totalCoordinatesUsed                   % For each of the dimensions we work in
    dataCoordMin(iCoord) = min(allLoci(:,iCoord));  % Find the minimum a datum is located at
    dataCoordMax(iCoord) = max(allLoci(:,iCoord));  % Find the maximum a datum is located at
end

if ~chosenOutputStyle         % User has not selected a format for his output data
  errordlg({'You must provide an Output Grid data format and the data to continue!';...
           'Please make your choice from the drop-down menu on the screen.'},...
           'No Output Grid data format chosen!')  
elseif ~ischar(grdFilename)   % If the user has not provided a grid data file
  errordlg('Please provide first an Output Grid Data info file to continue!',...
           'No Output Grid Data information given!')  
else % There is a filename provided for grid data input. Continue appropriately
  outGrid = getCustomEstiGridSize; %%%%     % Obtain estimation grid data (cell array)
  % If outGrid is empty, user has already been warned
  if ~isempty(outGrid{1})   % Then outGrid is not empty
    switch totalCoordinatesUsed
      case 1
        ck = outGrid{1}';
      case 2
        [xMesh yMesh] = meshgrid(outGrid{1},outGrid{2});
        ck = [xMesh(:) yMesh(:)];
      case 3
        [xMesh yMesh zMesh] = meshgrid(outGrid{1},outGrid{2},outGrid{3});
        ck = [xMesh(:) yMesh(:) zMesh(:)];
        % The above grid is just a repetition (in z or in t) of the following:
        [xMesh yMesh] = meshgrid(outGrid{1},outGrid{2});
        ckIn2D = [xMesh(:) yMesh(:)];
    end
    usingGrid = 1;
    delete(handles.figure1);
    ip304p1explorAnal('Title','Data Exploration');   % Proceed to the next step.
  end
end





function [outGrid] = getCustomEstiGridSize;
%
% Return a cell array that has 3 arrays, one for each dimension. Each array 
% has the grid nodes for the corresponding dimension as provided by the user.
%
global grdFilename grdPathname totalCoordinatesUsed totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax
global timePresent
global minTdata maxTdata minTout maxTout
global chosenOutputStyle
global outputTimeSpan

nCoords = totalCoordinatesUsed;      % Use a handy name
nSpCoords = totalSpCoordinatesUsed;  % Use a handy name

% STEP 1: Read data file contents

initialDir = pwd;                    % Save the current directory path
cd (grdPathname);                    % Go where the grid info file resides

linenumber = 0;                      % Initialize counter of lines that contain data
if isempty(xlsfinfo(grdFilename))    % If it is not Excel format, expect an ASCII file

  fid = fopen(grdFilename,'r');      % Check if the file can be opened
  if fid==-1
    fclose('all');
    errordlg(['Problem opening file ' grdFilename],...
      'Data file error!');
  end

  while ~feof(fid)                   % Start reading the file to its end
    str = fgetl(fid);                % Get one line at a time
    if str~=-1                       % If this is not the end of line
      linenumber = linenumber+1;     % Keep track of the line number itself
      % sscanf reads the contents into a column vector. Keep this in mind.
      fileVal{linenumber} = sscanf(str,'%g');   % Store the line contents into individual values
    end
  end

  st = fclose(fid);
  if st==-1,
    fclose('all');
    cd (initialDir);
    errordlg(['Could close properly file ' grdFilename],...
             'Data file error!');
  end;

else                                 % This is an Excel file
  
  [grdVal,grdValname] = xlsread(grdFilename);
  for is=1:size(grdVal,1)            % For each line in the file
    % Reading an Excel file produces an array whose columns are equal to the
    % file line that has the maximum columns. Each line fills any empty spaces
    % till the max column number with NaNs. If the current line in the file is 
    % empty, it will appear as an empty array "getLine". Otherwise, the 
    % following lines store temporarily all the non-NaN contents in "fileVal".
    getLine = grdVal(is,isfinite(grdVal(is,:)));
    if ~isempty(getLine)
      linenumber = linenumber+1;     % Keep track of the line number itself
      % The contents in getline are stored in a row vector. We need a matching
      % style with the sscanf data vertical storing for consistency later. Therefore:
      fileVal{linenumber} = getLine';
    end
  end
  
end
cd (initialDir);                     % Return to where this function was evoked from

% STEP 2: Process data file contents

is = 0;
tempval = [];
emptyLine = 0;
tInfoRead = 0;
allOk = 1;
for is=1:linenumber                  % For each cell in the array that holds the input
 
  tempval = fileVal{is};             % Get the current dimension info (tempval: 3x1)
  nTempval = size(tempval,1);        % Number of values in the currnet line
  if nTempval~=3                     % If more data are found than allowed...
    errordlg({[num2str(nTempval) ' numbers found in line ' ...
              num2str(is) ' of the input file.'];...
              'Format is inconsistent with the requirement for 3 numbers.';,...
              'Please revise your Output Grid data file.'},...
              'Input file format issue!')
    allOk = 0;
    break;
  end

  if is<=nSpCoords                   % Perform actions for preset spatial dimensions
    switch chosenOutputStyle
      case 1                         % Grid limits and node spacing are known
        directionMin(is) = tempval(1);
        directionDs(is) = tempval(2);
        directionMax(is) = tempval(3);
      case 2                         % Grid limits and # of nodes are known
        directionMin(is) = tempval(1);
        directionDs(is) = (tempval(3)-tempval(1)) / (tempval(2)-1);
        directionMax(is) = tempval(3);
      case 3                         % Grid limits, # of nodes and spacing are known
        directionMin(is) = tempval(1);
        directionDs(is) = tempval(3);
        directionMax(is) = tempval(1) + ((tempval(2)-1)*tempval(3));
      otherwise
        errordlg({'ip303outputGridWiz.m:getCustomEstiGridSize:';...
          'The switch commands detected that the chosenOutputStyle';...
          ['returns a value of chosenOutputStyle = ' num2str(chosenOutputStyle)];...
          'whereas currently only values 1, 2, and 3 are charted.'},...
          'GUI software Error')
    end
  else                               % In case more lines are found than spatial dimensions
 
    if timePresent & ~tInfoRead      % If temporal grid info is not present in a S/T study
      % Read temporal grid info. Any further lines in the file will be ignored
      switch chosenOutputStyle
        case 1                         % Grid limits and node spacing are known
          directionMin(is) = tempval(1);
          directionDs(is) = tempval(2);
          directionMax(is) = tempval(3);
        case 2                         % Grid limits and # of nodes are known
          directionMin(is) = tempval(1);
          directionDs(is) = (tempval(3)-tempval(1))/(tempval(2)-1);
          directionMax(is) = tempval(3);
        case 3                         % Grid limits, # of nodes and spacing are known
          directionMin(is) = tempval(1);
          directionDs(is) = tempval(3);
          directionMax(is) = tempval(1) + ((tempval(2)-1)*tempval(3));
        otherwise
          errordlg({'ip303outputGridWiz.m:getCustomEstiGridSize:';...
            'The switch commands detected that the chosenOutputStyle';...
            ['returns a value of chosenOutputStyle = ' num2str(chosenOutputStyle)];...
            'whereas currently only values 1, 2, and 3 are charted.'},...
            'GUI software Error')
      end
      tInfoRead = 1;                 % Mark the temporal grid info as entered
      if mod(tempval(2),floor(tempval(2)))
        errordlg({['In data line ' num2str(is) ' of the input file ',...
            'the temporal step is not an integer.'];...
            'Please revise your Output Grid data file so that';...
            'whole steps between temporal instances are used.'},...
            'Data file error!');
        allOk = 0;
        break;
      end
    else                             % Otherwise, the file contains redundant info
      errordlg({'The data file you provided contains more than'; ...
               [num2str(totalCoordinatesUsed) ' data lines for the current '...
               num2str(totalCoordinatesUsed) '-D case.'];...
               'Please revise the file so that it contains';...
               'only the necessary information.'},...
               'Data file issue!');
      allOk = 0;
      break;
    end
  end
   
  if ( (directionMax(is)<directionMin(is) & directionDs(is)>0) | ...
       (directionMax(is)>directionMin(is) & directionDs(is)<0) )
    errordlg({['In data line ' num2str(is) ' of the input file there is'];...
             'no logic progression from the lower to the upper limit.';...
             'Please revise your output grid data file';...
             'to contain the grid limits in ascending order.'},...
             'Data file error!');
    allOk = 0;
    break;
  end

end

if ~linenumber                        % No lines read. This is an empty file  
    errordlg({'The Output Grid Data file you provided contains no useful information';...
             'Please check your input file again.'},...
             'Empty Grid Data file!');
    allOk = 0;
    for i=1:3
        outGrid{i} = [];
    end
elseif linenumber<nSpCoords & allOk   % Fewer data read than what are necessary
    errordlg({['The data file contains ' num2str(linenumber) ' line(s), one for each dimension'];...
         ['whereas this is a ' num2str(nCoords) '-D case.'];...
         'Please revise your Output Grid data file.'},...
         'Data file issue!');
    allOk = 0;
    for i=1:3
        outGrid{i} = [];
    end
elseif timePresent & ~tInfoRead & allOk  % If user has not provided t-grid info
    %% Use information from available data
    %directionMin(totalCoordinatesUsed) = minTdata;  % Go from the first
    %directionDs(totalCoordinatesUsed) = 1;          % ...at a step of 1 t-unit
    %directionMax(totalCoordinatesUsed) = maxTdata;  % ...to the last t-instance
    errordlg({'The Output Grid Data file you provided contains no information';...
             'on the temporal grid. Please check your input file again.'},...
             'Data file issue!');
    allOk = 0;
    for i=1:3
        outGrid{i} = [];
    end    
elseif ~allOk                         % In case anything went wrong 
    for i=1:3
        outGrid{i} = [];
    end    
else                                  % Define the output grid based on data read
    for i=1:totalCoordinatesUsed
        outGrid{i} = directionMin(i):directionDs(i):directionMax(i);
    end
    iRem = 3-totalCoordinatesUsed;
    for i=1:iRem      % Initialize the grid variables of the unused dimensions.
        outGrid{totalCoordinatesUsed+i} = [];
    end
%directionMin  % test
%directionDs   % test
%directionMax  % test
end

%outGrid{1}    % test
%outGrid{2}    % test
%outGrid{3}    % test
%pwd

if allOk
  if totalCoordinatesUsed>=1
    if directionDs(1)>0
      xMin = directionMin(1); dx = directionDs(1); xMax = directionMax(1);
    else
      xMax = directionMin(1); dx = directionDs(1); xMin = directionMax(1);
    end
    if totalCoordinatesUsed>=2
      if directionDs(2)>0
        yMin = directionMin(2); dy = directionDs(2); yMax = directionMax(2);
      else
        yMax = directionMin(2); dy = directionDs(2); yMin = directionMax(2);
      end
      if totalCoordinatesUsed==3
        if directionDs(3)>0
          zMin = directionMin(3); dz = directionDs(3); zMax = directionMax(3);
        else
          zMin = directionMin(3); dz = directionDs(3); zMax = directionMax(3);
        end
      end
    end
  end
  if totalCoordinatesUsed<3  % Account for parameters in case of reduced directions
    zMin = [];
    zMax = [];
    if totalCoordinatesUsed<2
      yMin = [];
      yMax = [];
    end
  end
  if timePresent             % Define how output spans in time
    switch totalSpCoordinatesUsed
      case 1
        outputTimeSpan = length(outGrid{totalCoordinatesUsed});
        minTout = yMin;
        maxTout = outGrid{totalCoordinatesUsed}(outputTimeSpan);
        dT = dy;
      case 2
        outputTimeSpan = length(outGrid{totalCoordinatesUsed});
        minTout = zMin;
        maxTout = outGrid{totalCoordinatesUsed}(outputTimeSpan);
        dT = dz;
      case 3
        errordlg({'This error occured because there are 3 spatial';...
                  'dimensions plus time present together.';...
                  'This event can not be handled by SEKS-GUI.'},... 
                  'SEKS-GUI error');
      otherwise
        errordlg({['Unknown option: ' num2str(totalSpCoordinatesUsed) ...
                  ' spatial dimensions.'];...
                  'This event can not be handled by SEKS-GUI.'},... 
                  'SEKS-GUI error');
    end
  else
    outputTimeSpan = 1;
    minTout = 1;
    maxTout = 1;
    dT = [];    
  end
end