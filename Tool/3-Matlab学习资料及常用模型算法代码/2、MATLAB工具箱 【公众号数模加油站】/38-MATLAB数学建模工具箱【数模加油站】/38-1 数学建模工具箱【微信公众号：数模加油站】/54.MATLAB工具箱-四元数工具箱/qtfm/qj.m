function q = qj
% qj is one of the three quaternion operators.
% qj is usually denoted by j, but this symbol is used in Matlab to represent
% the complex operator (also represented by i).

% Copyright (c) 2005 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

q = quaternion(0, 1, 0);

% Implementation note:  j cannot be overloaded because it is a built-in Matlab
% operator. J cannot be used because Matlab does not distinguish between upper
% and lower case.

end

% $Id: qj.m 1090 2020-06-15 17:17:19Z sangwine $
