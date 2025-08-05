function out=sugmax(fis)
%SUGMAX Find maximum output range for Sugeno fuzzy system.
%   [maxOut,minOut]=SUGMAX(FIS) returns two vectors maxOut and
%   minOut that correspond to the highest and lowest possible
%   outputs for the Sugeno fuzzy inference system associated with
%   the matrix FIS, given the prescribed limits on the range of the
%   input variables. There are as many elements in maxOut and maxIn
%   as there are outputs.
%
%   For example:
%
%           a=newfis('sugtip','sugeno');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           a=addvar(a,'input','food',[0 10]);
%           a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
%           a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);
%           a=addvar(a,'output','tip',[0 30]);
%           a=addmf(a,'output',1,'cheap','constant',5);
%           a=addmf(a,'output',1,'generous','constant',25);
%           ruleList=[1 1 1 1 2; 2 2 2 1 2 ];
%           a=addrule(a,ruleList);
%           sugmax(a)

%   Ned Gulley, 6-15-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 1997/12/01 21:45:56 $

fisType=fis.type;
if ~strcmp(fisType,'sugeno'),
    error('SUGMAX works only with Sugeno fuzzy inference systems.');
end

inRange=getfis(fis,'inRange');
outMFParams=getfis(fis,'outMFParams');
numInputs=length(fis.input);
numOutputs=length(fis.output);

numOutputMFs=[];
for i=1:length(fis.output)
 numOutputMFs(i)=length(fis.output(i).mf);
end

out=zeros(numOutputs,2);
for outputVarIndex=1:numOutputs,
    params=outMFParams((1:numOutputMFs(outputVarIndex))+ ...
        sum(numOutputMFs(1:(outputVarIndex-1))),:);
    rMax=(params(:,1:numInputs)>=0)+1;
    rMin=3-rMax;
    inputValsMax=ones(size(params));
    inputValsMin=ones(size(params));
    % Here we're setting up the inputs to generate the most extreme outputs possible
    for inputVarIndex=1:numInputs,
        bounds=inRange(inputVarIndex,:)';
        inputValsMax(:,inputVarIndex)=bounds(rMax(:,inputVarIndex));
        inputValsMin(:,inputVarIndex)=bounds(rMin(:,inputVarIndex));
    end
    zMax=sum(inputValsMax'.*params')';
    zMin=sum(inputValsMin'.*params')';
    out(outputVarIndex,:)=[min(zMin) max(zMax)];
end

