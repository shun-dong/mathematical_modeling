function y=custdfuz(x,mf)
%CUSTDFUZ Customized defuzzification function for CUSTTIP.FIS
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.3 $

y=defuzz(x,mf,'centroid')/2;
