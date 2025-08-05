function [pure] = param_pure_1 (a, param_p_sqrt_func, prod_desc)
%
% Parametrization of a pure state
% 
% Usage: pure = param_pure_1(p[, param_p_func, prod_desc])
%
%     p:  A vector parameters (considered cyclical beyond 0..1).
%     param_p_sqrt_func: Which "param_p_*_sqrt" to use (default is param_p_1_sqrt, 
%         with p containing 2N-2 params)
%     prod_desc: If param_p_func is specified, prod_desc is required and specifies the number of 
%         elements in the pure state. It is equal to prod(desc) for the
%         state.
%         
%     pure: the pure state vector (of size prod_desc)
%

if nargin < 2
    param_p_sqrt_func = @param_p_1_sqrt;
    prod_desc = length(a)/2+1;
end

% in a: Phases are in positions 1..(prod_desc-1), param_p_1 args in prod_desc..end

pure   = to_col(param_p_sqrt_func(a(prod_desc:end)));
phases = to_col(exp(i * 2*pi * a(1:prod_desc-1)));
pure(2:end) = pure(2:end) .* phases;




