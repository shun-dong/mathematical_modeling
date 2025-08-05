function w = hanning(n_est,sflag)
%HANNING Hanning window.
%   W = HANNING(N) returns the N-point symmetric Hanning window 
%       in a column vector. 
%   W = HANNING(N,SFLAG) generates the N-point Hanning window 
%       using SFLAG window sampling. SFLAG may be either 'symmetric' 
%       or 'periodic'. By default, 'symmetric' window sampling is used. 

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.10 $  $Date: 1997/11/26 20:13:47 $

error(nargchk(1,2,nargin));

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

% Set sflag to default if it's not already set:
if nargin == 1,
   sflag = 'symmetric';
end

switch lower(sflag),
case 'periodic'
   w = sym_hanning(n+1);
   w = w(1:end-1);
case 'symmetric'
   w = sym_hanning(n);
otherwise
	error('Sampling must be either ''symmetric'' or ''periodic''');
end

function w = sym_hanning(n)
w = .5*(1 - cos(2*pi*(1:n)'/(n+1)));
