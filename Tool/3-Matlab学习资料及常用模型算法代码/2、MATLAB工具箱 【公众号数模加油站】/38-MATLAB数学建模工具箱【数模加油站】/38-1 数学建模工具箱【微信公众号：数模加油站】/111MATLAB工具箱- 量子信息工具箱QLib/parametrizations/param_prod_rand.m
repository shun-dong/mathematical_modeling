function dm = param_prod_rand(desc)
%
% Generate a random product state dm
%
% Usage: dm = param_prod_rand(desc)
%

dm = param_prod(1000*randrow(param_prod_size(desc)),desc);
