function p = param_p_1_sqrt (a)
%
% Parametrization of the square root of a probability distribution.
% 
% Usage: param_p_1_sqrt(a)
%     a: Array of length N-1. Range 0..1 and cycle beyond
%     result: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is NOT uniform under permutation (it's not
% even close)
% 
% Ref: Verdal & Plenio, PRA v57/3, p. 57, March 1998, quant-ph/9707035: "Entanglement measures and purification procedures"
%      

zavit = to_col(a)*2*pi;
sinsin = [1; sin(zavit)];
coscos = [cos(zavit); 1];
cumcoscos = flipud(cumprod(flipud(coscos)));

p = abs(sinsin .* cumcoscos);
% p = p ./ sum(p); % Normalization - Not needed, sum(p) == 1 within 1e-15


