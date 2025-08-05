function CompileMex
% CompileMex -- checks whether mex-files have been compiled and compiles them if needed

MEXCOMPILED = 1;

MEXROOT = strcat('mex',filesep,'src',filesep);

% The list of mex-files
% Every row in the string array should be
%'NAME-OF-FILE' 'LOCATION-RELATIVE-TO-CHIRPLABROOT' 'FILE-EXTENSION'
mexFiles = {...
'ShortestPathCellStub' strcat(MEXROOT,'Networks') 'c';...
'CSPcell_mex' strcat(MEXROOT,'Networks') 'cpp';
};

nFiles = size(mexFiles,1);

% Check if MEX files are installed
for k=1:nFiles,
  % check if mex-file exists on MATLAB's search path
  if exist(mexFiles{k,1})~=3,
    MEXCOMPILED = 0;
    break;
  end
end

% If MEX files are not installed, try to install them
if ~MEXCOMPILED,
  disp('MEX files are not installed')
  disp('Compiling MEX files...')
  
  rootDir = pwd;
  for k=1:nFiles,
    cd(mexFiles{k,2});
    fullFileName = sprintf('%s%s%s.%s',mexFiles{k,2},filesep,mexFiles{k,1},mexFiles{k,3});
    disp(sprintf('Compiling: %s',fullFileName));
    try,
      eval(sprintf('mex %s.%s',mexFiles{k,1},mexFiles{k,3}));
    catch
      disp(sprintf('CompileMex: Error occured while compiling MEX file: %s',fullFileName))
      disp('Try running "mex -help" to see if mex compiler is properly installed.')
      disp('If problem persists, ChirpLab will try to run a slower m-file versions of this function.')
      % go back to ChirpLab root directory
      cd(rootDir);
    end
    % go back to ChirpLab root directory
    cd(rootDir);
  end
end
