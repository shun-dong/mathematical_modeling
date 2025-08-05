function [y] = wavedecnd(x,n,arg3,arg4)
%WAVEDECND Multi-level N-D wavelet decomposition.
%       [Y] = WAVEDECNDND(X,N,'wname') returns the wavelet
%       decomposition of the matrix X at level N, using the
%       wavelet named in string 'wname' (see WFILTERS).
%       Ouput is cell array with cell embeded
%       N must be a strictly positive integer (see WMAXLEV).
%
%       Instead of giving the wavelet name, you can give the
%       filters.
%       For [Y] = WAVEDECND(X,N,LoF_D,HiF_D),
%       LoF_D is the decomposition low-pass filter and
%       HiF_D is the decomposition high-pass filter.
%
%       The output wavelet N-D decomposition structure Y
%       is organized as:
%        Y = {A(N),H(N),V(N),D(N)...H(N-1),V(N-1),D(N-1)...H(1),V(1),D(1)}.

if errargn(mfilename,nargin,[3:4],nargout,[0:2]), error('*'), end
if errargt(mfilename,n,'int'), error('*'), end
if nargin==3
        [LoF_D,HiF_D] = wfilters(arg3,'d');             
else
        LoF_D = arg3;   HiF_D = arg4;
end

c=2^ndims(x);
y={};
for i=1:n
   t = dwtndn(x,LoF_D,HiF_D);        
   y = {t{2:c},y{1:length(y)}};
	x = t{1};
end
y={x,y{1:length(y)}};

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
