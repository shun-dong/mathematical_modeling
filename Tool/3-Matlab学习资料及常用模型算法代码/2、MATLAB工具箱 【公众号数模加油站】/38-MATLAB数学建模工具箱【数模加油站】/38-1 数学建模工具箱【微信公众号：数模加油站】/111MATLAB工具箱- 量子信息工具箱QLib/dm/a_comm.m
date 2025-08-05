function C = a_comm(A,B)
%
% Anti-commutation of matrices
%
% Usage: C = a_comm(A,B)
%
% C = AB + BA
%


C = A*B+B*A;