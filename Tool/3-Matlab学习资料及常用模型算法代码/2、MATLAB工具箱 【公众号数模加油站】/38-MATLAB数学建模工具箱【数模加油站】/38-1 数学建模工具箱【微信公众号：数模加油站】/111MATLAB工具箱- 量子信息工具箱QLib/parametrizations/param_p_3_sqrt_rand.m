function cps_sqrt = param_p_3_sqrt_rand(desc)
%
% Generate a random sqrt(cps_sqrt) (using cps_sqrt parametrization 1)
%
% Usage: cps_sqrt = param_p_3_sqrt_rand(desc)
%

cps_sqrt = param_p_3_sqrt(1000*randrow(param_p_3_sqrt_size(desc)));
