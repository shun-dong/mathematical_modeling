function C = comm(A,B)
%
% Commutation of matrices
%
% Usage: C = comm(A,B)
%
% C = AB - BA
%

C = A*B-B*A;