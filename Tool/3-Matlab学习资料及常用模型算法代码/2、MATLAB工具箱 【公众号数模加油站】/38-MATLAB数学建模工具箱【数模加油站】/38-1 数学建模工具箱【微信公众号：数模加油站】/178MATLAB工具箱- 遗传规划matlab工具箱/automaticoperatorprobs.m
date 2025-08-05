function [state,pop]=automaticoperatorprobs(pop,params,state,data,currentsize,newsize,bestfit,worstfit);
%AUTOMATICOPERATORPROBS    Automatic operator probabilities procedure for GPLAB.
%   AUTOMATICOPERATORPROBS(POP,PARAMS,STATE,DATA,OLDSIZE,NEWSIZE,BESTFIT,WORSTFIT)
%   returns the updated state with new values for the operator
%   probabilities related variables, obtained by used the procedure
%   by Davis 89.
%
%   [STATE,POP]=AUTOMATICOPERATORPROBS(...) also returns the population
%   being created where some needed fitness measures have been added.
%
%   Input arguments:
%      POP - the new population being created (array)
%      PARAMS - the running parameters of the algorithm (struct)
%      STATE - the current state of the algorithm (struct)
%      DATA - the current dataset for the algorithm to run (struct)
%      OLDSIZE - the previous number of valid individuals in POP (integer)
%      NEWSIZE - the current number of valid individuals in POP (integer)
%      BESTFIT - the best fitness found in previous population (double)
%      WORSTFIT - the worst fitness found in previous population (double)
%   Output arguments:
%      STATE - the updated state with new operator related variables (struct)
%      POP - the population updated with some fitness measures (array)
%
%   References:
%      Davis, L. Adapting operator probabilities in genetic algorithms.
%      Third International Con-ference on Genetic Algorithms (1989).
%
%   See also SETINITIALPROBS 
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

%(bestfit and worstfit are not defined if state.generation==0)

% move adapt window to accomodate the new individuals:
state=moveadaptwindow(pop,params,state,currentsize,newsize);

if state.generation>0
   % build list with ids of individuals to credit:
   
	c=1;
	listtocredit=[];
   for i=currentsize+1:newsize
      
      % first we need the individuals fitness values:
   	if isempty(pop(i).fitness)
   		[pop(i).fitness,pop(i).result,state]=calcfitness(pop(i).str,params,data,state);
      end
      
      % ============
      % OLD VERSION:
      % the credit is calculated in terms of the difference to the best individual
      % in current pop. if this individual has better fitness than the higher
      % fitness from last generation (bestfit), give it credit:
   	%if pop(i).fitness<bestfit
		%	listtocredit(c).id=pop(i).id;
      %  listtocredit(c).fitness=pop(i).fitness;
         % (do not use normalized fitness because the old and new pops
         %  were not normalized together yet)
      %	c=c+1;
      %end
      % ============
      
      % the credit is calculated in terms of the difference to the best and worst
      % individual in current pop. all individuals get credit, some more, some less:
      listtocredit(c).id=pop(i).id;
      listtocredit(c).fitness=pop(i).fitness;
      c=c+1;
      
	end

	if ~isempty(listtocredit)
		state=addcredit(params,state,listtocredit,bestfit,worstfit);
	end
            
	% update operator probabilities:
      
	% Note: backup way for the following if:
   %if state.lastid>=state.lastadaptation+state.adaptinterval
      
	% individuals gone by (with new ids or not), now and then (before this operator):
   % (if popsize varies one day, the popsize history will have to be kept
   % in the state variable to do this calculation right)
	gonebynow=(state.generation-1)*params.gengap + newsize;
   gonebythen=(state.generation-1)*params.gengap + currentsize;
   
	% adapt if we just jumped an adaptation point:
	if (newsize>currentsize) & (mod(gonebynow,params.adaptinterval)<=mod(gonebythen,params.adaptinterval))
		% the part newsize>currentsize garantees that no adaptation will
      % occur in case the operator wasn't able to produce any individuals
      state=updateoperatorprobs(params,state);
      %state.ophistory(end+1,:)=state.operatorprobs; % (save operator probs in ophistory)
      %(no, lets save it only in each generation)
   	state.lastadaptation=state.lastid;
   end
   
% end if state.generation>0
else
   %state.ophistory(end+1,:)=state.operatorprobs; % (save operator probs in ophistory)
   %(no, lets save it only in each generation)
end
