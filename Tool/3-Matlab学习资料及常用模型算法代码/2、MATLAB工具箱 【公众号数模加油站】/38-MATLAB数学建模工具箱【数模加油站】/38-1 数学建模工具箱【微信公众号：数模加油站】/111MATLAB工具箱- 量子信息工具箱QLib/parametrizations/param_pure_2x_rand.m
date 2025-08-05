function pure = param_pure_2x_rand(desc)
%
% Generate a random pure state (using pure-state parametrization 2)
%
% Usage: pure = param_pure_2x_rand(desc)
%

pure = param_pure_2x(1000*randrow(param_pure_2x_size(desc)));
