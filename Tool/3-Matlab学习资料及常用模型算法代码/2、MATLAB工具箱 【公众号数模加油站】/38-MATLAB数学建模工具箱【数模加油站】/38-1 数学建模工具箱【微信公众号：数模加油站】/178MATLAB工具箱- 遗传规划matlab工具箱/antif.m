function ntime=antif(actiontrue,actionfalse)
%ANTIF    Executes one or other action of the GPLAB artificial ant.
%   ANTIF executes ACTIONTRUE if there is food ahead in the artificial
%   ant trail; executes ACTIONFALSE otherwise. Returns the number of
%   the time step used by the ant after executing the action. Other
%   variables are returned as global variables.
%
%   Output arguments:
%      NTIME - the number of the current time step used by the ant (double)
%
%   See also ANTFITNESS, ANTFOODAHEAD, ANTMOVE, ANTRIGHT, ANTLEFT, ANTPROGN2, ANTPROGN3
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

if antfoodahead
   actiontrue;
else
   actionfalse;
end
