function E = eyeq(varargin)
% EYEQ   N-by-N quaternion identity matrix. Takes the same parameters as
% the Matlab function EYE (q.v.).

% Copyright (c) 2008 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

E = quaternion(eye(varargin{:}));

end

% $Id: eyeq.m 1090 2020-06-15 17:17:19Z sangwine $
