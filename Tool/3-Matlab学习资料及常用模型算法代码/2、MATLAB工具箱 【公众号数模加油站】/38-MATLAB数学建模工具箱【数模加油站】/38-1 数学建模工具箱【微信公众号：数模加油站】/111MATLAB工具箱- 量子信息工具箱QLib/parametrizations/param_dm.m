function ret = param_dm(p, param_p_func, param_p_func_num_p)
% 
% Parametrization of an density matrix, represented as U'DU
%
% Usage: ret = param_dm(p, [param_p_func, param_p_func_num_p])
%     p - Vector of prod(desc)^2-1 (or more) elements
%     param_p_func, param_p_func_num_p - A function to parametrize the
%         diagonal, and the number of parameters it requires. Default is
%         param_p_1 and prod_desc-1, respectively.
%     
%     ret - A density matrix
%
% For details of this parametrization, see the param_SU_over_U.
%
% Notes:
%     * The routine determines the prod_desc in from the length of p
%     * The first few parameters are the eigenvalue parametrization. 
%       The remaining prod_desc(prod_desc-1) are for param_SU_over_U. See there for cycles, etc.
%     * If param_p_func is specified, you must specify param_p_func_num_p as well.
%

if nargin == 1
    param_p_func = @param_p_1;
    prod_desc = sqrt(length(p)+1);
    param_p_func_num_p = prod_desc-1;
else
   prod_desc = (1 + sqrt(1 + 4*(length(p) - param_p_func_num_p)))/2; 
end

d = param_p_func(p(1:param_p_func_num_p));
u = param_SU_over_U(p((param_p_func_num_p+1):end));
ret = u' * diag(d) * u;