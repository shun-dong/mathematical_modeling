function [fitness,resultind]=antfitness(ind,params,data,terminals,varsvals)
%ANTFITNESS    Measures the fitness of a GPLAB artificial ant.
%   ANTFITNESS(INDIVIDUAL,PARAMS,DATA,TERMINALS,VARSVALS) returns
%   the fitness of INDIVIDUAL, measured as the number of food
%   pellets eaten in the artificial ant food trail during 400
%   time steps. Returns other variables as global variables.
%
%   [FITNESS,RESULT]=ANTFITNESS(INDIVIDUAL,PARAMS,DATA,TERMINALS,VARSVALS)
%   also returns the results obtained in each fitness case (when there
%   is only one food trail, both output arguments are equal).
%
%   Input arguments:
%      INDIVIDUAL - the individual whose fitness is to measure (string)
%      PARAMS - the current running parameters (struct)
%      DATA - the dataset on which to measure the fitness (struct)
%      TERMINALS - (not needed here - kept for compatibility purposes)
%      VARSVALS - (not needed here - kept for compatibility purposes)
%   Output arguments:
%      FITNESS - the fitness of INDIVIDUAL (double)
%      RESULT - the result obtained in each fitness case (array)
%
%   See also CALCFITNESS, REGFITNESS
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

trail=data.example;
x=1;
y=1;
direction='r';
npellets=0;
maxtime=400;
ntime=0;

% evaluate ant and count food pellets eaten:
% (repeat program until maxtime)
while 1
   ans=eval(ind); % ans is necessary to avoid screen output of evaluation
   if ntime>=maxtime
      break
   end
end

% raw fitness:
fitness=npellets; %higher fitness means better individual

resultind(1)=fitness;