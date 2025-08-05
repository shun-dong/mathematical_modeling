function E = zerosvo(varargin)
% ZEROSVO   N-by-N pure octonion matrix of zeros. Takes the same
% parameters as the Matlab function ZEROS (q.v.).

% Copyright (c) 2011 Stephen J. Sangwine and Nicolas Le Bihan.
% See the file : Copyright.m for further details.

Z = zeros(varargin{:});
E = octonion(Z, Z, Z, Z, Z, Z, Z);

end

% $Id: zerosvo.m 1090 2020-06-15 17:17:19Z sangwine $
