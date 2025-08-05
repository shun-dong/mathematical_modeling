function dm = param_dm_3_rand(desc)
%
% Generate a random dm (using dm parametrization 3)
%
% Usage: dm = param_dm_3_rand(desc)
%

dm = param_dm_3(1000*randrow(param_dm_3_size(desc)), desc);
