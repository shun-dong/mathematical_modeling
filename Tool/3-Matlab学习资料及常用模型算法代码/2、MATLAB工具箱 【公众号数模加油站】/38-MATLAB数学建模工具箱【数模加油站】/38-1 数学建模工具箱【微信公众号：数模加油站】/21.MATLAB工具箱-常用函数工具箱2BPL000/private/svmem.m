function [errstr,P,f] = svmem(x,Fs,valueArray)
%SVMEM spectview Wrapper for Maximum-Entropy method.
%  [errstr,P,f] = svmem(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft
%          3                Correlation matrix checkbox

%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.3 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft = valueArray{2};

switch valueArray{3}
case 0
    wflag = 'adapt';
case 2
    wflag = 'unity';
case 3
    wflag = 'eigen';
end

if valueArray{3} == 0 
    evalStr = '[P,f] = pmem(x,order,nfft,Fs);';
else
    evalStr = '[P,f] = pmem(x,order,nfft,Fs,''corr'');';
end

err = 0;
eval(evalStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate pmem; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

