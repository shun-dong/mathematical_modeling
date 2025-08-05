function x=randvec(n,m,c)
%RANDVEC  Generate gaussian random vectors X=(N,M,C)
% generates a random matrix of size (n,p) where p is the maximum dimension of m or c
% Each row of x is independent with mean m and covariance matrix c
% m or c (but not both) may be scalars and c defaults to the identity matrix



%      Copyright (C) Mike Brookes 1998
%
%      Last modified Fri Apr  3 14:57:18 1998
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

k=length(m);
mm=m(:).';
if nargin<3
   x=randn(n,k)+mm(ones(n,1),:);
else
  [i,j]=size(c);
  l=max([i,j,k]);
  if i==j
     if i==1
        x=randn(n,l).*sqrt(abs(c))+mm(ones(n,1),:);
     else
        [v,d]=eig(c+c.');
        cc=sqrt(abs(diag(0.5*d))).';
        if k==l
           x=(randn(n,l).*cc(ones(n,1),:))*v.'+mm(ones(n,1),:);
        else
           x=(randn(n,l).*cc(ones(n,1),:))*v.'+mm(1);
        end
     end
  else
     cc=sqrt(abs(c(:).'));
     if k==l
        x=randn(n,l).*cc(ones(n,1),:)+mm(ones(n,1),:);
     else
        x=randn(n,l).*cc(ones(n,1),:)+mm(1);
     end
     
  end
  
  
end
