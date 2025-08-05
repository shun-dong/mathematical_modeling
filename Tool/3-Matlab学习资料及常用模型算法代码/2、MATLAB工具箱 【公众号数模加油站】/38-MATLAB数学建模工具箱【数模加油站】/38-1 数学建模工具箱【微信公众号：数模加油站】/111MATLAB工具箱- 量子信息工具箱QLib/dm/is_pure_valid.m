function yn = is_pure_valid(pure, desc)
%
% is_pure_valid: Is the vector a proper pure state?
%
% Usage:  yn = is_pure_valid(dm, desc)
%     pure      The pure state to validate
%     desc      The descriptor (optional)
%     yn        Yes or No / Valid or not?
%
% Testing matches the descriptor with the state and validates norm 1
%
% See also: validate_pure
%

if (length(size(pure)) > 2) || (size(pure,2) > 1)
    yn = false;
    return;
end

if nargin == 2
    if length(pure) ~= prod(desc)
        yn = false;
        return;
    end
end

nrm = pure_norm(pure);
if ~is_close(nrm,1)
    yn = false;
    return;
end

yn = true;
