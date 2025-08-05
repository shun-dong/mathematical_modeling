function nv=normalize(v,s)
%NORMALIZE    Normalizes vectors.
%   NORMALIZE(VECTOR,SUM) returns the normalized VECTOR so that
%   the sum of its elements is SUM, and all elements are >=0.
%
%   Input arguments:
%      VECTOR - the vector to normalize (1xN matrix)
%      SUM - the total to which the normalized vector should sum (double)
%   Output arguments:
%      NORMVECTOR - the normalized VECTOR (1xN matrix)
%
%   Example:
%      VECTOR = [1,-1,4,2,0]
%      SUM = 1
%      NORMVECTOR = NORMALIZE(VECTOR,SUM)
%      NORMVECTOR = 0.1818         0    0.4545    0.2727    0.0909
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

if min(v)<0
   v=v+abs(min(v));
end

if sum(v)==0
   error('NORMALIZE: Division by zero!')
else
   nv=s*(v./sum(v));
end
