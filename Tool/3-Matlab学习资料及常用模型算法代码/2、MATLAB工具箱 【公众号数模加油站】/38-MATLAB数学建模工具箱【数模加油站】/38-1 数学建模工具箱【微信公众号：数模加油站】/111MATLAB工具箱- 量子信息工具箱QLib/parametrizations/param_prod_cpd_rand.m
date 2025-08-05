function cpd = param_prod_cpd_rand(desc)
%
% Generate a random product cpd state
%
% Usage: cpd = param_prod_cpd_rand(desc)
%

cpd = param_prod_cpd(1000*randrow(param_prod_cpd_size(desc)),desc);
