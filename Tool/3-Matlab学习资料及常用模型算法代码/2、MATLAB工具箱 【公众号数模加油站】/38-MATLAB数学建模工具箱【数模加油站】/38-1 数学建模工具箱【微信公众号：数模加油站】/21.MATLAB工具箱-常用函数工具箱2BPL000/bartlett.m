function w = bartlett(n_est)
%BARTLETT Bartlett window.
%   W = BARTLETT(N) returns the N-point Bartlett window.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.10 $  $Date: 1997/11/26 20:13:01 $

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

w = 2*(0:(n-1)/2)/(n-1);
if rem(n,2)
	% It's an odd length sequence
	w = [w w((n-1)/2:-1:1)]';
else
	% It's even
	w = [w w(n/2:-1:1)]';
end


