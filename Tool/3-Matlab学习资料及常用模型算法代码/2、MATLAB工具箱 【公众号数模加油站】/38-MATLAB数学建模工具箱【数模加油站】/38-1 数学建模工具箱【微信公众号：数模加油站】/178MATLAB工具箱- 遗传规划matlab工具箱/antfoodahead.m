function food=antfoodahead
%ANTFOODAHEAD    Tests if there is food ahead of the GPLAB artificial ant.
%   ANTFOODAHEAD returns true if there is food ahead of the artificial ant;
%   returns false otherwise.
%
%   Output arguments:
%      FOOD - whether there is food ahead (boolean)
%
%   See also ANTFITNESS, ANTMOVE, ANTIF, ANTRIGHT, ANTLEFT, ANTPROGN2, ANTPROGN3
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

% save variables that may be changed by "antmove":
keepx=x;
keepy=y;
keepnpellets=npellets;
keeptrail=trail;
keepntime=ntime;

antmove;
food=(trail(x,y)==1);

% load variables that may have been changed by "antmove":
x=keepx;
y=keepy;
npellets=keepnpellets;
trail=keeptrail;
ntime=keepntime;