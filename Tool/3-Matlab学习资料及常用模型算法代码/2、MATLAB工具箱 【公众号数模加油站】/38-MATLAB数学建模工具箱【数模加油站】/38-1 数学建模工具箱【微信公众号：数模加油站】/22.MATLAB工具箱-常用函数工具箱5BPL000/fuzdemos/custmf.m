function y = custmf(x,params)
%CUSTMF Customized membership function for CUSTTIP.FIS.
%   This function is really just TRAPMF in disguise.
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.3 $

y=trapmf(x,params);
