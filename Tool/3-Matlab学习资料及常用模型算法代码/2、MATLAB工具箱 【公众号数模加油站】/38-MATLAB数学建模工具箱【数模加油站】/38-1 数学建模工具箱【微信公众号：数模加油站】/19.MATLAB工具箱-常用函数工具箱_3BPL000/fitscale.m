function [d]=fitscale(x,n)
%Rescale the value to fit the colormap

if nargin==1, n=255; end;
d=x(:);
mi=min(d);
ma=max(d);
s=n/(ma-mi);
d=(d-mi)*s;
d=reshape(d,size(x));

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
