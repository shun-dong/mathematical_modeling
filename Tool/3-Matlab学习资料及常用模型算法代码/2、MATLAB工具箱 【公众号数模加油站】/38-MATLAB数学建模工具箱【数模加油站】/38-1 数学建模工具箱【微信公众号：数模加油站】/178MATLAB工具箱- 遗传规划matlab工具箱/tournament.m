function [indid,indindex,popexpected,popnormfitness]=tournament(pop,params,state,nsample,toavoid)
%TOURNAMENT    Sampling of GPLAB individuals by the tournament method.
%   TOURNAMENT(POP,PARAMS,STATE,NSAMPLE,TOAVOID) returns NSAMPLE random
%   ids of the individuals chosen from POP using the tournament method.
%   The ids in TOAVOID are not chosen.
%
%   [IDS,INDICES]=TOURNAMENT(POP,PARAMS,STATE,NSAMPLE,TOAVOID) also
%   returns the indices in POP of the chosen individuals.
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
%
%   Note:
%      The two last output arguments are not referred because they are
%      not used in this function. They are present only for compatibility
%      with the other functions for sampling individuals.
%
%   See also ROULETTE, SUS, SAMPLING
%
%   Copyright (C) 2003 Sara Silva (sara@itqb.unl.pt)
%   This file is part of the GPLAB Toolbox


popexpected=[];
popnormfitness=[];

% tournament selection:
% first get tournamentsize individuals (randomly) from the population;
% (we can use the roulette procedure for this, since we may want to avoid some indices -
% - rand would turn out difficult to avoid indices)
% then choose the one with best fitness.

popids=[pop.id];
state.popexpected=ones(1,state.popsize);

% roll the roulette to draw nsample*tournamentsize individuals:
[tids,tindices]=roulette(pop,params,state,nsample*params.tournamentsize,toavoid);
%example: tids=[80 50 50 35 40 60 10 10]; tindices=[3 1 2 4 5 7 6 6];

% shuffle:
[tids,myorder]=shuffle(tids); % shuffle randomly
tindices=orderby(tindices,myorder); % shuffle exactly like tids, with the same order

% get the fitnesses of these individuals:
tfits=state.popfitness(tindices);
%example: tfits=[0.9 0.9 0.9 0.5 0.2 0.9 0.3 0.3];

% each row of tgroup* is a set of individuals (a single tournament) to choose the best from:
tgroupinds=reshape(tindices,params.tournamentsize,nsample)';
tgroupfits=reshape(tfits,params.tournamentsize,nsample)';
%(tournamentsize=4; nsample=2)
%example: tgroupinds=[3 1 2 4       tgroupfits=[0.9 0.9 0.9 0.5
%                     5 7 6 6];                 0.2 0.9 0.3 0.3];

% get better fitness from each row and repmat to fit the shape of tgroupfits:
if params.lowerisbetter
   betterfits=repmat(min(tgroupfits,[],2),1,params.tournamentsize);
else
   betterfits=repmat(max(tgroupfits,[],2),1,params.tournamentsize);
end
%example: betterfits=[0.9 0.9 0.9 0.9
%                     0.9 0.9 0.9 0.9]

% now find the better values in tgroupfits and proceed like in the function "findfirstindex"
% to get the first ocurrence of the better value in each row:
f=tgroupfits==betterfits;
%example: f=[1 1 1 0
%            0 1 0 0]
cs=cumsum(cumsum(f,2),2);
%example: cs=[1 3 6 9
%             0 1 2 3]
indindex=tgroupinds(find(cs==1))';
indid=popids(indindex);
%example: indindex=[3 7]; indid=[80 60]