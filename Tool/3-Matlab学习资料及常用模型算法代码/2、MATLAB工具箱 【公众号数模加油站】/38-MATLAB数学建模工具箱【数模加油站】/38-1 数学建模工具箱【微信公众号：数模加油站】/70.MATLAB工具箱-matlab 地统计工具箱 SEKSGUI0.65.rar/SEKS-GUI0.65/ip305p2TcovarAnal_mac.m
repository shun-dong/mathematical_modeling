function varargout = ip305p2TcovarAnal_mac(varargin)
%IP305P2TCOVARANAL_MAC M-file for ip305p2TcovarAnal_mac.fig
%      IP305P2TCOVARANAL_MAC, by itself, creates a new IP305P2TCOVARANAL_MAC or raises the existing
%      singleton*.
%
%      H = IP305P2TCOVARANAL_MAC returns the handle to a new IP305P2TCOVARANAL_MAC or the handle to
%      the existing singleton*.
%
%      IP305P2TCOVARANAL_MAC('Property','Value',...) creates a new IP305P2TCOVARANAL_MAC using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip305p2TcovarAnal_mac_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP305P2TCOVARANAL_MAC('CALLBACK') and IP305P2TCOVARANAL_MAC('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP305P2TCOVARANAL_MAC.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip305p2TcovarAnal_mac

% Last Modified by GUIDE v2.5 22-Jun-2006 15:42:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip305p2TcovarAnal_mac_OpeningFcn, ...
                   'gui_OutputFcn',  @ip305p2TcovarAnal_mac_OutputFcn, ...
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


% --- Executes just before ip305p2TcovarAnal_mac is made visible.
function ip305p2TcovarAnal_mac_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip305p2TcovarAnal_mac
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

% UIWAIT makes ip305p2TcovarAnal_mac wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip305p2TcovarAnal_mac_OutputFcn(hObject, eventdata, handles)
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
global thisVersion
global hardDataPresent softDataPresent
global timePresent
global ch zh cs totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory nl limi probdens softApprox
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMa5
global cPt cPtValues
global usingLog
global zhLog limiLog softApproxLog
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covInputFile covInputPath
global covModelST covParamST
global maxCorrRangeS lagsNumberS lagsLimitsS maxCorrRangeT lagsNumberT lagsLimitsT
global covModST covExpST nestedSTcounter
global displayString
global prevExtFigState
global minTdata maxTdata dataTimeSpan
global viewAzim viewElev
global sillWithinBounds 
global sRangeMin sRangeMax sRangeWithinBounds
global tRangeMin tRangeMax tRangeWithinBounds
global covModSTcell

axes(handles.stCovAxes2)
image(imread('guiResources/ithinkPic.jpg'));
axis image
axis off

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

if timePresent    % Define properly the s-distance between most remote data in space.
    maxEuclDistS = coord2dist( max(cPt(:,1:end-1)),min(cPt(:,1:end-1)) );
    % Fot t: maxEuclDistT = coord2dist( max(cPt(:,end)),min(cPt(:,end)) );
else
    maxEuclDistS = coord2dist( max(cPt(:,:)),min(cPt(:,:)) );
end
maxEuclDistT = dataTimeSpan; % Define the t-distance between most remote data in time.

covModST = struct('model',{},...           % 5 spots for up to 5
               'sill',{},...               % nested components. This
               'sPar',{},...             % can change in future versions.
               'sModelName',{},...         
               'tPar',{},...   
               'tModelName',{},...         % To store BMElib model names   
               'emptySpot',{},...        % An index for the struct
               'modIndex',{},...           % Index of current model showing
               'modOk',{},...          
               'modUse',{},...
               'parSet',{});              % Index to show if model parameters are set

set(handles.anisotropyMenu,'Value',1);  % Initialize using all-directions option.

displayString = 'Start by adding a S/T model from the list above';
set(handles.feedbackEdit,'String',displayString);

covInputFile = [];                  % Initialize.
nestedSTcounter = 0;                % Initialize.

covModelST = [];                    % Initialize.
covParamST = [];                    % Initialize.

viewAzim = 50;                      % Initialize.
viewElev = 25;                      % Initialize.

% Set the interval for the S range values
% The handle values range from 0 to 1, so a transformation is necessary. 
sRangeMin = 1e-6;                % We do not want 0 in the denominator
%% Use as max the max correlation range.
%sRangeMax = covExpST(choice).sMaxCorrRange; 
% Use as max the 150% of the max spatial data span.
if totalSpCoordinatesUsed==1
  sRangeMax = 1.5*(xMax-xMin);
elseif totalSpCoordinatesUsed==2
  sRangeMax = 1.5*(max((xMax-xMin),(yMax-yMin)));
end

% Set the interval for the T range values
% The handle values range from 0 to 1, so a transformation is necessary. 
tRangeMin = 1e-6;                % We do not want 0 in the denominator
%% Use as max the max correlation range.
%tRangeMax = covExpST(choice).tMaxCorrRange; 
% Use as max the 500% of the max temporal data span.
tRangeMax = 5*dataTimeSpan;

sillWithinBounds = 1;              % Initialize. A flag used in edit boxes
sRangeWithinBounds = 1;             % Initialize. A flag used in edit boxes
tRangeWithinBounds = 1;             % Initialize. A flag used in edit boxes

% set(handles.modelsPresentEdit,'String',num2str(nestedSTcounter)); % Initialize.
% set(handles.addSModelMenu,'Value',1);     % Initialize using "exponential" option.
% set(handles.currModelMenu,'Value',1);                             % Initialize to show 0.
% set(handles.modelTypeEdit,'String','NONE');                       % Initialize to show 0.
set(handles.sillEdit,'String','N/A','Enable','off');                                % Initialize.
% set(handles.sRangeEdit,'String','');                              % Initialize.
% set(handles.tRangeEdit,'String','');                              % Initialize.
set(handles.sPar1Edit,'String','N/A','Enable','off');
set(handles.sPar2Edit,'String','N/A','Enable','off');
set(handles.tPar1Edit,'String','N/A','Enable','off');
set(handles.tPar2Edit,'String','N/A','Enable','off');

prevExtFigState = 0;                % Initialize - plots in GUI window

% Plot the experimental covariance outcome previously found for all-directions.
% Include in the plot the distance at s=0 where the covariance is the data variance
%
choice = 1;
set(handles.graphTypeMenu,'Value',choice);  
if get(handles.extFigureBox,'Value')      % Separate figure or not?
  axes(handles.stCovAxes2)
  image(imread('guiResources/ithinkPic.jpg'));
  axis image
  axis off
  figure;
else
  axes(handles.stCovAxes2)
end
dataPts = [covExpST(choice).sCovDistance(:),...
           covExpST(choice).tCovDistance(:),...
           covExpST(choice).experimCov(:)];
set(handles.graphTypeMenu,'Value',1)
surf(covExpST(choice).sCovDistance,...
     covExpST(choice).tCovDistance,covExpST(choice).experimCov);
hold on
hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
hold off
view(viewAzim,viewElev)
cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
maxSdistance = max(max(covExpST(choice).sCovDistance));
maxTdistance = max(max(covExpST(choice).tCovDistance));
%axis image;
axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                               1.05*max(max(covExpST(choice).experimCov))]);
if thisVersion<7
  legend(hCov,[covExpST(choice).anisotropyString ' Experimental']);
else
  legend(hCov,[covExpST(choice).anisotropyString ' Experimental'],'Location','North');
end
xlabel('S-lag (in s-units)');
ylabel('T-lag (in t-units)');
zlabel('Covariance');

covModSTcell{1}=[]; % for the model usage entry
covModSTcell{2}=covModST;




% --- Executes on selection change in anisotropyMenu.
function anisotropyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to anisotropyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns anisotropyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from anisotropyMenu
global thisVersion
global covExpST
global zhDataToProcess softApproxDataToProcess
global displayString
global viewAzim viewElev

% Choice of covariance in all-directions (1), E-W (2), or N-S (3).
choice = get(handles.anisotropyMenu,'Value');
if covExpST(choice).dirOk  % If choice info already stored, load info on screen
  displayString = 'Presenting stored data for this choice';
  set(handles.feedbackEdit,'String',displayString);
  
  % Gather all point data (whether log-transformed or not).
  % Also provides correct set (HD only) in case where no SD approximations are used.
  cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

  set(handles.graphTypeMenu,'Value',choice);  
  % Plot the experimental covariance outcome
  % Include in the plot the distance at s=0 where the covariance is the data variance
  %
  if get(handles.extFigureBox,'Value')      % Separate figure or not?
    axes(handles.stCovAxes2)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    figure;
  else
    axes(handles.stCovAxes2)
  end
  dataPts = [covExpST(choice).sCovDistance(:),...
             covExpST(choice).tCovDistance(:),...
             covExpST(choice).experimCov(:)];
  if choice == 1
    set(handles.graphTypeMenu,'Value',1)
    surf(covExpST(choice).sCovDistance,...
         covExpST(choice).tCovDistance,covExpST(choice).experimCov);
    hold on
    hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
  elseif choice == 2
    set(handles.graphTypeMenu,'Value',2)
    surf(covExpST(choice).sCovDistance,...
         covExpST(choice).tCovDistance,covExpST(choice).experimCov);
    hold on
    hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
  elseif choice == 3
    set(handles.graphTypeMenu,'Value',3)
    surf(covExpST(choice).sCovDistance,...
         covExpST(choice).tCovDistance,covExpST(choice).experimCov);
    hold on
    hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
  end
  hold off
  view(viewAzim,viewElev)
  cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
  %axis image;
  maxSdistance = max(max(covExpST(choice).sCovDistance));
  maxTdistance = max(max(covExpST(choice).tCovDistance));
  axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                 1.05*max(max(covExpST(choice).experimCov))]);
  if thisVersion<7
    legend(hCov,[covExpST(choice).anisotropyString ' Experimental']);
  else
    legend(hCov,[covExpST(choice).anisotropyString ' Experimental'],'Location','North');
  end
  xlabel('S-lag (in s-units)');
  ylabel('T-lag (in t-units)');
  zlabel('Covariance');
else
  displayString = 'No information for this direction selection';
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



% --- Executes on selection change in graphTypeMenu.
function graphTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphTypeMenu
plotcovST(handles);


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




% --- Executes on button press in saveModDataButton.
function saveModDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveModDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModSTcell

used=find(covModSTcell{1}==1);
covSTmodels=covModSTcell{2};

if length(used)<1
  displayString='No S/T models are chosen';
  set(handles.feedbackEdit,'String',displayString);
  return;
else
  for i=1:length(used)
    covModelST{i}=covSTmodels(used(i)).model;
    covParamST{i}=[covSTmodels(used(i)).sill,covSTmodels(used(i)).sPar,covSTmodels(used(i)).tPar];
  end;
end;

covModDataFile = 'covSTmodelInfo.txt';
initialDir = pwd;              % Save the current directory path

if size(covModelST,2)>0
  [covModDataFile,covOutPath] = ...
      uiputfile('covSTmodelInfo.txt','Save covariance model info in a text file:');	
  if ~isequal(covModDataFile,0) & ~isequal(covOutPath,0)
    File = fullfile(covOutPath,covModDataFile);
    fid = fopen(File,'w');
    fprintf(fid,'SPATIOTEMPORAL MODEL TYPE        Sill        Par1        Par2        Par3        Par4\n');
  
    for i=1:length(used)
      if length(covParamST{i})==3
        fprintf(fid,'%25s%12.4f%12.4f%12.4f\n',...
          covModelST{i},covParamST{i}(1),covParamST{i}(2),covParamST{i}(3));
      elseif length(covParamST{i})==4
        fprintf(fid,'%25s%12.4f%12.4f%12.4f%12.4f\n',...
          covModelST{i},covParamST{i}(1),covParamST{i}(2),covParamST{i}(3),covParamST{i}(4));
      elseif length(covParamST{i})==5
        fprintf(fid,'%25s%12.4f%12.4f%12.4f%12.4f%12.4f\n',...
          covModelST{i},covParamST{i}(1),covParamST{i}(2),covParamST{i}(3),covParamST{i}(4),covParamST{i}(5));
      end;
    end
    fclose(fid);
  end;
else
  displayString='No S/T models are chosen';
  set(handles.feedbackEdit,'String',displayString);
end;

% --- Executes on button press in loadModDatabutton.
function loadModDatabutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadModDatabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModSTcell

initialDir = pwd;  

[covInputFileNew,covInputPath] = uigetfile('*.txt','Select the saved covariance model');
[nparam,models]=nparammodelsgui;
modnum=0;
if ~isequal(covInputFileNew,0) & ~isequal(covInputPath,0)
  cd(covInputPath);
  fid=fopen(covInputFileNew,'r');
  title=fgetl(fid);
  if isempty(strmatch('SPATIOTEMPORAL',title))
    displayString='Please choose a CORRECT SEKS-GUI covariance model file';
    set(handles.feedbackEdit,'String',displayString);
    return;
  end    
  while 1
    tline = fgetl(fid);
    if ~ischar(tline)   
      break;
    else 
      modnum=modnum+1;
      covModSTcell{1}=ones(1,modnum);
      covModST(modnum).sill=sscanf(tline,'%*s%f%*f%*f%*f%*f');
      covModST(modnum).model=sscanf(tline,'%s%*f%*f%*f%*f%*f');
      [isST,isSTsep,modelS,modelT]=isspacetime(covModST(modnum).model);
      covModST(modnum).sModelName=modelS;
      covModST(modnum).tModelName=modelT;
      nSpar=nparam{strmatch(modelS,models,'exact')};
      nTpar=nparam{strmatch(modelT,models,'exact')};
      switch nTpar
        case 1
          switch nSpar
            case 1
              covModST(modnum).sPar=[];
              covModST(modnum).tPar=[];
            case 2
              covModST(modnum).sPar=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              covModST(modnum).tPar=[];
            case 3
              a1=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              a2=sscanf(tline,'%*s%*f%*f%f%*f%*f');
              covModST(modnum).sPar=[a1 a2];
              covModST(modnum).tPar=[];
          end;
        case 2
          switch nSpar
            case 1
              covModST(modnum).sPar=[];
              covModST(modnum).tPar=sscanf(tline,'%*s%*f%f%*f%*f%*f');
            case 2
              covModST(modnum).sPar=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              covModST(modnum).tPar=sscanf(tline,'%*s%*f%*f%f%*f%*f');
            case 3
              a1=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              a2=sscanf(tline,'%*s%*f%*f%f%*f%*f');
              covModST(modnum).sPar=[a1 a2];
              covModST(modnum).tPar=sscanf(tline,'%*s%*f%*f%*f%f%*f');
          end;
        case 3
          switch nSpar
            case 1
              covModST(modnum).sPar=[];
              b1=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              b2=sscanf(tline,'%*s%*f%*f%f%*f%*f');
              covModST(modnum).tPar=[b1 b2];
            case 2
              covModST(modnum).sPar=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              b1=sscanf(tline,'%*s%*f%*f%f%*f%*f');
              b2=sscanf(tline,'%*s%*f%*f%*f%f%*f');
              covModST(modnum).tPar=[b1 b2];
            case 3
              a1=sscanf(tline,'%*s%*f%f%*f%*f%*f');
              a2=sscanf(tline,'%*s%*f%*f%f%*f%*f');
              covModST(modnum).sPar=[a1 a2];
              b1=sscanf(tline,'%*s%*f%*f%*f%f%*f');
              b2=sscanf(tline,'%*s%*f%*f%*f%*f%f');
              covModST(modnum).tPar=[b1 b2];
          end;
      end                
    end;
  end
  fclose(fid);
end
covModSTcell{2}=covModST;
for i=1:modnum
  newList{i}=covModST(i).model;
end;
set(handles.stModelListbox,'String',newList);
set(handles.stModelListbox,'Value',1);
displayPar(handles,covModSTcell{2},size(newList,1));
if get(handles.graphTypeMenu,'Value')==1
  set(handles.graphTypeMenu,'Value',2);
end
plotcovST(handles);

cd(initialDir);


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

global covModSTcell
delete(handles.figure1);                            % Close current window...
clear covModSTcell
ip305p1TcovarAnal('Title','Covariance Analysis');   % ...and procede to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModelST covParamST nestedSTcounter covModSTcell
global displayString

used=find(covModSTcell{1}==1);
covSTmodels=covModSTcell{2};

for i=1:length(used)
  covModelST{i}=covSTmodels(used(i)).model;
  covParamST{i}=[covSTmodels(used(i)).sill,covSTmodels(used(i)).sPar,covSTmodels(used(i)).tPar];
end;

if sum(covModSTcell{1})>0     % User can only proceed when done with covariance modelling
  displayString = [];
  delete(handles.figure1);                               % Close current window...
  ip306estimationsWiz('Title','BME Estimations Wizard'); % ...and procede to following screen.
else
  errordlg({'No covariance models have been defined.';...
           'BMElib needs covariance model information';...
           'in order to advance to the estimation stage.'},...
           'Can not proceed further');
end

function sillEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sPar1Edit as text
%        str2double(get(hObject,'String')) returns contents of sPar1Edit as a double

global covModSTcell covModST
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
currSelectIdx=currUsedIdx(covSelected);
newsill=str2num(get(handles.sillEdit,'String'));
covModSTcell{2}(currSelectIdx).sill=newsill;
covModST=covModSTcell{2};
plotcovST(handles);


% --- Executes during object creation, after setting all properties.
function sillEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sPar1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to sPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sPar1Edit as text
%        str2double(get(hObject,'String')) returns contents of sPar1Edit as a double
global covModSTcell covModST;
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
currSelectIdx=currUsedIdx(covSelected);
newPar=str2num(get(handles.sPar1Edit,'String'));
covModSTcell{2}(currSelectIdx).sPar(1)=newPar;
covModST=covModSTcell{2};
plotcovST(handles);

% --- Executes during object creation, after setting all properties.
function sPar1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sPar2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to sPar2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sPar2Edit as text
%        str2double(get(hObject,'String')) returns contents of sPar2Edit as a double
global covModSTcell covModST;
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
currSelectIdx=currUsedIdx(covSelected);
newPar=str2num(get(handles.sPar2Edit,'String'));
covModSTcell{2}(currSelectIdx).sPar(2)=newPar;
covModST=covModSTcell{2}
plotcovST(handles);

% --- Executes during object creation, after setting all properties.
function sPar2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sPar2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tPar1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to tPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tPar1Edit as text
%        str2double(get(hObject,'String')) returns contents of tPar1Edit as a double
global covModSTcell covModST;
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
currSelectIdx=currUsedIdx(covSelected);
newPar=str2num(get(handles.tPar1Edit,'String'));
covModSTcell{2}(currSelectIdx).tPar(1)=newPar;
covModSTc=covModSTcell{2};
plotcovST(handles);

% --- Executes during object creation, after setting all properties.
function tPar1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tPar1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tPar2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to tPar2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tPar2Edit as text
%        str2double(get(hObject,'String')) returns contents of tPar2Edit as a double
global covModSTcell covModST;
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
currSelectIdx=currUsedIdx(covSelected);
newPar=str2num(get(handles.tPar2Edit,'String'));
covModSTcell{2}(currSelectIdx).tPar(2)=newPar;
covModST=covModSTcell{2};
plotcovST(handles);

% --- Executes during object creation, after setting all properties.
function tPar2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tPar2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stModelListbox.
function stModelListbox_Callback(hObject, eventdata, handles)
% hObject    handle to stModelListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns stModelListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stModelListbox

global covModSTcell;
covSelected=get(handles.stModelListbox,'Value');
currList=get(handles.stModelListbox,'String');
if ~iscell(currList) & strcmp(currList,'No S/T Models')
  displayString='No covariance model was added';
  set(handles.feedbackEdit,'String',displayString);
else
  currUsedIdx=find(covModSTcell{1}==1);
  displayPar(handles,covModSTcell{2},currUsedIdx(covSelected));
end;


% --- Executes during object creation, after setting all properties.
function stModelListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stModelListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in addSModelMenu.
function addSModelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to addSModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns addSModelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from addSModelMenu

% --- Executes during object creation, after setting all properties.
function addSModelMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addSModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in addTModelMenu.
function addTModelMenu_Callback(hObject, eventdata, handles)
% hObject    handle to addTModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns addTModelMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        addTModelMenu


% --- Executes during object creation, after setting all properties.
function addTModelMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addTModelMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addModelButton.
function addModelButton_Callback(hObject, eventdata, handles)
% hObject    handle to addModelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thisVersion
global zhDataToProcess softApproxDataToProcess
global covModST covExpST nestedSTcounter
global displayString
global covModelST covParamST
global viewAzim viewElev
global dataTimeSpan
global tRangeMin tRangeMax tRangeWithinBounds
global covModSTcell;

choice = get(handles.anisotropyMenu,'Value');
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
sillMax = var(cPtValuesDataToProcess);
sRangeMax = covExpST(choice).sMaxCorrRange; 
sRangeInit = sRangeMax / 5;                       % A range initialization value.
% Set the t-range values to be between 0 and the current max correlation range.
tRangeMax = covExpST(choice).tMaxCorrRange; 
tRangeInit = tRangeMax / 5;                       % A range initialization value.

if get(handles.addSModelMenu,'Value') ~= 1 & get(handles.addTModelMenu,'Value') ~= 1
  nestedSTcounter=nestedSTcounter+1;
  for i=1:2
    if i==1
      modval=get(handles.addSModelMenu,'Value');
    else
      modval=get(handles.addTModelMenu,'Value');
    end;
    switch modval
      case 2
        stModel{i}='exponentialC';  
      case 3
        stModel{i}='gaussianC';
      case 4
        stModel{i}='holecosC';
      case 5
        stModel{i}='holesinC';
      case 6
        stModel{i}='mexicanhatC';
      case 7
        stModel{i}='nuggetC';
      case 8
        stModel{i}='sphericalC';
    end;
    if modval==6
      if i==1
        stPar{i}=[sRangeInit 3];
      else
        stPar{i}=[tRangeInit 3];
      end;   
    elseif modval==7
      if i==1
        stPar{i}=[];
      else
        stPar{i}=[];
      end;       
    else
      if i==1
        stPar{i}=sRangeInit;
      else
        stPar{i}=tRangeInit;
      end;
    end      
  end;
  covModST(nestedSTcounter).model=strcat(stModel{1},'/',stModel{2});
  covModST(nestedSTcounter).sModelName=stModel{1};
  covModST(nestedSTcounter).tModelName=stModel{2};
  covModST(nestedSTcounter).sPar=stPar{1};
  covModST(nestedSTcounter).tPar=stPar{2};
  covModST(nestedSTcounter).modUse=1;       % set the model will be in use
  covModST(nestedSTcounter).parSet=0;       % set the model parameter has not been confirmed
  %% Add the new model into cov list
  currlistTemp=get(handles.stModelListbox,'String');
  if iscell(currlistTemp)
    currlist=currlistTemp; clear currlistTemp;
  else
    currlist{1}=currlistTemp; clear currlistTemp;
  end;
  if size(currlist,1)==1 & strcmp(currlist{1},'No S/T Models')
    covModST(nestedSTcounter).sill=sillLeft(sillMax,covModSTcell);
    covModSTcell{1}(size(covModSTcell{1},2)+1)=1;
    covModSTcell{2}=covModST;
    currlist{1}=covModST(nestedSTcounter).model;
    set(handles.stModelListbox,'String',currlist,'Value',size(currlist,1));    
    displayPar(handles,covModST,nestedSTcounter);
    if get(handles.graphTypeMenu,'Value')==1
      set(handles.graphTypeMenu,'Value',2);
    end
    plotcovST(handles);
  else size(currlist,1)>1;    
    covModST(nestedSTcounter).sill=sillLeft(sillMax,covModSTcell);
    covModSTcell{1}(size(covModSTcell{1},2)+1)=1;
    covModSTcell{2}=covModST;
    currlist{size(currlist,1)+1}=covModST(nestedSTcounter).model;
    set(handles.stModelListbox,'String',currlist,'Value',size(currlist,2));    
    displayPar(handles,covModST,nestedSTcounter);
    plotcovST(handles);
  end;
elseif get(handles.addSModelMenu,'Value')==1 & get(handles.addTModelMenu,'Value')~=1
  displayString='No Spatial model is selected';
  set(handles.feedbackEdit,'String',displayString);
elseif get(handles.addSModelMenu,'Value')~=1 & get(handles.addTModelMenu,'Value')==1
  displayString='No Temporal Model is selected';
  set(handles.feedbackEdit,'String',displayString);
else
  displayString='Please select Spatial and Temporal covariance models';
  set(handles.feedbackEdit,'String',displayString);
end;

function sillDef=sillLeft(sillMax,covModSTcell)
used=(covModSTcell{1}==1);
usedIdx=find(covModSTcell{1}==1);
sillnow=0;
if sum(used)<1
  sillDef=sillMax;
else
  covMod=covModSTcell{2};
  for i=1:sum(used)
    sillnow=sillnow+covMod(usedIdx(i)).sill;
  end;
end
sillDef=sillMax-sillnow;
if sillDef<0
  sillDef=0;
end;

function displayPar(handles,covModST,num)
if num==0
  set(handles.sillEdit,'String','N/A','FontSize',8,'Enable','off');
  set(handles.sPar1Edit,'String','N/A','FontSize',8,'Enable','off');
  set(handles.tPar1Edit,'String','N/A','FontSize',8,'Enable','off');
  set(handles.sPar2Edit,'String','N/A','FontSize',8,'Enable','off');
  set(handles.tPar2Edit,'String','N/A','FontSize',8,'Enable','off');
else
  set(handles.sillEdit,'String',num2str(covModST(num).sill),'FontSize',8,'Enable','on');
  if ~strcmp(covModST(num).sModelName,'nuggetC')
    set(handles.sPar1Edit,'String',num2str(covModST(num).sPar(1)),'FontSize',8,'Enable','on');
  else
    set(handles.sPar1Edit,'String','N/A','FontSize',8,'Enable','off');
  end;
  if ~strcmp(covModST(num).tModelName,'nuggetC')
    set(handles.tPar1Edit,'String',num2str(covModST(num).tPar(1)),'FontSize',8,'Enable','on');
  else
    set(handles.tPar1Edit,'String','N/A','FontSize',8,'Enable','off');
  end
  if strcmp(covModST(num).sModelName,'mexicanhatC')
    set(handles.sPar2Edit,'String',num2str(covModST(num).sPar(2)),'FontSize',8,'Enable','on');
  else
    set(handles.sPar2Edit,'String','N/A','FontSize',8,'Enable','off');
  end
  if strcmp(covModST(num).tModelName,'mexicanhatC')
    set(handles.tPar2Edit,'String',num2str(covModST(num).tPar(2)),'FontSize',8,'Enable','on');
  else
    set(handles.tPar2Edit,'String','N/A','FontSize',8,'Enable','off');
  end
end

function plotcovST(handles)

global covExpST
global covModSTcell
global covModelST covParamST
global viewAzim viewElev thisVersion

used=find(covModSTcell{1}==1);
covSTmodels=covModSTcell{2};
if length(used)==0
    displayString = 'No models defined yet. Can not set sill';
    set(handles.feedbackEdit,'String',displayString);
    set(handles.graphTypeMenu,'Value',1);
end;

  if get(handles.extFigureBox,'Value')   % Separate figure or not?
    axes(handles.stCovAxes2)
    image(imread('guiResources/ithinkPic.jpg'));
    axis image
    axis off
    figure;
  else
    axes(handles.stCovAxes2)
  end
  clear covModelST covParamST;
  for i=1:length(used)
    covModelST{i}=covSTmodels(used(i)).model;
    covParamST{i}=[covSTmodels(used(i)).sill,covSTmodels(used(i)).sPar,covSTmodels(used(i)).tPar];
  end;
  ani_choice = get(handles.anisotropyMenu,'Value');        
  dataPts = [covExpST(ani_choice).sCovDistance(:),...
          covExpST(ani_choice).tCovDistance(:),...
          covExpST(ani_choice).experimCov(:)];

% Domain Setting              
  maxSdistance = max(max(covExpST(ani_choice).sCovDistance));
  maxTdistance = max(max(covExpST(ani_choice).tCovDistance));
  modelPoints = 25;              % Obtain model covariance on a grid.
  sDistances = 0:round(maxSdistance)/modelPoints:maxSdistance;
  tDistances = 0:round(maxTdistance)/modelPoints:maxTdistance;
  [sMesh,tMesh] = meshgrid(sDistances,tDistances);
  stLoci = [sMesh(:) tMesh(:)];
  if length(used)>0
    modCovAtLoci = coord2K([0 0],stLoci,covModelST,covParamST);
    modCovGridded = reshape(modCovAtLoci,[size(sMesh)]);
  end;
        
  switch get(handles.graphTypeMenu,'Value')
    case 1
      hold off
      hfCov = surf(covExpST(ani_choice).sCovDistance,...
      covExpST(ani_choice).tCovDistance,covExpST(ani_choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      displayString = 'Experimental Covariances (in selected direction)';
      set(handles.feedbackEdit,'String',displayString);
    case 2
      hold off
      hfCov = surf(covExpST(ani_choice).sCovDistance,...
      covExpST(ani_choice).tCovDistance,covExpST(ani_choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');  
      mCov = surf(sMesh,tMesh,modCovGridded);
      displayString = 'Experimental & Modelled Covariances (in selected direction)';
      set(handles.feedbackEdit,'String',displayString);
    case 3      
      hold off
      hCov = plot(covExpST(ani_choice).sCovDistance(:,1),...
            covExpST(ani_choice).experimCov(:,1),'ro');   hold on;
      mCov = plot(sMesh(1,:),modCovGridded(1,:));    
      xlabel('S-lag (in s-units)'); 
      ylabel('Covariance');
      displayString = 'Experimental (in selected direction) and model at lag t=0';
      set(handles.feedbackEdit,'String',displayString);
    case 4
      hold off
      hCov = plot(covExpST(ani_choice).tCovDistance(1,:),...
            covExpST(ani_choice).experimCov(1,:),'ro');  hold on;
      mCov = plot(tMesh(:,1),modCovGridded(:,1));    
      xlabel('T-lag (in t-units)');
      ylabel('Covariance');
      displayString = 'Experimental (in selected direction) and model at lag s=0';
      set(handles.feedbackEdit,'String',displayString);
  end
  if get(handles.graphTypeMenu,'Value')==1 | get(handles.graphTypeMenu,'Value')==2
  %  set(hfCov,'FaceAlpha',0.7);    % Add transparency to compare with other plot
    if get(handles.graphTypeMenu,'Value')==2
      set(mCov,'FaceAlpha',0.7);     % Add transparency to compare with other plot
    end;
    hold off;
    view(viewAzim,viewElev)
    cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
    %axis image;
    axis([0 maxSdistance 0 maxTdistance min(min(covExpST(ani_choice).experimCov))...
        1.05*max(max(covExpST(ani_choice).experimCov))]);
    xlabel('S-lag (in s-units)');
    ylabel('T-lag (in t-units)');
    zlabel('Covariance');
  end
  if get(handles.graphTypeMenu,'Value')~=1
    if thisVersion<7
      legend([hCov mCov],[covExpST(ani_choice).anisotropyString ' Experim.'],...
            'Covariance Model');
    else 
      legend([hCov mCov],[covExpST(ani_choice).anisotropyString ' Experim.'],...
            'Covariance Model','Location','North');
    end    
  end;


% --- Executes on button press in removeModelButton.
function removeModelButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeModelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global covModSTcell;
covSelected=get(handles.stModelListbox,'Value');
currList=get(handles.stModelListbox,'String');
currUsedIdx=find(covModSTcell{1}==1);
currUsedNum=sum((covModSTcell{1}==1));
if currUsedNum<=1
  if currUsedNum==1
    covModSTcell{1}(currUsedIdx(covSelected))=0;
  end;
  set(handles.stModelListbox,'String','No S/T Models');
else
  rmvIdx=currUsedIdx(covSelected);
  covModSTcell{1}(rmvIdx)=0;
  j=1;
  for i=1:currUsedNum
    if i~=covSelected
      newList{j}=currList{i};
      j=j+1;
    end;
  end;
  set(handles.stModelListbox,'Value',(max(covSelected-1,1)));
  set(handles.stModelListbox,'String',newList);
end;
% Reset figure
covSelected=get(handles.stModelListbox,'Value');
currUsedIdx=find(covModSTcell{1}==1);
if isempty(currUsedIdx)
  displayPar(handles,covModSTcell{2},0);
  set(handles.graphTypeMenu,'Value',1);
  plotcovST(handles);
else
  displayPar(handles,covModSTcell{2},currUsedIdx(covSelected));
  plotcovST(handles);
end;
  





