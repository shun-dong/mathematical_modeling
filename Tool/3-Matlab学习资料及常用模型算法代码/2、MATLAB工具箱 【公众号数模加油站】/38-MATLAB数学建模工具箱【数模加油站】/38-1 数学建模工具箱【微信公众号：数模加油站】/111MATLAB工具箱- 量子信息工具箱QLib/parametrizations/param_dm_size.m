function n = param_dm_size(desc, param_p_size_func)
% 
% Get number of parameters for param_dm_size.
%
% Usage: n = param_dm_size(desc<, param_p_size_func>)
%     desc - The descriptor
%     param_p_func_size - The size function for param_p_func. 
%           Defaults to param_p_1_size
%     
%     ret - A density matrix
%
% See param_dm_size for further details
%

if nargin < 2
    param_p_size_func = @param_p_1_size;
end

n = param_SU_over_U_size(desc) + param_p_size_func(desc);