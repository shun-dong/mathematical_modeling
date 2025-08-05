function [indid,indindex,popexpected,popnormfitness]=lexictour(pop,params,state,nsample,toavoid)
%LEXICTOUR    Sampling of GPLAB individuals by lexicographic parsimony tournament.
%   LEXICTOUR(POP,PARAMS,STATE,NSAMPLE,TOAVOID) returns NSAMPLE random
%   ids of the individuals chosen from POP using the lexicographic parsimony
%   tournament method (Luke & Panait 2002). The ids in TOAVOID are not chosen.
%
%   [IDS,INDICES]=LEXICTOUR(POP,PARAMS,STATE,NSAMPLE,TOAVOID) also
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
%   See also ROULETTE, SUS, TOURNAMENT, SAMPLING
%
%   References:
%   Luke, S. and Panait, L. Lexicographic Parsimony Pressure. GECCO (2002).
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
% (this tournament also selects for parsimony, so after selecting the best fitness
%  values, check tree sizes and select again for smaller trees)
f=tgroupfits==betterfits;
%example: f=[1 1 1 0
%            0 1 0 0]


funique=find(sum(f,2)==1); % (rows where size doesn't matter)
%example: funique=2
ftosize=f;
ftosize(funique,:)=0; % (only the non-unique are kept - the rest is set to zero)
%example: ftosize=[1 1 1 0
%                  0 0 0 0]
indindextosize=unique(tgroupinds(find(ftosize==1)))'; % (indices of the individuals to measure)
%example: indindextosize=[3 1 2]
fsizes=zeros(size(f));
for i=1:length(indindextosize)
   if isempty(pop(indindextosize(i)).nodes)
      pop(indindextosize(i)).nodes=nodes(pop(indindextosize(i)).tree);
   end
   fsizes(find(tgroupinds==indindextosize(i)))=1/pop(indindextosize(i)).nodes;
end
%example: fsizes=[1/89 1/45 1/45    0
%                    0    0    0    0]
fsizes(funique,:)=f(funique,:); % (add the rows that were previously set to zero)
%example: fsizes=[1/89 1/45 1/45    0
%                    0    1    0    0]
bettersizes=repmat(max(fsizes,[],2),1,params.tournamentsize);
%example: bettersizes=[1/45 1/45 1/45 1/45
%                         1    1    1    1]
f=fsizes==bettersizes;
%example: f=[0 1 1 0
%            0 1 0 0]


cs=cumsum(cumsum(f,2),2);
%example: cs=[1 3 6 9
%             0 1 2 3]
indindex=tgroupinds(find(cs==1))';
indid=popids(indindex);
%example: indindex=[3 7]; indid=[80 60]