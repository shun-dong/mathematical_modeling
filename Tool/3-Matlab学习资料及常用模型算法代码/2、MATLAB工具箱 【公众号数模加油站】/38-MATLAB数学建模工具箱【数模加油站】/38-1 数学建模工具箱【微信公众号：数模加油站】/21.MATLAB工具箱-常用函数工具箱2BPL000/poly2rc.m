function k = poly2rc( a )
%POLY2RC Compute reflection coefficients from polynomial coefficients.
%   K = POLY2RC(A) finds the reflection coefficients of the lattice
%   structure of discrete filter A.  A(0) must not be 0, and A must
%   be real.  K is a row vector of length one less than A.
%
%   A simple, fast way to check if A has all of its roots inside the unit 
%   circle is to check if all of the K's have magnitude less than 1, e.g.
%       stable = all(abs(poly2rc(a))<1)
%
%   CAUTION: If abs(K(i)) == 1 for any i, finding the reflection
%   coefficients is an ill conditioned problem. POLY2RC will return
%   some NaNs and provide a warning message in this case.
%
%   See also RC2POLY.

%       Author(s): T. Krauss, 9-20-93
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.12 $  $Date: 1997/11/26 20:13:12 $

a = (1/a(1))*a(:).';

a(1) = [];    % get rid of leading coefficient
for i = length(a):-1:1
    k(i) = a(i);
    a(i) = [];
    if isempty(a), break, end
    a = (a - k(i)*conj(a(i-1:-1:1)))/(1 - abs(k(i)).^2);
end 
