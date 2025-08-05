% ChirpPath:

global CHIRPLABPATH
global PATHNAMESEPARATOR
global PREFERIMAGEGRAPHICS
global MATLABPATHSEPARATOR
		
PREFERIMAGEGRAPHICS = 1;
Friend = computer;

if strcmp(Friend,'MAC2'),
  PATHNAMESEPARATOR = ':';
  CHIRPLABPATH = [pwd, PATHNAMESEPARATOR];
  MATLABPATHSEPARATOR = ';';
elseif isunix,
  % Mac OS X returns isunix=1
  PATHNAMESEPARATOR = '/';
  CHIRPLABPATH = [pwd, PATHNAMESEPARATOR];
  MATLABPATHSEPARATOR = ':';
elseif strcmp(Friend(1:2),'PC');
  PATHNAMESEPARATOR = '\';	  
  CHIRPLABPATH = [pwd, PATHNAMESEPARATOR];  
  MATLABPATHSEPARATOR = ';';
end

disp('-- STARTING CHIRPLAB --')
disp('Adding ChirpLab to MATLAB path...')

post = PATHNAMESEPARATOR;
p = path;
pref = [MATLABPATHSEPARATOR CHIRPLABPATH];
p = [p pref];

p = [p pref 'ChirpletTrans' post];

p = [p pref 'Networks' post ];

% data folder
p = [p pref 'Data' post];
p = [p pref 'Data' post 'ForDemos' post];

p = [p pref 'Demos' post];
p = [p pref 'Utilities' post];

% Inspiral code
p = [p pref 'Inspiral' post];

% mex code
p = [p pref 'mex' post 'src' post 'Networks' post];

path(p);


% Check if MEX files have been compiled and compile them if needed
CompileMex;

clear p pref post
clear CHIRPLABPATH MATLABVERSION PATHNAMESEPARATOR
clear Friend PREFERIMAGEGRAPHICS MATLABPATHSEPARATOR

% $RCSfile: ChirpPath.m,v $
% $Date: 2006/05/01 20:12:06 $
% $Revision: 1.9 $
%
% Copyright (c) Hannes Helgason, California Institute of Technology, 2006
