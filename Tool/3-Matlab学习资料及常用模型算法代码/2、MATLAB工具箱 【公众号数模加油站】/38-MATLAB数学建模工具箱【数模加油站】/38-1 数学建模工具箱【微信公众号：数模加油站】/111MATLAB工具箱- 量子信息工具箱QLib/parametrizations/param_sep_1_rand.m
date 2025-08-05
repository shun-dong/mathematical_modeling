function dm = param_sep_1_rand(desc)
%
% Generate a random separable state (using sep. parametrization 1)
%
% Usage: dm = param_sep_1_rand(desc)
%

dm = param_sep_1(1000*randrow(param_sep_1_size(desc)), desc);
