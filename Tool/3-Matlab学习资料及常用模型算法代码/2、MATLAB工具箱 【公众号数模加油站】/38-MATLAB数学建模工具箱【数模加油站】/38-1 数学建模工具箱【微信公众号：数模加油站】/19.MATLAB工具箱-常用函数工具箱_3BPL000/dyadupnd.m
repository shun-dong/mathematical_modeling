function y = dyadupnd(x,s)
%[Y]=DYADUPND(X,S)
%X is N-D array
%S is the dimension want to up
%Y is N-D array output
%some difference with MATHWORKS wavelet toolbox
h=size(x);
h=[h(s:length(h)),h(1:s-1)];
h(1)=h(1)*2+1;
y=zeros(h);
t=shiftdim(x,s-1);
y([1:size(x,s)]*2,:)=t(:,:);
y=reshape(y,h);
y=shiftdim(y,length(h)-s+1);

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
