function n = param_prod_cpd_size (desc)
%
% Compute number of parameters in a cpd product state
%
% Usage: n = param_prod_cpd_size (desc)
%     desc   cpd state descriptor
%     n      The number of DoF
%

n = sum(desc) - length(desc); % N-1 DoF per particle

