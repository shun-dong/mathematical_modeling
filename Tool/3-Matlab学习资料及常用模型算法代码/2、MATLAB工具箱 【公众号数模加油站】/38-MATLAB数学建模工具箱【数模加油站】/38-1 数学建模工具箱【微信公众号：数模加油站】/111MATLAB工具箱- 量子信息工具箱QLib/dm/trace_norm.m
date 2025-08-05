function tn = trace_norm(A)
%
% Compute the trace norm of a matrix
%
% Usage tn = trace_norm(A)
%
% Trace norm is defined as: trace(sqrt(A'*A)), which is the sum of A's abs(eigenvalue)
%
% Note: 
% 1. The trace norm of a density matrix is always one
% 2. It is used to define the trace distance (see dist_trace)
%

eg_2 = eig(A'*A); % We do it this way since A'*A is Hermitian and therefore eigenvalue-able
tn = real(sum(sqrt(eg_2))); % The "real" is to take care of numeric glitches which may give a tiny imaginary part

