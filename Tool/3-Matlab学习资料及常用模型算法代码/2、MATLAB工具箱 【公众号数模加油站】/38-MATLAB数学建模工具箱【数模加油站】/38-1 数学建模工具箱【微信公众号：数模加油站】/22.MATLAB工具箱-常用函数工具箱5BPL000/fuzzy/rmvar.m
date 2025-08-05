function [out,errorStr]=rmvar(fis,varType,varIndex, infoflag)
%RMVAR  Remove variable from FIS.
%   fis2 = RMVAR(fis,varType,varIndex) removes the specified
%   variable from the fuzzy inference system associated with the 
%   FIS matrix fis.
%
%   [fis2,errorStr] = RMVAR(fis,varType,varIndex) returns any necessary
%   error messages in the string errorStr.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addvar(a,'input','food',[0 10]);
%           getfis(a)
%           a=rmvar(a,'input',1);
%           getfis(a)
%
%   See also ADDMF, ADDVAR, RMMF.

%   Ned Gulley, 2-2-94  Kelly Liu, 7-22-96
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.18 $  $Date: 1997/12/01 21:45:18 $

errorStr=[];
out=[];
if nargin<4
  infoflag=1;
end
errorFlag=0;
numInputs=length(fis.input);
numOutputs=length(fis.output);
for i=1:numInputs
 numInputMFs(i)=length(fis.input(i).mf);
end
totalInputMFs=sum(numInputMFs);
numOutputMFs=[];
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end
totalOutputMFs=sum(numOutputMFs);
numRules=length(fis.rule);



switch lower(varType(1)),
 case 'i',
    if numInputs==0,
        errorStr='No input variables left to remove';
        if nargout<2, 
           error(errorStr); 
        else
            out=[];
            return
        end
    end

    % if the variable is currently being used in the rules
    if  infoflag==1 & numRules>0 
      usedlist=[];
      for i=1:numRules,
       if fis.rule(i).antecedent(varIndex)~=0
          usedlist=[usedlist, i];
       end
      end
      if ~isempty(usedlist)
         anws=questdlg({['This varable is used in rule ' mat2str(usedlist) ' now,'],...
                ['do you really want to remove it?']}, '', 'Yes', 'No', 'No');
      end
      if strcmp(anws, 'No')
         out=fis;
         return;
      end
    end
    for i=1:numRules,
        fis.rule(i).antecedent(varIndex)=[];
    end
    
    fis.input(varIndex)=[];
    %check if there is any rule with no antecedent
    for i=numRules:-1:1
       if isempty(find(fis.rule(i).antecedent~=0))
          fis.rule(i)=[];
       end
    end 
case 'o',
    if numOutputs==0,
        errorStr='No output variables left to remove';
        if nargout<2, 
           error(errorStr); 
        else
            out=[];
            return
        end
    end
    % Make sure the variable is not currently being used in the rules
    for i=1:numRules,
       if infoflag==1 & fis.rule(i).consequent(varIndex)~=0
         anws=questdlg({['This varable is used in rule ' num2str(i) ' now,'],...
                ['do you really want to remove it?']}, '', 'Yes', 'No', 'No');
         if strcmp(anws, 'No')
           out=fis;
           return;
         else
           break;
         end
       end
       fis.rule(i).consequent(varIndex)=[];
    end

    fis.output(varIndex)=[];
    %check if there is any rule with no consequent
    for i=numRules:-1:1
       if isempty(find(fis.rule(i).consequent~=0))
          fis.rule(i)=[];
       end
    end

end

out=fis;
