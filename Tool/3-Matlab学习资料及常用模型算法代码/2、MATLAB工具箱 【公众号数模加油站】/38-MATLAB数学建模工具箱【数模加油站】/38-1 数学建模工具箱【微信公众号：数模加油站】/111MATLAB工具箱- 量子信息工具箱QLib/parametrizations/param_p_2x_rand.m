function cpd = param_p_2x_rand(desc)
%
% Generate a random CPD (using CPD parametrization 2)
%
% Usage: cpd = param_p_2_rand(desc)
%

cpd = param_p_2x(1000*randrow(param_p_2x_size(desc)));
