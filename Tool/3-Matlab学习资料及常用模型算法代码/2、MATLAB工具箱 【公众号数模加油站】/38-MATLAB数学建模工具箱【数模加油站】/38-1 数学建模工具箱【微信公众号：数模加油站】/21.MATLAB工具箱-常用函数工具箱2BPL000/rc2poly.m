function a = rc2poly( k )
%RC2POLY Compute polynomial coefficients from reflection coefficients.
%   A = RC2POLY(K) finds the filter coefficients A, with A(1) == 1,
%   from the real reflection coefficients K of the lattice structure
%   of a discrete filter.
%   A is a row vector of length one more than K.
%
%   See also POLY2RC.

%       Author(s): T. Krauss, 9-20-93
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 1997/11/26 20:13:22 $

a = k(1);
for i = 2:length(k)
    a = [ a+conj(a(i-1:-1:1))*k(i)  k(i) ];
end 
a = [1 a];
