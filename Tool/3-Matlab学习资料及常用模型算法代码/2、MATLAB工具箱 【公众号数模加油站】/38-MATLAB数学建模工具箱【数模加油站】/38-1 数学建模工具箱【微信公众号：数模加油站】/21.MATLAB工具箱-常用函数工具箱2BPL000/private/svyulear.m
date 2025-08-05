function [errstr,P,f] = svyulear(x,Fs,valueArray)
%SVYULEAR spectview Wrapper for the Yule-Walker AR method.
%  [errstr,P,f] = svyulear(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft
%          3                Correlation matrix checkbox

%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.2 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft = valueArray{2};

if valueArray{3} == 0 
    evalStr = '[P,f] = pyulear(x,order,nfft,Fs);';
else
    evalStr = '[P,f] = pyulear(x,order,nfft,Fs,''corr'');';
end

err = 0;
eval(evalStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate pyulear; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

