function cpd = param_p_3_rand(desc)
%
% Generate a random CPD (using CPD parametrization 3)
%
% Usage: cpd = param_p_3_rand(desc)
%

cpd = param_p_3(1000*randrow(param_p_3_size(desc)));
