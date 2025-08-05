function w = hamming(n_est,sflag)
%HAMMING Hamming window.
%   W = HAMMING(N) returns the N-point symmetric Hamming window 
%       in a column vector. 
%   W = HAMMING(N,SFLAG) generates the N-point Hamming window 
%       using SFLAG window sampling. SFLAG may be either 'symmetric' 
%       or 'periodic'. By default, 'symmetric' window sampling is used. 

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.11 $  $Date: 1997/11/26 20:13:19 $

error(nargchk(1,2,nargin));

[n,w,trivalwin] = check_order(n_est);
if trivalwin, return, end;

% Set sflag to default if it's not already set:
if nargin == 1,
   sflag = 'symmetric';
end

switch lower(sflag),
case 'periodic'
   w = sym_hamming(n+1);
   w = w(1:end-1);
case 'symmetric'
   w = sym_hamming(n);
otherwise
	error('Sampling must be either ''symmetric'' or ''periodic''');
end

function w = sym_hamming(n)
w = .54 - .46*cos(2*pi*(0:n-1)'/(n-1));
