function [x] = idwtndn(y,arg2,arg3)
%IDWT Single-level inverse discrete N-D wavelet transform in all N dimension.
%Here y is a cell array.
%arg2,arg3 is the same meaning as dwt and dwt2 in MATHWORKS wavelet toolbox.
%Two style is 
%       [X] = DWT(Y,'wname') 
%       [X] = DWT(Y,Lo_D,Hi_D) 

if errargn(mfilename,nargin,[2:3],nargout,[0:1]), error('*'), end
if nargin == 2
   [LoF_R,HiF_R] = wfilters(arg2,'r');
else
   LoF_R = arg2;   HiF_R = arg3;
end

for i=log(length(y))/log(2):-1:1
   y2={};
   for j=1:2:length(y)
      t=idwtnd1(y{j},y{j+1},i,LoF_R,HiF_R);
      y2={y2{1:length(y2)},t};
   end;
   y=y2;
end;
x=y{1};

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
