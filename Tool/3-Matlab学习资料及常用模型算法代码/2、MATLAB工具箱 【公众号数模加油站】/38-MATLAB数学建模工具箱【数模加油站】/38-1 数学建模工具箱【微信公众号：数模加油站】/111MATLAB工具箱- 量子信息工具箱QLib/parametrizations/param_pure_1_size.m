function n = param_pure_1_size (desc, param_p_sqrt_size_func)
% 
% Get number of parameters for param_pure_1
%
% Usage: n = param_pure_1_size(desc, <param_p_sqrt_size_func>)
%     desc  The descriptor 
%     param_p_sqrt_size_func  The size function for generating the amplitudes
%     n     The number of parameters 
%
% See param_pure_1 for further details
%

if nargin < 2
    param_p_sqrt_size_func = @param_p_1_sqrt_size;
end

n = param_p_sqrt_size_func(desc) + prod(desc)-1;




