function cpd = param_p_1_rand(desc)
%
% Generate a random CPD (using CPD parametrization 1)
%
% Usage: cpd = param_p_1_rand(desc)
%

cpd = param_p_1(1000*randrow(param_p_1_size(desc)));
