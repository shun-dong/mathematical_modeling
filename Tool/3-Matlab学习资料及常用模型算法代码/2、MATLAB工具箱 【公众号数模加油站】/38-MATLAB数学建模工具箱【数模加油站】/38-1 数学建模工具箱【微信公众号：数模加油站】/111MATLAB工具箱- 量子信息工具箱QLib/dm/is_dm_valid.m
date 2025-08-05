function yn = is_dm_valid(dm, desc)
%
% is_dm_valid: Is the matrix a proper DM?
%
% Usage:  yn = is_dm_valid(dm, desc)
%     dm        The dm to validate
%     desc      The descriptor (optional)
%     yn        Yes or No / Valid or not?
%
% Tests the matrix is definite semi-positive hermitian of trace 1 and that it matches the descriptor
%
% See also: validate_dm
%

global QLib


if (length(size(dm)) > 2) | (size(dm,2) ~= size(dm,1))
    yn = false;
    return;
end

if nargin == 2
    if size(dm,1) ~= prod(desc)
    yn = false;
    return;
    end
end

if ~is_close(dm,dm')
    yn = false;
    return;
end

evals = cleanup(eig(dm));  % The matrix is Hermitian --> real eigenvalues

if min(evals) < (0-QLib.close_enough)
    yn = false;
    return;
end

if max(evals) > (1+QLib.close_enough)
    yn = false;
    return;
end

if ~is_close(sum(evals),1) > 0
    yn = false;
    return;
end

yn = true;