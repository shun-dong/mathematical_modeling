function n = param_sep_1_size(desc, param_p_size_func, param_pure_size_func)
%
% Get the dimension of the separable state parametrization param_sep_1
% 
% Usage: n = param_sep_1_size (desc, <param_p_size_func, param_pure_size_func>)
%     desc        DM descriptor
%     p_for_*     The size functions for the mixing (CPD) and pure-state parametrizations.
%                 Defaults: @param_p_1_size, @param_pure_1_size
%
% See param_sep_1 for more details
%

if nargin == 1
    param_p_size_func = @param_p_1_size;
    param_pure_size_func   = @param_pure_1_size;
end


D = prod(desc);

n1 = 0;
for k = 1:length(desc)
    n1 = n1 + param_pure_size_func(desc(k));
end

n = param_p_size_func(D^2) + D^2 * n1;

