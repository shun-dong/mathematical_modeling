% INITBB Initialize variables in the demo slbb.m
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.4 $

global AnimBbFigH AnimBbAxisH BbDragging
[winName] = get_param(0,'CurrentSystem');
fprintf('Initializing ''fismatrix'' in %s...\n', winName);
fismatrix = readfis('slbb.fis');
fprintf('Done with initialization.\n');
