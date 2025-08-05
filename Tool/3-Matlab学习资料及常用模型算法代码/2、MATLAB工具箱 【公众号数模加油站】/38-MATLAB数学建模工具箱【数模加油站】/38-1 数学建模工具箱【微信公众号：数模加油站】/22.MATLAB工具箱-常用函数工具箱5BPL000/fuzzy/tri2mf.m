function y = tri2mf(x,params)
%TRI2MF	Triangular membership function with two parameters 
%	The parameters are [center delta] where delta is the
%	distance from the center to either foot.

%	Copyright (c) 1994-98 by The MathWorks, Inc.
%       $Revision: 1.2 $
y=trimf(x,[params(1)-params(2) params(1) params(1)+params(2)]);
