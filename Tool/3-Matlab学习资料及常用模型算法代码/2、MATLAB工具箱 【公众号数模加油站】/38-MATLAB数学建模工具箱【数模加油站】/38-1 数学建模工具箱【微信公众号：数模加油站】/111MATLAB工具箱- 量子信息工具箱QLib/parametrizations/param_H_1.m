function ret = param_H_1(p)
% 
% Parametrization of an Hermitian matrix, represented as U'DU
%
% Usage: ret = param_H_1(p)
%     p - Vector of N^2 elements
%     ret - Hermitian matrix
%
% For details of this parametrization, see the param_SU_over_U.
%
% Notes:
%     * The routine determines the N in from the length of p
%     * First N parameters are the eigenvalues. The remaining N(N-1) are
%       for param_SU_over_U. See there for cycles, etc.
%     * This parametrization allows you to specify eigenvalues explicitly.
%

N = sqrt(length(p));

d = diag(p(1:N));
u = param_SU_over_U(p((N+1):end));
ret = u * d * u';
