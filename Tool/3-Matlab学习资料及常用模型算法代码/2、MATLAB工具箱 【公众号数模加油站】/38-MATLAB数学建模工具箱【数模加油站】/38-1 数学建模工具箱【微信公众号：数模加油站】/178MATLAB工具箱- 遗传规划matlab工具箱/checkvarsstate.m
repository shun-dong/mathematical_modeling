function [state,params]=checkvarsstate(start,continuing,data,params,state,n,g);
%CHECKVARSSTATE    Initializes GPLAB algorithm state variables.
%   CHECKVARSSTATE(START,CONTINUE,DATA,PARAMS,STATE,POPSIZE,NGENS)
%   returns the initial state variables of the algorithm, after
%   checking for necessary initializations.
%
%   Input arguments:
%      START - true if no generations have been run yet (boolean)
%      CONTINUE - true if some generations have been run (boolean)
%      DATA - the dataset on which the algorithm runs (struct)
%      PARAMS - the algorithm running parameters (struct)
%      STATE - the algorithm current state (struct)
%      POPSIZE - the number of individuals in the population (integer)
%      NGENS - the number of generations to run the algorithm (integer)
%   Output arguments:
%      STATE - the updated state variables (struct)
%      PARAMS - the updated parameters (struct)
%
%   See also CHECKVARSPARAMS, CHECKVARSDATA, GPLAB
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

% check state variables:

if start
   
   state=setparams([],'defaults','state');
   if ~strcmp(params.output,'silent')
      fprintf('\n- Initializing algorithm state values.\n');
   end
	state.popsize=n;
   state.maxgen=g;
   
   % diversity measures - create fields to store diversity history:
   for i=1:length(params.calcdiversity)
      eval(['state.diversityhistory.' params.calcdiversity{i} '=[];']);
   end
   
   % manage depth/nodes:
   state.depthnodes=params.depthnodes; % it's practical to have it in state
   state.iniclevel=params.inicmaxlevel; % it's practical to have it in state
   if ~strcmp(params.dynamiclevel,'0')
      state.maxlevel=params.inicdynlevel; % dynamic limit
   elseif ~strcmp(params.fixedlevel,'0')
      state.maxlevel=params.realmaxlevel; % strict limit
   else
      state.maxlevel=0; % no limit!
   end
   
   % fill state variables "functions" (functions + terminals) and "terminals" (just terminals):
   if (~isempty(params.numvars)) | (strcmp(params.autovars,'1'))
      % create variables automatically:
      if isempty(params.numvars)
         % how many
         s=size(data.example,2);
      else
         s=min(size(data.example,2),params.numvars);
         % (do not create more than the columns of data.example)
      end
      params.numvars=s; % (fill params.numvars with correct number)
	   for v=1:s
   	   % create variable terminals:
      	varterminals{v,1}=strcat('X',num2str(v)); % X1, X2, ...
      	% IF YOU CHANGE 'X', ALSO CHANGE IN MAKETREE
      	varterminals{v,2}=0; % null arity
   	end
      state.terminals=[varterminals; params.terminals]; % variables MUST come first!
   else
      % do not create variables
      state.terminals=params.terminals;
      params.numvars=0; % (fill params.numvars with null value)
   end
   state.functions=[params.functions; state.terminals];
   % keep arity in numeric format:
	for i=1:size(state.functions,1)
   	state.arity(i)=state.functions{i,2};
	end
   
   % initialize array with cloning freqs, the right size:
   state.clonings=zeros(1,length(params.operatornames));
      
   % initialize array with operator freqs, the right size:
   state.operatorfreqs=zeros(1,length(params.operatornames));
   
   % choose initial operator probabilities, eventually variable:
   if strcmp(params.initialprobstype,'variable')
      state.operatorprobs=normalize(params.initialvarprobs,1);
      %if ~strcmp(params.output,'silent')
         fprintf('\n   (setting initial operator probabilities automatically...)\n');
      %end
      state.operatorprobs=normalize(setinitialprobs(params,state,data),1);
   else
      state.operatorprobs=normalize(params.initialfixedprobs,1);
   end
   
   % initialize "keepevals" struct variable:
   if params.keepevalssize>0
      state.keepevals=struct('inds',[],'fits',[],'ress',[],'used',[]);
   end
   
end

if continuing
	state.maxgen=state.generation+g;	   
end

if strcmp(params.output,'verbose')
   fprintf('\n');
   state
   fprintf('\n');   
end
