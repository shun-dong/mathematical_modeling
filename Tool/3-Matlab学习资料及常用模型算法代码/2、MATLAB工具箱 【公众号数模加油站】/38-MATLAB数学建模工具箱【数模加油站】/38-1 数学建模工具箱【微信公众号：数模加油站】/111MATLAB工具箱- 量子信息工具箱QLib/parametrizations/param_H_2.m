function ret = param_H_2(p)
% 
% Alternative parametrization of an Hermitian matrix, by direct element specification
%
% Usage: ret = param_H_2(p)
%     p - Vector of N^2 elements
%     ret - Hermitian matrix
%
% The parameters are as follows: first N(N+1)/2 are the real upper
% triangular elements (ordered (1,1),(1,2),...(1,N),(2,1),(2,2), ....). 
% The remaining N(N-1)/2 ar the imaginary upper triangulars, in similar ordering.
%
% Notes:
%     * The routine determines the N in from the length of p
%

p = to_row(p);
N = sqrt(length(p));

ret = zeros(N,N);

pos = 1;

% The real part 
for k = 1:N
    pos2 = pos + N-k+1;
    ret(k,k) = p(pos)/2; % Only half on the diagonal
    ret(k,k+1:N)=p((pos+1):(pos2-1));
    pos = pos2;
end

for k = 1:N-1
    pos2 = pos + N-k;
    ret(k,(k+1):N) = ret(k,(k+1):N) + i*p(pos:(pos2-1));
    pos = pos2;
end

ret = ret + ret';
