function [y] = dwtndn(x,arg2,arg3)
%DWT Single-level discrete N-D wavelet transform in all N dimension.
%Here x is a N-D array.
%[ca,cd] is the approximation coefficients vector CA and detail coefficients vector CD.
%arg2,arg3 is the same meaning as dwt and dwt2 in MATHWORKS wavelet toolbox.
%Two style is 
%       [CA,CD] = DWT(X,'wname') 
%       [CA,CD] = DWT(X,Lo_D,Hi_D) 
%See also DWTMODE, dwtnd1

% Check arguments.
if errargn(mfilename,nargin,[2:3],nargout,[0:1]), error('*'), end
if nargin == 2
   [LoF_D,HiF_D] = wfilters(arg2,'d');
else
   LoF_D = arg2;   HiF_D = arg3;
end

y={x};
for i=1:ndims(x)
   y2={};
   for j=1:length(y)
      [a,d]=dwtnd1(y{j},i,LoF_D,HiF_D);
      y2={y2{1:length(y2)},a,d};
   end;
   y=y2;
end;

   