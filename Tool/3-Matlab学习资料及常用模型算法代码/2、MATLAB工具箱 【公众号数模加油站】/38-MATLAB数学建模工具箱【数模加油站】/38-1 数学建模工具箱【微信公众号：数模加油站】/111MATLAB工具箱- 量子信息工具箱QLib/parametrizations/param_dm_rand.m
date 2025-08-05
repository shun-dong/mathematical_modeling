function dm = param_dm_rand(desc)
%
% Generate a random dm
%
% Usage: dm = param_dm_rand(desc)
%

dm = param_dm(1000*randrow(param_dm_size(desc)));
