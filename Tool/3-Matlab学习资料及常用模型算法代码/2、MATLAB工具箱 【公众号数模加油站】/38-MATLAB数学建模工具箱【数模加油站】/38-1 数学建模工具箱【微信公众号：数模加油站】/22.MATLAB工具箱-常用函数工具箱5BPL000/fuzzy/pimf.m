function y = pimf(x, params)
%PIMF Pi-shaped curve membership function.
%   PIMF(X, PARAMS) returns a matrix which is the Pi-shaped
%   membership function evaluated at X. PARAMS = [A B C D] is a 4-element
%   vector that determines the break points of this membership function.
%   Specifically, this MF is the product of SMF and ZMF:
%
%   PIMF(X, PARAMS) = SMF(X, PARAMS(1:2)).*ZMF(X, PARAMS(3:4))
%
%   Note that this Pi MF could be asymmetric because it has four
%   parameters. This is different from the conventional Pi MF that uses
%   only two parameters.
%   
%   For example:
%
%       x = (0:0.1:10)';
%       y1 = pimf(x, [1 4 9 10]);
%       y2 = pimf(x, [2 5 8 9]);
%       y3 = pimf(x, [3 6 7 8]);
%       y4 = pimf(x, [4 7 6 7]);
%       y5 = pimf(x, [5 8 5 6]);
%       plot(x, [y1 y2 y3 y4 y5]);
%       set(gcf, 'name', 'pimf', 'numbertitle', 'off');
%
%   See also DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PSIGMF, SIGMF,
%   SMF, TRAPMF, TRIMF, ZMF.

%   Roger Jang, 10-5-93.
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1997/12/01 21:45:12 $

if nargin ~= 2
    error('Two arguments are required by PIMF.');
elseif length(params) < 4
    error('PIMF needs at least four parameters.');
end

y = smf(x, params(1:2)).*zmf(x, params(3:4));
