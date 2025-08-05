function w = chebwin(n_est, r)
%CHEBWIN Chebyshev window.
%    W = CHEBWIN(N,R) returns the N-point Chebyshev window 
%        with R decibels of ripple.

%   Author: James Montanaro
%   Reference: E. Brigham, "The Fast Fourier Transform and its Applications" 
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1997/11/26 20:13:28 $

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

w = chebwinx(n,r);
