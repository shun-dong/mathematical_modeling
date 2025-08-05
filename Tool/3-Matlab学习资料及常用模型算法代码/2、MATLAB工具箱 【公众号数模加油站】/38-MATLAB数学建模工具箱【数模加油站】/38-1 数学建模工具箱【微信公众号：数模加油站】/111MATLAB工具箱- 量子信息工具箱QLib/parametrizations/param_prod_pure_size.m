function n = param_prod_pure_size (desc)
%
% Compute number of parameters in a pure-state product state
%
% Usage: n = param_prod_pure_size (desc)
%     desc   pure state descriptor
%     n      The number of DoF
%

n = 2*(sum(desc)-length(desc)); % 2*(N-1) DoF per particle

