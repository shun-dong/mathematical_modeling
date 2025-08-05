function [out,errorStr]=rmmf(fis,varType,varIndex,mfFlag,mfIndex, infoflag)
%RMMF   Remove membership function from FIS.
%   fis2 = RMMF(fis,varType,varIndex,'mf',mfIndex) removes the
%   specified membership function from the fuzzy inference system
%   associated with the FIS matrix fis.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           subplot(2,1,1), plotmf(a,'input',1)
%           a=rmmf(a,'input',1,'mf',2);
%           subplot(2,1,2), plotmf(a,'input',1)
%
%   See also ADDMF, ADDRULE, ADDVAR, PLOTMF, RMVAR.

%   Ned Gulley, 2-2-94   Kelly Liu 7-22-96
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 1997/12/01 21:45:18 $

out=[];
errorStr=[];

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

if nargin<6
  infoflag=1;
end

% Get the rule matrix

if ~isempty(fis.rule)
   ruleList=getfis(fis, 'ruleList');
end

if isempty(mfIndex),
    errorStr='No membership function was selected!';
    if nargout<2,
        error(errorStr)
    else
        out=[]; return
    end
end

if strcmp(varType,'input'),
    if varIndex>numInputs,
        errorStr=['There are only ' num2str(numInputs)  ' input variables.'];
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end

    currNumMFs=numInputMFs(varIndex);
    if currNumMFs==0,
        errorStr='No membership functions left to remove';
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end

    if mfIndex>currNumMFs,
        errorStr=['There are only ' num2str(currNumMFs) ...
            ' membership functions for this variable.'];
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end

    % Make sure the MF is not currently being used in the rules
    if numRules>0,
        usageIndex=find(ruleList(:,varIndex)==mfIndex);
    else
        usageIndex=[];
    end
    if length(usageIndex),
       if infoflag==1
         anws=questdlg({['This membership function is used in rule ' num2str(usageIndex) ' now, do you really want to remove it?']}, '', 'Yes', 'No', 'No');
         if strcmp(anws, 'No')
           out=fis;
           return;
         end
       end
    end

    
    fis.input(varIndex).mf(mfIndex)=[];
  
    % And update the rules
    if numRules>0,
        ruleList(usageIndex,:)=[];
        templist=find(ruleList(:,varIndex)>mfIndex);
        temp1=zeros(size(ruleList,1),1);
        temp1(templist)=1;
        ruleList(:,varIndex)=ruleList(:,varIndex)-temp1;
        fis=setfis(fis,'ruleList',ruleList);
    end
elseif strcmp(varType,'output'),
    if varIndex>numOutputs,
        errorStr=['There are only ' num2str(numInputs)  ' output variables.'];
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end

    currNumMFs=numOutputMFs(varIndex);
    if currNumMFs==0,
        errorStr='No membership functions left to remove';
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end
    aaa=mfIndex
    bbb=currNumMFs
    if mfIndex>currNumMFs,
        errorStr=['There are only ' num2str(currNumMFs) ...
            ' membership functions for this variable.'];
        if nargout<2,
            error(errorStr)
        else
            out=[]; return
        end
    end

    % Make sure the MF is not currently being used in the rules
    if numRules>0,
        usageIndex=find(ruleList(:,numInputs+varIndex)==mfIndex);
    else
        usageIndex=[];
    end
    if length(usageIndex),
       if infoflag==1
         anws=questdlg({['This membership function is used in rule ' num2str(usageIndex) ' now,'],...
                ['do you really want to remove it?']}, '', 'Yes', 'No', 'No');
         if strcmp(anws, 'No')
           out=fis;
           return;
         end
       end
    end

    
    fis.output(varIndex).mf(mfIndex)=[];
  
    % And update the rules
    if numRules>0,
        ruleList(usageIndex,:)=[];
        % change index number for mfs in rule
        templist=find(ruleList(:,varIndex)>mfIndex);
        temp1=zeros(size(ruleList,1),1);
        temp1(templist)=1;
        ruleList(:,numInputs+varIndex)=ruleList(:,varIndex)-temp1;
        fis=setfis(fis,'ruleList',ruleList);
    end

end

out=fis;

