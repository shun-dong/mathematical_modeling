function dm = param_dm_2x_rand(desc)
%
% Generate a random dm (using dm parametrization 2x)
%
% Usage: dm = param_dm_2x_rand(desc)
%

dm = param_dm_2x(1000*randrow(param_dm_2x_size(desc)));
