function ntime=antprogn3(action1,action2,action3)
%ANTPROGN3    Executes three actions of the GPLAB artificial ant.
%   ANTPROGN2 executes ACTION1 followed by ACTION2 followed by ACTION3.
%   Returns the number of the time step used by the ant after all
%   actions. Other variables are returned as global variables.
%
%   Output arguments:
%      NTIME - the number of the current time step used by the ant (double)
%
%   See also ANTFITNESS, ANTFOODAHEAD, ANTMOVE, ANTRIGHT, ANTLEFT, ANTIF, ANTPROGN2
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

action1;
action2;
action3;
