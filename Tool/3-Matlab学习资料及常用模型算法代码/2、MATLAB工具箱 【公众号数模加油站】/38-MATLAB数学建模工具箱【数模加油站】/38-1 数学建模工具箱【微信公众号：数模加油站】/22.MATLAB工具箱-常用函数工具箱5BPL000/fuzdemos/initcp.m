% INITCP Initialize variables in the demo slcp.m
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.4 $

global AnimCpFigH AnimCpAxisH
[winName] = get_param(0, 'CurrentSystem');
fprintf('Initializing ''fismatrix'' in %s...\n', winName);
fismatrix = readfis('slcp.fis');
fprintf('Done with initialization.\n');
