function bool = pinrect(pts,rect)
%PINRECT Determine if points lie in or on rectangle.
%   Inputs:
%     pts - n-by-2 array of [x,y] data
%     rect - 1-by-4 vector of [xlim ylim] for the rectangle
%   Outputs:
%     bool - length n binary vector 
 
%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.5 $

    [i,j] = find(isnan(pts));
    bool = (pts(:,1)<rect(1))|(pts(:,1)>rect(2))|...
           (pts(:,2)<rect(3))|(pts(:,2)>rect(4));
    bool = ~bool;
    bool(i) = 0;

