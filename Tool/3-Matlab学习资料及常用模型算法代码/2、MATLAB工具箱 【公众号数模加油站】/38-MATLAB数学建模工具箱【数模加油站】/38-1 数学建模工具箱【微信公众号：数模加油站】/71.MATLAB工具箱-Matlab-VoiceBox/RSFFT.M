function x=rsfft(y,n)
%RSFFT    FFT of of a real symmetric data sequence X=(Y,N)
% i.e. y(i)=y(N+2-i)
% only FIX(1+N/2) data samples need be provided in y which will be truncated
% or zero-padded as necessary.
% if y is a matrix, each column will be transformed separately.
% the default value of N is 2*size(x,1)+2
% IMPORTANT: If N is odd, it MUST be specified explicitly.
%
% See also IRSFFT


%      Copyright (C) Mike Brookes 1998
%
%      Last modified Fri Apr  3 14:57:19 1998
%
%   VOICEBOX home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   ftp://prep.ai.mit.edu/pub/gnu/COPYING-2.0 or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fl=size(y,1)==1;
if fl y=y(:); end
[m,k]=size(y);
if nargin<2 n=2*m-2;
else
  mm=1+fix(n/2);
  if mm>m y=[y; zeros(mm-m,k)];
  elseif mm<m y(mm+1:m,:)=[];
  end
  m=mm;
end
if rem(n,2)		% odd case
   x=real(fft([y;y(m:-1:2,:)]));
   x(m+1:n,:)=[];
else			% even case
  w=ones(1,k);
  t=-0.5i* exp((2i*pi/n)*(0:m-1)).';
  z=(t(:,w)+0.5).*(y(m:-1:1,:)-y)+y;
  z(m,:)=[];
  zz=ifft(z)*n;
  x=zeros(m,k);
  m2=(m+1)/2;
  x(1:2:m,:)=real(zz(1:m2,:));
  x(2:2:m,:)=imag(zz(1:m2-1,:));
end

if fl x=x.'; end
