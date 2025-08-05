function pure = param_pure_1_rand(desc)
%
% Generate a random pure state (using pure-state parametrization 1)
%
% Usage: pure = param_pure_1_rand(desc)
%

pure = param_pure_1(1000*randrow(param_pure_1_size(desc)));
