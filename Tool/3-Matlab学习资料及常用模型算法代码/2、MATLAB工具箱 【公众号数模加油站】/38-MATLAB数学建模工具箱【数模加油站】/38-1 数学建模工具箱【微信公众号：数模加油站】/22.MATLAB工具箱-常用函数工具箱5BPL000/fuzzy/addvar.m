function out=addvar(fis,varType,varName,varRange)
%   Purpose
%   Add a variable to an FIS.
%
%   Synopsis
%   a = addvar(a,varType,varName,varBounds)
%
%   Description
%   addvar has four arguments in this order:
%   the FIS name
%   the type of the variable (input or output)
%   the name of the variable
%   the vector describing the limiting range for the variable
%   Indices are applied to variables in the order in which they are added, so
%   the first input variable added to a system will always be known as input
%   variable number one for that system. Input and output variables are
%   numbered independently.
%
%   Example
%   a=newfis('tipper');
%   a=addvar(a,'input','service',[0 10]);
%   getfis(a,'input',1)
%   MATLAB replies
%   	Name = service
%   	NumMFs = 0
%   	MFLabels =
%   	Range = [0 10]
%
%   See also 
%   addmf, addrule, rmmf, rmvar

%   Kelly Liu, 7-10-96
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 1997/12/01 21:44:38 $

out=fis;
if strcmp(lower(varType),'input'),
    index=length(fis.input)+1;
    out.input(index).name=varName;
    out.input(index).range=varRange;
    out.input(index).numMFs=0;
    out.input(index).mf=[];
    % If this is a sugeno output, need to insert a new column into 
    % the current out params list...
    fisType=fis.type;
    if strcmp(fisType,'sugeno'),
      % if totalOutputMFs,
            % Don't bother if there aren't any output MFs in the first place
          for i=1:length(fis.output)
            for j=1:length(fis.output(i).mf)
              % this is not correct
              out.output(i).mf(j).param(length(fis.input)+1)=0;
            end
          end
      % end
    end 
    % Need to insert a new column into the current rule list
    numRules=length(fis.rule);
    if numRules,
        % Don't bother if there aren't any rules
      
        for i=1:numRules
         out.rule(i).antecedent(index)=0;
        end
    end

elseif strcmp(lower(varType),'output'),
    index=length(fis.output)+1;
    out.output(index).name=varName;
    out.output(index).range=varRange;
    out.output(index).numMFs=0;
    out.output(index).mf=[];
    numRules=length(fis.rule);
    if numRules,
        % Don't bother if there aren't any rules     
        for i=1:numRules
         out.rule(i).consequent(index)=0;
        end
    end   
end

