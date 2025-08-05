%
% The SU(N) generators have a subgroup of N-1 generators (numbered n^2-1 for n=2..N), which are
% diagonal (i.e. no off-diagonal members).
%
% This demo verifies that these generators, together with eye(N) are linearly independent.
%
% If this is the case, then these N matrices can together span a matrix diagonal.
%
% This is related to why param_SU_over_U works. See there for further  details on the math 
% and appropriate references.
%

clc; 
SU_gen_cache;

disp ('Are the SU(N) generators n^2-1 and eye(N) linearly independent?');


for N=2:10
    mat = NaNs(N,N);
    mat(1,:) = 1; % The trace of eye(N)
    for k=2:N
        mat(k,:) = diag(QLib.SU.gen{N}{k^2-1});
    end
    if ~is_close(det(mat),0)
        fprintf ('%2d: Ok\n', N);
    else
        fprintf ('%2d: PROBLEM\n', N);
    end
end
