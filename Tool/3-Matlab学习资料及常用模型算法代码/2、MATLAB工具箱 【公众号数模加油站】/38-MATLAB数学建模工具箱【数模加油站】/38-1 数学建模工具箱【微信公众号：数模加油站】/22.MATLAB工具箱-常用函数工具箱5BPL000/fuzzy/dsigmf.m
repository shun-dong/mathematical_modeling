function y = dsigmf(x, params)
%DSIGMF Membership function composed of the difference between two sigmoidal
%   membership functions.
%   Synopsis
%   y = dsigmf(x,[a1 c1 a2 c2])
%   Description
%   The sigmoidal membership function used here depends on the two parameters a
%   and c and is given by
%   The membership function dsigmf depends on four parameters, a1, c1, a2, and
%   c2, and is the difference between two of these sigmoidal functions:
%   f1(x; a1, c1) - f2(x; a2, c2)
%   The parameters are listed in the order: [a1 c1 a2 c2].
%   Example
%   x=0:0.1:10;
%   y=dsigmf(x,[5 2 5 7]);
%   plot(x,y)
%   xlabel('dsigmf, P=[5 2 5 7]')
%
%   See also GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF, SIGMF,
%   SMF, TRAPM, TRIMF, ZMF.

%       Roger Jang, 10-5-93.
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1997/12/01 21:44:48 $

if nargin ~= 2
    error('Two arguments are required by diff. sigmoidal MF.');
elseif length(params) < 4
    error('The diff. sigmoidal MF needs at least four parameters.');
end

y = abs(sigmf(x, params(1:2)) - sigmf(x, params(3:4)));
