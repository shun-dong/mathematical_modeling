function [x]=idwtnd1(a,d,s,arg4,arg5,arg6)
%IDWT Single-level discrete N-D wavelet inverse transform in one dimension.
%Here x is a N-D array, and s is the dimension index you want to do IDWT.
%a,d is the approximation coefficients vector CA and detail coefficients vector CD.
%arg2,arg3 is the same meaning as dwt and dwt2 in MATHWORKS wavelet toolbox.
%Two style is 
%       X = IDWTND1(A,D,S,'wname') 
%       X = IDWTND1(A,D,S,Lo_D,Hi_D) 

if errargn(mfilename,nargin,[3:5],nargout,[0:1]), error('*'), end

if isstr(arg4)
        [LoF_R,HiF_R] = wfilters(arg4,'r');
        if nargin==5 , 
           l = arg5; 
        else 
           l = 2*size(a,s)-length(LoF_R)+2; 
        end
else
        LoF_R = arg4;   HiF_R = arg5;
        if nargin==6 
           l = arg6; 
        else 
           l = 2*size(a,s)-length(LoF_R)+2; 
        end
end

x = convndcut(dyadupnd(a,s),s,LoF_R,l)+convndcut(dyadupnd(d,s),s,HiF_R,l);

%   
% Part of Multi-dimension Wavelet Toolbox Version 1.0
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail chen_fu@263.net
%   
