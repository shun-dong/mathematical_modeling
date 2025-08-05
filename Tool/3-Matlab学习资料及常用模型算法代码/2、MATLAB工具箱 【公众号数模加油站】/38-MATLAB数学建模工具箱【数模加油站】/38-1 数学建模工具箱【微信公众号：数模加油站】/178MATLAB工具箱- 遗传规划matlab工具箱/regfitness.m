function [fitness,resultind]=regfitness(ind,params,data,terminals,varsvals)
%REGFITNESS    Measures the fitness of a GPLAB individual.
%   REGFITNESS(INDIVIDUAL,PARAMS,DATA,TERMINALS,VARSVALS) returns
%   the fitness of INDIVIDUAL, measured as the sum of differences
%   between the obtained and expected results, on DATA dataset.
%
%   [FITNESS,RESULT]=REGFITNESS(INDIVIDUAL,PARAMS,DATA,TERMINALS,VARSVALS)
%   also returns the result obtained in each fitness case.
%
%   Input arguments:
%      INDIVIDUAL - the individual whose fitness is to measure (string)
%      PARAMS - the current running parameters (struct)
%      DATA - the dataset on which to measure the fitness (struct)
%      TERMINALS - the variables to set with the input dataset (cell array)
%      VARSVALS - the string of the variables of the fitness cases (string)
%   Output arguments:
%      FITNESS - the fitness of INDIVIDUAL (double)
%      RESULT - the result obtained in each fitness case (array)
%
%   See also CALCFITNESS, ANTFITNESS
%
%   Copyright (C) 2003-2005 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox
%
%   Modified in April 2005:
%   - for eficiency reasons, substituted lines 39-48 by lines 31-37.
%
%   Acknowledgement: Vladimir Crnojevic, University of Novi Sad
%   (crnojevic@uns.ns.ac.yu)

X=data.example;
outstr=ind;
for i=params.numvars:-1:1
    outstr=strrep(outstr,strcat('X',num2str(i)),strcat('X(:,',num2str(i),')'));
end
res=eval(outstr); 

%for t=1:params.numvars
	% for all variables (which are first in input list), ie, X1,X2,X3,...
   %var=terminals{t,1};
   %val=varsvals{t}; % varsvals was previously prepared to be assigned (in genpop)
   %eval([var '=' val ';']);
   % (this eval does assignments like X1=2,X2=4.5,...)
%end
   
% evaluate the individual and measure difference between obtained and expected results:
%res=eval(ind);

% if the individual is just a terminal, res is just a scalar, but we want a vector:
if length(res)<length(data.result)
   res=res*ones(length(data.result),1);
end
sumdif=sum(abs(res-data.result));
resultind=res;

% raw fitness:
fitness=sumdif; %lower fitness means better individual

% now limit fitness precision, to eliminate rounding error problem:
fitness=fixdec(fitness,params.precision);