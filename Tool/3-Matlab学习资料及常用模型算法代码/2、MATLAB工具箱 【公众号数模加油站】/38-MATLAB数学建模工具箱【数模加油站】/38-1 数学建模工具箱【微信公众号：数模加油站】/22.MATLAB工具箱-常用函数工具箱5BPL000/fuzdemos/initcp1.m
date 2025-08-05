%INITCP1 Initialize variables in the demo slcp1.m
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.4 $

global AnimCpFigH AnimCpAxisH
[winName] = get_param(0,'CurrentSystem');
fprintf('Initializing ''fismat'' in %s...\n', winName);
fismat = readfis('slcp1.fis');
fprintf('Done with initialization.\n');
