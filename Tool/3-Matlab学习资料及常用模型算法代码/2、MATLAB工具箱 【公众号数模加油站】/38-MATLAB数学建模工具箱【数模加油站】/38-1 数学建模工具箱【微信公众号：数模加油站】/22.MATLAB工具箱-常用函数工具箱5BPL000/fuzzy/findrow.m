function rowNum=findrow(str,strMat)
%FINDROW Find the rows of a matrix that match the input string.
%   ROWNUM = FINDROW(STR,STRMAT) returns the index to the row or rows
%   in the matrix STRMAT that are identical to the vector STR.
%   Blanks (ASCII 32) and zeros are not considered. An empty matrix 
%   is returned if there is no match.
%
%   For example:
%
%   strMat = fstrvcat('one','fish','two','fish',[1 2 3 4 5 6]);
%   rowNum = findrow('fish',strMat)

%   Ned Gulley, 4-26-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 1997/12/01 21:44:53 $

% If either of the inputs is empty, we can return a null answer right away
if isempty(strMat) | isempty(str),
    rowNum=[];
    return
end

% Strip out any columns that consist of nothing but blanks
str(:,find(str==32))=[];
strMat(:,find(all(strMat==32)))=[];
% Replace all zeros with spaces (ASCII 32)
zeroIndex=find(strMat==0);
strMat(zeroIndex)=32*ones(size(zeroIndex));

numChars=size(str,2);
[numRows,numCols]=size(strMat);

if numChars>numCols,
    rowNum=[];
    return;
end

% Now stuff the input string with spaces until it matches the width
% of the input matrix
str2=[str 32*ones(1,numCols-numChars)];
% Then replicate it until it matches the height of the input matrix
str2=str2(ones(1,numRows),:);

match=all((str2 == strMat)');

rowNum=find(match==1);

%if prod(size(rowNum)),
%    rowNum=0;
%end

