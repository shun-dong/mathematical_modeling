function out=newfis(fisName,fisType,andMethod,orMethod,impMethod,aggMethod,defuzzMethod)
%NEWFIS Create new FIS.
%   FIS=NEWFIS(FISNAME) creates a new Mamdani-style FIS structure
%
%   FIS=NEWFIS(FISNAME, FISTYPE) creates a FIS structure for a Mamdani or 
%   Sugeno-style system with the name FISNAME.
%
%   See Also
%       readfis, writefis

%   Kelly Liu 4-5-96 
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 1997/12/01 21:45:09 $

if (nargin>=1), name=fisName; end
if (nargin<2), fisType='mamdani'; else, fisType = fisType; end
if strcmp(fisType,'mamdani'),
    if (nargin<3), andMethod='min'; end
    if (nargin<4), orMethod='max'; end
    if (nargin<7), defuzzMethod='centroid'; end
end


if (nargin<5), impMethod='min'; end
if (nargin<6), aggMethod='max'; end


if strcmp(fisType,'sugeno'),
    if (nargin<3), andMethod='prod'; end
    if (nargin<4), orMethod='probor'; end
    if (nargin<7), defuzzMethod='wtaver'; end
end
out.name=name;
out.type=fisType;
out.andMethod=andMethod;
out.orMethod=orMethod;
out.defuzzMethod=defuzzMethod;
out.impMethod=impMethod;
out.aggMethod=aggMethod;

out.input=[];
out.output=[];

out.rule=[];

