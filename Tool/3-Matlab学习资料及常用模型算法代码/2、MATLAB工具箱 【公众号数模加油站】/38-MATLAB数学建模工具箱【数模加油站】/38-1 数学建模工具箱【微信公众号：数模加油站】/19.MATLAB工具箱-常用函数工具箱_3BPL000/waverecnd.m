function [x] = waverecnd(y,n,arg3,arg4)
%WAVEDEC2 Multi-level N-D wavelet decomposition.
%       [Y] = WAVEDECND(X,N,'wname') returns the wavelet
%       decomposition of the matrix X at level N, using the
%       wavelet named in string 'wname' (see WFILTERS).
%       Ouput is cell array with value array form small size to big size.
%       N must be a strictly positive integer.
%
%       Instead of giving the wavelet name, you can give the
%       filters.
%       For [X] = WAVEDECND(Y,N,Lo_R,Hi_R),
%       Lo_R is the decomposition low-pass filter and
%       Hi_R is the decomposition high-pass filter.
%
%       The output wavelet N-D decomposition structure Y
%       is organized as:
%        Y = {A(N),H(N),V(N),D(N)...H(N-1),V(N-1),D(N-1)...H(1),V(1),D(1)}.

if errargn(mfilename,nargin,[3:4],nargout,[0:2]), error('*'), end
if errargt(mfilename,n,'int'), error('*'), end
if nargin==3
        [LoF_R,HiF_R] = wfilters(arg3,'r');             
else
        LoF_R = arg3;   HiF_R = arg4;
end

u=ndims(y{1});
c=2^u;
x=y{1};
for i=1:n
   for p=1:u
      if rem(size(y{2+(i-1)*(c-1)},p),2)==1
			h=size(x);         
         x(h(1),:)=[];
         h(1)=h(1)-1;
         x=reshape(x,h);
      end
      x=shiftdim(x,1);
   end
   t={x,y{2+(i-1)*(c-1):1+i*(c-1)}};
   x = idwtndn(t,LoF_R,HiF_R);        
end

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
    
