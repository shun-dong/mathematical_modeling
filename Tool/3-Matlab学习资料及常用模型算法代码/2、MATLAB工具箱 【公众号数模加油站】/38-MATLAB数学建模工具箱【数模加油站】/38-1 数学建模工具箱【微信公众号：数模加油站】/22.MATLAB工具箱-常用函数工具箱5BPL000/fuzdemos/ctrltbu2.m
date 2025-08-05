function out = ctrltbu2(x)
% CTRLTBU2 controller for the truck backer-upper when distance is near.

%   Roger Jang, 10-21-93, 1-16-94, 11-7-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 1997/12/01 21:44:06 $

tmp = (x(3) - pi/2) - round((x(3)-pi/2)/(2*pi))*(2*pi); % abs(tmp) < pi
out = x(1)/8 + tmp;
out = max(-pi/4, min(pi/4, out));

