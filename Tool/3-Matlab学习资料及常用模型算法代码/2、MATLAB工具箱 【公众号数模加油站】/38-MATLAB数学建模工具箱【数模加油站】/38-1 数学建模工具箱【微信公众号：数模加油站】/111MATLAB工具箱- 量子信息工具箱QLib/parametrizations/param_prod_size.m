function n = param_prod_size (desc)
%
% Compute number of parameters in a density-matrix product state
%
% Usage: n = param_prod_size (desc)
%     desc   DM descriptor
%     n      The number of DoF
%

n = sum(desc.^2)-length(desc); % N^2-1 per particle

