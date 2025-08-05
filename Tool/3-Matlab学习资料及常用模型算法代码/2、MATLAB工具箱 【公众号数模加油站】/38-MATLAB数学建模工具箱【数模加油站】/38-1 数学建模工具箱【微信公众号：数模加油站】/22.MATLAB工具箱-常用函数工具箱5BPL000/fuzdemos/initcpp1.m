%INITCPP1  Initialize variables in the demo slcpp1.m
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.4 $

global AnimCppFigH AnimCppAxisH
[winName] = get_param(0, 'CurrentSystem');
fprintf('Initializing ''fismat'' in %s...\n', winName);
fismat = readfis('slcpp1.fis');
fprintf('Done with initialization.\n');

