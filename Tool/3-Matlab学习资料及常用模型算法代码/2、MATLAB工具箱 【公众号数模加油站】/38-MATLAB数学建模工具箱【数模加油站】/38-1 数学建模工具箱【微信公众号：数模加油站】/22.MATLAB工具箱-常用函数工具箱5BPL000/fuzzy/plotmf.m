function [xOut,yOut]=plotmf(fis,varType,varIndex,numPts)
%PLOTMF Display all membership functions for one variable.
%   PLOTMF(fismat,varType,varIndex) plots all the membership functions 
%   associated with a specified variable in the fuzzy inference system
%   given by the matrix fismat.
%
%   [xOut,yOut]=PLOTMF(fismat,varType,varIndex) returns the x and y data
%   points associated with the membership functions without plotting them.
%
%   PLOTMF(fismat,varType,varIndex,numPts) generates the same plot with
%   exactly numPts points plotted along the curve.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           plotmf(a,'input',1)
%
%   See also EVALMF, PLOTFIS.

%   Ned Gulley, 10-30-94, Kelly Liu  7-11-96
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 1997/12/01 21:45:14 $

%====================================
if nargin<4, numPts=181; end

fisType=fis.type;

if ~strcmp(varType,'input') & (~strcmp(varType,'output') | strcmp(fisType,'sugeno'))
    error('No plots for Sugeno Output MFs')
end

if strcmp(varType, 'input')
 numMFs=size(fis.input(varIndex).mf, 2);
 var=fis.input(varIndex);
else
 numMFs=size(fis.output(varIndex).mf, 2);
 var=fis.output(varIndex);
end

y=zeros(numPts,numMFs);

xPts=linspace(var.range(1),var.range(2),numPts)';
x=xPts(:,ones(numMFs,1));
for mfIndex=1:numMFs,    
    mfType=var.mf(mfIndex).type;
    mfParams=var.mf(mfIndex).params;
    y(:,mfIndex)=evalmf(xPts,mfParams,mfType);
end

if nargout<1,
    plot(x,y)

     xlabel(var.name);
    ylabel('Degree of membership')
    axis([var.range(1) var.range(2) -0.1 1.1])
    for mfIndex=1:numMFs,
        centerIndex=find(y(:,mfIndex)==max(y(:,mfIndex)));
        centerIndex=floor(mean(centerIndex));
        text(x(centerIndex,mfIndex),1.05,var.mf(mfIndex).name, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10)
    end
else
    xOut=x;
    yOut=y;
end
