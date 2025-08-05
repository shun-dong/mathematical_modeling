function dm = param_sep_2x_rand(desc)
%
% Generate a random separable state (using sep. parametrization 2x)
%
% Usage: dm = param_sep_2x_rand(desc)
%

dm = param_sep_2x(1000*randrow(param_sep_2x_size(desc)),desc);
