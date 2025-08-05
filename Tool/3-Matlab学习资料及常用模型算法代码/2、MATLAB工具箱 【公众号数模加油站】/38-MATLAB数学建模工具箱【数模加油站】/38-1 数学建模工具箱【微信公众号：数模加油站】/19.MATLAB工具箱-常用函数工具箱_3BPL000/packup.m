function [x]=packup(y)
%[X]=PACKUP(Y)
%Y is the result of dwtndn or wavedecnd
%There maybe some situation can't pack them up right(because of even and odd) 
%So some edge lines be cutted to make it fit for packing.

n=length(size(y{1}));
c=2^n;
if rem(length(y),c-1)~=1, error('the size of y is wrong!'), end;
k=fix(length(y)/(c-1));
x=y{1};
for i=1:k
   for p=1:n %cut edge lines to make it fit for packing
      if rem(size(y{2+(i-1)*(c-1)},p),2)==1
			h=size(x);         
         x(h(1),:)=[];
         h(1)=h(1)-1;
         x=reshape(x,h);
      end
      x=shiftdim(x,1);
   end
   t={x,y{2+(i-1)*(c-1):1+i*(c-1)}}; %pack one level
   for l=n:-1:1
   	t2={};
	   for j=1:2:length(t)
   	   s=cat(l,t{j},t{j+1});
      	t2={t2{1:length(t2)},s};
	   end;
   	t=t2;
   end;
   x=t{1};
end;

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
