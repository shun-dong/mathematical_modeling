function pop=applysurvival(pop,params,tmppop)
%APPLYSURVIVAL    Choose new generation of individuals for GPLAB algorithm.
%   APPLYSURVIVAL(OLDPOP,PARAMS,NEWPOP) returns a population of individuals
%   chosen between the individuals of the previous current population,
%   OLDPOP, and the individuals newly created, in NEWPOP, applying the
%   survival method specified in PARAMS.
%
%   Input arguments:
%      OLDPOP - the previous current population of the algorithm (array)
%      PARAMS - the running parameters of the algorithm (struct)
%      NEWPOP - the new population of individuals recently created (array)
%   Output arguments:
%      POPULATION - the new current population (array)
%
%   See also GENERATION
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

survtype=params.survival;

popsize=length(pop);
tmppopsize=length(tmppop);

if strcmp(survtype,'replace')
   numbest=0;
elseif strcmp(survtype,'keepbest')
   numbest=1;
elseif strcmp(survtype,'halfelitism')
   numbest=ceil(popsize/2);
elseif strcmp(survtype,'totalelitism')
   numbest=popsize;
else
   error('APPLYSURVIVAL: unknown survival type!')
end 
  

% both pop and tmppop joined in allpop:
% allpopfit contains 2 cols: 1st-fitness; 2nd-if this individual comes from oldpop
allpop=pop;
allpopfitness=[allpop.fitness]';
allpopfit(1:popsize,1)=allpopfitness; 
allpopfit(1:popsize,2)=1; % these come from pop

allpop(popsize+1:popsize+tmppopsize)=tmppop;
allpopfitness=[allpop.fitness]';
allpopfit(popsize+1:popsize+tmppopsize,1)=allpopfitness(popsize+1:popsize+tmppopsize);
allpopfit(popsize+1:popsize+tmppopsize,2)=0; % these do not come from pop

% now we sort allpopfit and keep index I, and then pick individuals from allpop:
if ~params.lowerisbetter
   allpopfit(:,1)=-allpopfit(:,1); % minus sign because the ordering will be ascending
end
[ans,I]=sortrows(allpopfit,1); % sort by 1st col - fitness

% get numbest individuals, sorted by fitness, from allpop
pop(1:numbest)=allpop(I(1:numbest));
worsefit=max(allpopfit(:,1)); % the worse fitness of all
allpopfit(I(1:numbest),1)=(worsefit+1)*ones(numbest,1);
% (the ones already chosen get worse than the worse fitness, so they won't be chosen again)

% now we sort allpopfit again, and then pick individuals from tmppop only:
[ans,I]=sortrows(allpopfit,[2,1]); % sort by 2nd col - tmppop first and then 1st col - fitness
% get the number of individuals needed to reach popsize, sorted by fitness, from tmppop
pop(numbest+1:popsize)=allpop(I(1:popsize-numbest));   

