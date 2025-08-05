function n=intrand(inf,sup)
%INTRAND    Generates an integer random number inside an interval.
%   INTRAND(INFLIMIT,SUPLIMIT) returns an integer number no
%   smaller than INFLIMIT and no larger than SUPLIMIT.
%
%   Input arguments:
%      INFLIMIT - the inferior limit to the random number (integer)
%      SUPLIMIT - the superior limit to the random number (integer)
%   Output arguments:
%      N - the integer random number >= INFLIMIT and <= SUPLIMIT (integer)
%
%   Copyright (C) 2003-2004 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

if mod(sup,1)~=0 | mod(inf,1)~=0
   error('INTRAND: Both arguments must be integers!')
end

if sup>inf
   s=sup;
   i=inf;
elseif inf>sup
   s=inf;
   i=sup;
else
   n=inf;
   return
end

n=ceil(rand*(s-i+1))+i-1;
