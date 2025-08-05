% 
% Comment to install SEKS-GUI:
%
% When you install SEKS-GUI on your machine, edit this file so it correctly reflects
% the name of the directory in which you installed the GUI packages
%
dirBME=pwd;

if ispc
    addpath([dirBME '\SEKS-GUI0.65'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\iolib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\graphlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\modelslib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\statlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\bmeprobalib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\bmeintlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\bmehrlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\simulib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\genlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\mvnlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\tutorlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\exlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\testslib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\extensions\stmapping'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\extensions\projectionlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\BMELIB2.0b\bmecatlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\GBMELIB1.0'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\GBMELIB1.0\models'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiLibs\GBMELIB1.0\mvnlib'],'-end');
    addpath([dirBME '\SEKS-GUI0.65\guiResources'],'-end');
elseif isunix
    addpath([dirBME '/SEKS-GUI0.65'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/iolib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/iolib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/graphlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/modelslib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/statlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/bmeprobalib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/bmeintlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/bmehrlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/simulib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/genlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/mvnlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/tutorlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/exlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/testslib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/extensions/stmapping'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/extensions/projectionlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/BMELIB2.0b/bmecatlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/GBMELIB1.0'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/GBMELIB1.0/models'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiLibs/GBMELIB1.0/mvnlib'],'-end');
    addpath([dirBME '/SEKS-GUI0.65/guiResources'],'-end');
end

disp('Search path set for SEKS-GUI 0.65 on MATLAB');