function pure = param_prod_pure_rand(desc)
%
% Generate a random product pure state
%
% Usage: pure = param_prod_pure_rand(desc)
%

pure = param_prod_pure(1000*randrow(param_prod_pure_size(desc)),desc);
