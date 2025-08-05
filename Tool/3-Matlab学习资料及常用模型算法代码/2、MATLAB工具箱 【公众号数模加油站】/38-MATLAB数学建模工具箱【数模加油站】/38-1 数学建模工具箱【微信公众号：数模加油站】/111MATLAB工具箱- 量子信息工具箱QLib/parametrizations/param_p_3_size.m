function n = param_p_3_size (desc)
% 
% Get number of parameters for param_p_3
%
% Usage: n = param_p_3_size(p)
%     desc  The descriptor 
%     n     The number of parameters 
%
% See param_p_3 for further details
%

n = prod(desc)-1;
