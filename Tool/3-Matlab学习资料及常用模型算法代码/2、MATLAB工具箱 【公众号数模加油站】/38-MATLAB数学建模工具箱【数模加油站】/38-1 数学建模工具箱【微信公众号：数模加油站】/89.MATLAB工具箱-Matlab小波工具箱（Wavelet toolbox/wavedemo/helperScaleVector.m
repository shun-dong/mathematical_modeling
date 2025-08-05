function scales = helperScaleVector(nv,N,Fs)
%   scales = helperScaleVector(NumVoices,N,Fs)
%   NumVoices - number of voices per octave
%   N         - number of elements in input vector
%   Fs        - sampling frequency
%   s0        - initial scale
%   This function helperScaleVector is only in support of
%   synchrosqueezingExample.m. 
%   It may change in a future release.
%
%
dt = 1/Fs;
a0 = 2^(1/nv);
numoct = log2(N)-1;
na = numoct*nv;
scales = a0.^(1:na).*dt;

