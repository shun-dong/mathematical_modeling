function [myparams,defaults]=availableparams
%AVAILABLEPARAMS    Describes the GPLAB algorithm parameter variables.
%   AVAILABLEPARAMS returns a structured variable containing the
%   possible values of each parameter variable or simply hints on
%   validating each element.
%   
%   [PARAMVARS,DEFAULTS]=AVAILABLEPARAMS also returns the default
%   initial values for each element.
%
%   Output arguments:
%      PARAMVARS - the structure of the parameters variable (struct)
%      DEFAULTS - the default initial parameters (struct)
%
%   See also AVAILABLESTATE, RESETPARAMS, SETPARAMS, RESETSTATE
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

% available parameter elements:

myparams=struct(...
	'functions',[],...
   'terminals',[],...
   'numvars',[],...
   'autovars',[],...
   'initpoptype',[],...
	'expected',[],...
	'survival',[],...
   'sampling',[],...
   'calcfitness',[],...
   'precision',[],...
   'lowerisbetter',[],...
   'gengap',[],...
	'savetofile',[],...
	'operatorprobstype',[],...
   'initialprobstype',[],...
   'reproduction',[],...
	'operatornames',[],...
	'operatornparents',[],...
	'operatornchildren',[],...
	'initialfixedprobs',[],...
	'initialvarprobs',[],...
	'savedir',[],...
	'datafilex',[],...
   'datafiley',[],...
   'usetestdata',[],...
   'testdatafilex',[],...
   'testdatafiley',[],...
   'files2data',[],...
	'numbackgen',[],...
	'percentback',[],...
	'percentchange',[],...
	'adaptinterval',[],...
	'adaptwindowsize',[],...
	'smalldifference',[],...
   'minprob',[],...
   'tournamentsize',[],...
   'depthnodes',[],...
   'fixedlevel',[],...
   'dynamiclevel',[],...
	'inicmaxlevel',[],...
   'inicdynlevel',[],...
   'realmaxlevel',[],...
   'calccomplexity',[],...
   'calcdiversity',[],...
   'hits',[],...
   'output',[],...
   'graphics',[],...
   'keepevalssize',[],...
   'filters',[]);


% possible values or some hints for validation:

myparams.functions='list <- no need for validation';
myparams.terminals='list <- no need for validation';
myparams.numvars='posint';
myparams.autovars={'0','1'};
myparams.initpoptype={'growinit','fullinit','rampedinit'};
myparams.expected={'absolute','rank85','rank89'};
myparams.survival={'keepbest','replace','halfelitism','totalelitism'};
myparams.sampling={'roulette','sus','tournament','lexictour'};
myparams.calcfitness={'regfitness','antfitness'};
myparams.precision='posint'; % number of decimal places to use
myparams.lowerisbetter='boolean';
myparams.gengap='posint';
myparams.savetofile={'never','firstlast','every10','every100','always'};
myparams.operatorprobstype={'fixed','variable'};
myparams.initialprobstype={'fixed','variable'};
myparams.reproduction='special_01float';
myparams.savedir='string <- no need for validation'; % ([] means GPLAB will ask the user)
myparams.datafilex='string <- no need for validation'; % ([] means GPLAB will ask the user)
myparams.datafiley='string <- no need for validation'; % ([] means GPLAB will ask the user)
myparams.usetestdata='boolean';
myparams.testdatafilex='string <- no need for validation'; % ([] means GPLAB will ask the user)
myparams.testdatafiley='string <- no need for validation'; % ([] means GPLAB will ask the user)
myparams.files2data={'xy2inout','anttrail'};
myparams.operatornames='list <- no need for validation';
myparams.operatornparents='list <- no need for validation';
myparams.operatornchildren='list <- no need for validation';
myparams.initialfixedprobs='list <- no need for validation';
myparams.initialvarprobs='list <- no need for validation';
myparams.numbackgen='posint';
myparams.percentback='special_01float'; % a float between 0 and 1, inclusive
myparams.percentchange='01float';
myparams.adaptinterval='special_posint'; % ([] means GPLAB will set this parameter)
myparams.adaptwindowsize='special_posint'; % ([] means GPLAB will set this parameter)
myparams.smalldifference='01float'; % (the same)
myparams.minprob='01float';
myparams.tournamentsize='posnumeric';
myparams.depthnodes={'1','2'}; % 1=limit depth; 2=limit nodes
myparams.fixedlevel={'0','1'}; % use strict limit: 0=no, 1=yes
myparams.dynamiclevel={'0','1','2'}; % 0=no; 1=normal; 2=heavy
myparams.inicmaxlevel='posint';
myparams.inicdynlevel='posint';
myparams.realmaxlevel='posint';
myparams.calccomplexity={'0','1'};
myparams.calcdiversity='list <- no need for validation';
myparams.output={'silent','normal','verbose'};
myparams.hits='matrix <- no need for validation';
myparams.graphics='list <- no need for validation';
% (available plots: plotfitness,plotdiversity,plotcomplexity,plotoperators)
myparams.keepevalssize='special_posint';
myparams.filters='list <- no need for validation';

% default parameters:

defaults.initpoptype='''rampedinit''';
defaults.expected='''rank85''';
defaults.survival='''replace''';
defaults.sampling='''lexictour''';
defaults.calcfitness='''regfitness''';
defaults.precision='12';
defaults.lowerisbetter='1';
defaults.savetofile='''never''';
defaults.operatorprobstype='''fixed''';
defaults.initialprobstype='''fixed''';
defaults.gengap='[]'; % when empty, this default will be filled in gplab 
defaults.savedir='[]'; % when empty, GPLAB will ask the user
defaults.datafilex='[]'; % when empty, GPLAB will ask the user
defaults.datafiley='[]'; % when empty, GPLAB will ask the user
defaults.usetestdata='0';
defaults.testdatafilex='[]'; % when empty, GPLAB will ask the user
defaults.testdatafiley='[]'; % when empty, GPLAB will ask the user
defaults.files2data='''xy2inout''';
defaults.operatornames='{''crossover'',''mutation''}';
defaults.operatornparents='[2 1]';
defaults.operatornchildren='[2 1]';
defaults.initialfixedprobs='[]'; % when empty, this default will be filled in gplab
defaults.initialvarprobs='[]'; % the same
defaults.reproduction='0.1';
defaults.numbackgen='3';
defaults.percentback='0.25';
defaults.percentchange='0.25';
defaults.adaptinterval='[]'; % when empty, this default will be filled in gplab
defaults.adaptwindowsize='[]'; % the same
defaults.smalldifference='[]'; % the same
defaults.minprob='0.1'; % no operator probability will be lower than minprob/number of operators
defaults.tournamentsize='[]'; % when empty, this default will be filled in gplab
defaults.depthnodes='''1'''; % 1=depth, 2=nodes
defaults.fixedlevel='''1'''; % 1=yes
defaults.dynamiclevel='''1'''; % 1=normal
defaults.inicmaxlevel='[]'; % when empty, filled automatically (consider depth or size)
defaults.inicdynlevel='[]'; % when empty, filled automatically (consider depth or size)
defaults.realmaxlevel='[]'; % when empty, filled automatically (consider depth or size)
defaults.calccomplexity='''0''';
defaults.calcdiversity='{''uniquegen''}';
defaults.hits='[100 0]';
defaults.output='''normal''';
defaults.graphics='{''plotfitness'' ''plotdiversity'' ''plotcomplexity'' ''plotoperators''}';
% (order of plots is top-right, bottom-right, top-left, bottom-left)
defaults.functions='{''plus'' 2; ''minus'' 2; ''times'' 2; ''sin'' 1; ''cos'' 1; ''mylog'' 1}';
defaults.terminals='{}';
defaults.numvars='[]'; % when empty, it will be filled automatically depending on 'autovars'
defaults.autovars='''1''';
defaults.keepevalssize='[]'; % when empty, this default will be filled in gplab
defaults.filters='{}';
% (filters are to be filled automatically depending on 'depthnodes', 'fixedlevel' and 'dynamiclevel')

% each operator name must be available as a matlab function.
% the user chooses whatever functions from the list of available functions:
% any MATLAB functions that verify closure may be used.

%defaults.functions='{
	%'ceil' 1;
   %'floor' 1;
   %'times' 2;
   %'mydivide' 2;
   %'plus' 2;
   %'minus' 2;
   %'uminus' 1;
   %'mysqrt' 1;
   %'mylog2' 1;
   %'mylog10' 1;
   %'mylog' 1;
   %'mypower' 2;
   %'sin' 1;
   %'cos' 1;
   %'min' 2;
   %'max' 2;
   %'abs' 1;
   %'myif' 3;
   %'eq' 2;
   %'ne' 2;
   %'lt' 2;
   %'gt' 2;
   %'le' 2;
   %'ge' 2;
   %'and' 2;
   %'or' 2;
   %'not' 1;
   %'xor' 2
%}';

