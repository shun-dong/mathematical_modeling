%INITTBU  Initialize variables in the demo sltbu.m
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.3 $

global TbuInitCond truck_l
global AnimTbuFigH AnimTbuAxisH

TbuInitCond = [10, 25, -pi/2-0.5];
backup_speed = 5;
truck_l = 4;

winTitle = 'Truck Backer-Upper Animation';
[exist_flag, fig] = figflag(winTitle);
if exist_flag,
    animtbu([], [], init_cond, [], 'clear');
end
fismat = readfis('sltbu');
disp('Done reading FIS matrix and initial condition.');
