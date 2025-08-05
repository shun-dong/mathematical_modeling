function [d]=convnd(x,s,y)
%conv in one dimension
%[D]=CONVND(X,S,Y)
%X is N-D array
%S is the dimension you want to conv
%Y is a vector to conv

t=size(x);
if s>length(t), error('s can''t bigger than the dimensions of x.'), end;
x=shiftdim(x,s-1);
z=x(:,:); sz=size(z); d=zeros(sz(1)+length(y)-1,sz(2));
for i=1:size(z,2)
   d(:,i)=conv(z(:,i),y)';
end;
t2=[t(s:length(t)),t(1:s-1)]; t2(1)=size(d,1);
d=reshape(d,t2);
d=shiftdim(d,length(t)-(s-1));

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
