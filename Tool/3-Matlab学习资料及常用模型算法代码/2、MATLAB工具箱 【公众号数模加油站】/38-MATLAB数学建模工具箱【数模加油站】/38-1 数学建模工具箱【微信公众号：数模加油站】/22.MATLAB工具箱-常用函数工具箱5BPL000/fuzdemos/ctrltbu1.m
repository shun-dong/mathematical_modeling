function out = ctrltbu1(x)
% CTRLTBU1 controller for the truck backer-upper when distance is far.

%   Roger Jang, 10-21-93, 1-16-94, 11-7-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 1997/12/01 21:44:05 $

distance = norm(x(1:2));
alpha = acos(x(1)/distance) - pi/2; % abs(alpha) <= pi/2
tmp = x(3) - pi/2 - alpha;
beta = tmp - round(tmp/2/pi)*2*pi; % abs(beta) <= pi
out = - 3*alpha + 2*beta;
out = max(-pi/4, min(pi/4, out));
