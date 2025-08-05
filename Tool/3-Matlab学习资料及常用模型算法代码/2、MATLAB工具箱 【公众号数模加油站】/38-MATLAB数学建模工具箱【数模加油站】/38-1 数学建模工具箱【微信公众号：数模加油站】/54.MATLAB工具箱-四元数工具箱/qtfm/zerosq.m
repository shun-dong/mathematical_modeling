function E = zerosq(varargin)
% ZEROSQ   N-by-N quaternion matrix of zeros. Takes the same parameters as
% the Matlab function ZEROS (q.v.).

% Copyright (c) 2008 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

E = quaternion(zeros(varargin{:}));

end

% $Id: zerosq.m 1090 2020-06-15 17:17:19Z sangwine $
