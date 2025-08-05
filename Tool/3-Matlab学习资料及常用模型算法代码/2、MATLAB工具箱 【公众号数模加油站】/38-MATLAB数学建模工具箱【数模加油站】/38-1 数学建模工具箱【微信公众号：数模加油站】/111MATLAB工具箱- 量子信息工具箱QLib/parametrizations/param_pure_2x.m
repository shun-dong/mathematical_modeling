function [pure] = param_pure_2x (p)
%
% Parametrization of a pure state (alternative)
% 
% Usage: pure = param_pure_2x(p)
%
%     p:  A vector parameters         
%     pure: the pure state vector (of size prod_desc)
%
% Method of parametrization is a random U(n) rotation of a fixed [1 0 0 0 ...] state.
%

N = sqrt(numel(p));

pure = param_U_1(to_row(p)) * [1 zeros(1, N-1)]';
