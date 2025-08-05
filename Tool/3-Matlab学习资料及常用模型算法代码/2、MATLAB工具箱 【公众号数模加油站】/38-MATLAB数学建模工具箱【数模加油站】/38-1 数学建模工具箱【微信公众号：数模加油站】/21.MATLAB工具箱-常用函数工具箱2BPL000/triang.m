function w = triang(n_est)
%TRIANG Triangular window.
%   W = TRIANG(N) returns the N-point triangular window.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.11 $  $Date: 1997/12/02 18:36:01 $

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

if rem(n,2)
	% It's an odd length sequence
	w = 2*(1:(n+1)/2)/(n+1);
	w = [w w((n-1)/2:-1:1)]';
else
	% It's even
	w = (2*(1:(n+1)/2)-1)/n;
	w = [w w(n/2:-1:1)]';
end

