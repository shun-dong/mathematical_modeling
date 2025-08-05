function dm = validate_dm(a, desc)
%
% validate_pure: Make sure a matix describes a good dm. If yes, return unchanged. If not, issue an error
%
% Usage: dm = validate_dm(a <,desc>)
%     a         The dm to validate
%     desc      The descriptor (optional)
%     dm        The input dm returned untouched
%
% If "a" is not a good dm (definite semi-positive hermitian of trace 1), an error will be issued
% If it is, nothing will happen and the DM is returned as-it.
%
% This function is very useful (as is validate_pure) to make sure nothing has gone awry in a complicated computation.
%

global QLib


if (length(size(a)) > 2) | (size(a,2) ~= size(a,1))
    size(a)
    error ('validate_dm: expected a matrix');
end

if nargin == 2
    if size(a,1) ~= prod(desc)
        desc
        error(sprintf('validate_dm: vector has %d elements, but %d are expected by descriptor'), length(a), prod(desc));
    end
end

if ~is_close(a,a')
    disp ('The DM:');
    disp(a)
    disp ('Asymmetric part:');
    disp(a-a')
    error ('validate_dm: Matrix is not Hermitian');
end

evals = cleanup(eig(a));  % The matrix is Hermitian --> real eigenvalues

if min(evals) < (0-QLib.close_enough)
    disp ('The DM:');
    disp(a)
    disp ('The eigenvalues:');
    disp(evals);
    error ('validate_dm: Some eigenvalues are negative');
end

if max(evals) > (1+QLib.close_enough)
    disp ('The DM:');
    disp(a)
    disp ('The eigenvalues:');
    disp(evals);
    error ('validate_dm: Some eigenvalues are greater than 1');
end

if ~is_close(trace(a),1)  % Adding up the eigenvalues may cause inaccuracies for almost-singulat matrices. But it's the same as the trace anyway
    disp ('The DM:');
    disp(a)
    disp ('The eigenvalues:');
    disp(evals);
    fprintf ('Eigenvalues total: %g\n', sum(evals));
    fprintf ('1 - eigenvalues total: %g\n', 1-sum(evals));
    error ('validate_dm: Eigenvalues do not add up to 1');
end

dm = a;