function y=sinc(x)
%SINC Sin(pi*x)/(pi*x) function.
%   SINC(X) returns a matrix whose elements are the sinc of the elements 
%   of X, i.e.
%        y = sin(pi*x)/(pi*x)    if x ~= 0
%          = 1                   if x == 0
%   where x is an element of the input matrix and y is the resultant
%   output element.  

%   Author(s): T. Krauss, 1-14-93
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 1997/11/26 20:13:12 $

y=ones(size(x));
i=find(x);
y(i)=sin(pi*x(i))./(pi*x(i));
