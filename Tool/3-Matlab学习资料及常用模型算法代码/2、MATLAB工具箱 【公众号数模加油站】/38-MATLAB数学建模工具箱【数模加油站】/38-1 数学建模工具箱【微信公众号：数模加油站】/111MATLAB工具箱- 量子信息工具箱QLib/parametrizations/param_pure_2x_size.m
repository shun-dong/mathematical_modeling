function n = param_pure_2x_size (desc)
% 
% Get number of parameters for param_p_2x
%
% Usage: n = param_p_2x_size(p)
%     desc  The descriptor 
%     n     The number of parameters 
%
% See param_p_2x for further details
%


n = prod(desc)^2;