function ntime=antleft
%ANTLEFT    Turns the GPLAB artificial ant to the left.
%   ANTLEFT returns the number of the time step used by the ant after
%   turning. Other variables are returned as global variables.
%
%   Output arguments:
%      NTIME - the number of the current time step used by the ant (double)
%
%   See also ANTFITNESS, ANTFOODAHEAD, ANTIF, ANTMOVE, ANTRIGHT, ANTPROGN2, ANTPROGN3
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

global trail;
global x;
global y;
global direction;
global npellets;
global maxtime;
global ntime;

% new direction:
if strcmp(direction,'u') % facing up
   newdirection='l';
elseif strcmp(direction,'d') % facing down
   newdirection='r';
elseif strcmp(direction,'r') % facing right
   newdirection='u';
elseif strcmp(direction,'l') % facing left
   newdirection='d';
end

direction=newdirection;
ntime=ntime+1;