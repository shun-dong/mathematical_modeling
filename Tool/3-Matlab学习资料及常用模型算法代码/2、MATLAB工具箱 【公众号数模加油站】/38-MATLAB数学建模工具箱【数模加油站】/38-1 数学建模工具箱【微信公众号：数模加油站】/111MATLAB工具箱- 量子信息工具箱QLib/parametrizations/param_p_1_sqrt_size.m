function n = param_p_1_sqrt_size (desc)
% 
% Get number of parameters for param_p_1_sqrt
%
% Usage: n = param_p_1_sqrt_size(p)
%     desc  The descriptor 
%     n     The number of parameters 
%
% See param_p_1_sqrt for further details
%

n = prod(desc) - 1;

