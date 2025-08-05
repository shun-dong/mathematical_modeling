function ntime=antmove
%ANTMOVE    Moves the GPLAB artificial ant forward one step.
%   ANTMOVE returns the number of the time step used by the ant after
%   moving. Other variables are returned as global variables.
%
%   Output arguments:
%      NTIME - the number of the current time step used by the ant (double)
%
%   See also ANTFITNESS, ANTFOODAHEAD, ANTIF, ANTRIGHT, ANTLEFT, ANTPROGN2, ANTPROGN3
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

% new coordinates:
newy=y;
if strcmp(direction,'u') % facing up
   newx=x;
   newy=mod(y-1,size(trail,1));
elseif strcmp(direction,'d') % facing down
   newx=x;
   newy=mod(y+1,size(trail,1));
end
if newy==0
   newy=size(trail,1);
end
newx=x;
if strcmp(direction,'r') % facing right
   newy=y;
   newx=mod(x+1,size(trail,1));
elseif strcmp(direction,'l') % facing left
   newy=y;
   newx=mod(x-1,size(trail,1));
end
if newx==0
   newx=size(trail,1);
end

% if there's food, eat it:
if (trail(newx,newy)==1) & (ntime<=maxtime)
   trail(newx,newy)=0;
   npellets=npellets+1;
end

x=newx;
y=newy;
ntime=ntime+1;