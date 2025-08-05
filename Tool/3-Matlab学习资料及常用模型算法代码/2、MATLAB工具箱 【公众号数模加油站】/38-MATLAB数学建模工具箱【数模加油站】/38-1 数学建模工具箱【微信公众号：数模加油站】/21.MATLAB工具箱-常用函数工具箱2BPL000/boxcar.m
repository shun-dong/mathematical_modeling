function w = boxcar(n_est)
%BOXCAR Boxcar window.
%   W = BOXCAR(N) returns the N-point rectangular window.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.11 $  $Date: 1997/12/02 18:36:12 $

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

w = ones(n,1);

