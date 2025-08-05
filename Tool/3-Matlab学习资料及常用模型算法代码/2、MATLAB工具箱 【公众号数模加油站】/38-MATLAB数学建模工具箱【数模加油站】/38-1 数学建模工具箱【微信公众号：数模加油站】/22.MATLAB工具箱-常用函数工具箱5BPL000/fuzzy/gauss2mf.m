function y = gauss2mf(x, params)
%   Two-sided Gaussian membership function.
%
%   Synopsis
%   y = gauss2mf(x,params)
%   y = gauss2mf(x,[sig1 c1 sig2 c2])
%
%   Description
%   The Gaussian function depends on two parameters sig and c as given by
%   The function gauss2mf is a combination of two of these. The first function,
%   specified by sig1 and c1, determines the shape of the leftmost curve. the
%   second function determines the shape of the rightmost curve. Whenever c1 <
%   c2, the gauss2mf function reaches a maximum value of 1. Otherwise, the
%   maximum value is less than one. The parameters are listed in the order:
%   [sig1, c1, sig2, c2].
%
%   Examples
%   x = (0:0.1:10)';
%   	y1 = gauss2mf(x, [2 4 1 8]);
%   	y2 = gauss2mf(x, [2 5 1 7]);
%   	y3 = gauss2mf(x, [2 6 1 6]);
%   	y4 = gauss2mf(x, [2 7 1 5]);
%   	y5 = gauss2mf(x, [2 8 1 4]);
%   	plot(x, [y1 y2 y3 y4 y5]);
%   	set(gcf, 'name', 'gauss2mf', 'numbertitle', 'off');
%
%   See Also
%   dsigmf, gauss2mf, gbellmf, evalmf, mf2mf, pimf, psigmf, sigmf, smf, trapmf,
%   trimf, zmf

%   Ned Gulley, 4-7-94, Roger Jang, 8-25-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1997/12/01 21:44:58 $

if nargin ~= 2
    error('Two arguments are required by GAUSS2MF.');
elseif length(params) < 2
    error('GAUSS2MF needs four parameters.');
end

sigma1 = params(1);
c1 = params(2);
sigma2 = params(3);
c2 = params(4);

if (sigma1==0) | (sigma2==0),
    error('The sigma value must be non-zero.');
end

c1Index=(x<=c1);
c2Index=(x>=c2);
y1 = exp(-(x-c1).^2/(2*sigma1^2)).*c1Index + 1-c1Index;
y2 = exp(-(x-c2).^2/(2*sigma2^2)).*c2Index + 1-c2Index;

y = y1.*y2;
