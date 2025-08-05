function [indid,indindex,popexpected,popnormfitness]=roulette(pop,params,state,nsample,toavoid)
%ROULETTE    Sampling of GPLAB individuals by the roulette method.
%   ROULETTE(POP,PARAMS,STATE,NSAMPLE,TOAVOID) returns NSAMPLE random
%   ids of the individuals chosen from POP using the roulette method,
%   with duplicate individuals allowed. The ids in TOAVOID are not chosen.
%
%   [IDS,INDICES]=ROULETTE(POP,PARAMS,STATE,NSAMPLE,TOAVOID) also
%   returns the indices in POP of the chosen individuals.
%
%   [IDS,INDICES,EXPECTED,NORMFIT]=ROULETTE(POP,PARAMS,STATE,NSAMPLE,TOAVOID)
%   also returns the expected number of offspring and the normalized
%   fitness vectors, which may have been needed by the roulette procedure.
%
%   Input arguments:
%      POPULATION - the current population of the algorithm (array)
%      PARAMS - the running parameters of the algorithm (struct)
%      STATE - the current state of the algorithm (struct)
%      NSAMPLE - the number of individuals to draw (integer)
%      TOAVOID - the ids of the individuals to avoid drawing (1xN matrix)
%   Output arguments:
%      IDS - the ids of the individuals chosen (1xN matrix)
%      INDICES - the indices of the individuals chosen (1xN matrix)
%      EXPECTED - the expected number of children of all individuals (1xN matrix)
%      NORMFIT - the normalized fitness of all individuals (1xN matrix)
%
%   See also SUS, TOURNAMENT, SAMPLING
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox


% get the things needed, if they're not available yet:
popids=[pop.id];
if isempty(state.popexpected)
   [popexpected,popnormfitness]=calcpopexpected(pop,params,state);
else
   popexpected=state.popexpected;
end

% roll the roulette with nsample random pointers:

indicesavoid=[];
%  the expected value of the toavoid elements is set to zero:
if ~isempty(toavoid)
   [lixo,lixo,matrixnotavoid,lixo]=countfind(popids,setdiff(popids,toavoid));
   expected=popexpected.*matrixnotavoid;
   indicesavoid=find(matrixnotavoid==0);
else
   expected=popexpected;
end

% cumulative sum of the expected values:
cexpected=[0,cumsum(expected)];
% random pointers:
pos=(rand(1,nsample)*cexpected(end));
% for each pos, find the indices where cexpected(1:end-1)<pos<=cexpected(2:end)
cexpected=repmat(cexpected,length(pos),1);
pos=repmat(pos',1,size(cexpected,2)-1);
[ans,indindex]=find(cexpected(:,1:end-1)<pos & pos<=cexpected(:,2:end));
indindex=indindex';
indid=popids(indindex);
