function cps_sqrt = param_p_2x_sqrt_rand(desc)
%
% Generate a random sqrt(cps_sqrt) (using cps_sqrt parametrization 2x)
%
% Usage: cps_sqrt = param_p_2x_sqrt_rand(desc)
%

cps_sqrt = param_p_2x_sqrt(1000*randrow(param_p_2x_sqrt_size(desc)));
