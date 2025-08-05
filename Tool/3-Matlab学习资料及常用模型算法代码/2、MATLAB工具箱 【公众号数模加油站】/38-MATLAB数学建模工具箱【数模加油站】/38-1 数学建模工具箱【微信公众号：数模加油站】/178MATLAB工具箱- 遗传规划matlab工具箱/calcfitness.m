function [fitness,resultind,state]=calcfitness(ind,params,data,state)
%CALCFITNESS    Measures the fitness of a GPLAB individual.
%   CALCFITNESS(INDIVIDUAL,PARAMS,DATA,STATE) returns the
%   fitness of INDIVIDUAL, measured in DATA with the
%   procedure indicated in PARAMS.
%
%   [FITNESS,RESULT]=CALCFITNESS(...) also returns the result
%   obtained in each fitness case.
%
%   [FITNESS,RESULT,STATE]=CALCFITNESS(...) also returns the
%   updated state.
%
%   Input arguments:
%      INDIVIDUAL - the individual whose fitness is to measure (string)
%      PARAMS - the algorithm running parameters (struct)
%      DATA - the dataset on which to measure the fitness (struct)
%      STATE - current state of the algorithm (struct)
%   Output arguments:
%      FITNESS - the fitness of INDIVIDUAL (double)
%      RESULT - the result obtained in each fitness case (array)
%      STATE - the updated state of the algorithm (struct)
%
%   See also REGFITNESS, ANTFITNESS
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

if isempty(state.keepevals) % this means keepevals has not be initialized (on purpose)
   [fitness,resultind]=feval(params.calcfitness,ind,params,data,state.terminals,state.varsvals);
   return;
end
% (this can be accessed by historical graphical output functions,
%  with no state or keepevals initialization)


% first check if this same string has already been evaluated:
f=find(strcmp(state.keepevals.inds,ind));

if isempty(f) % this string not in keepevals yet
   % select appropriate fitness measurement function:
   [fitness,resultind]=feval(params.calcfitness,ind,params,data,state.terminals,state.varsvals);
   % save evaluation in keepevals:
   % (do not exceed keepevalssize individuals, remove less used individuals)
   nevals=length(state.keepevals.inds);
   if nevals<params.keepevalssize
      i=nevals+1;
   else
      i=find(state.keepevals.used==min(state.keepevals.used));
      i=i(1);
   end
   state.keepevals.used(i)=1;
   state.keepevals.inds{i}=ind;
   state.keepevals.fits(i)=fitness;
   state.keepevals.ress{i}=resultind;
   
else % it is in keepevals - use the information stored and increase usage number
   fitness=state.keepevals.fits(f);
  	resultind=state.keepevals.ress{f};
   state.keepevals.used(f)=state.keepevals.used(f)+1;
end

