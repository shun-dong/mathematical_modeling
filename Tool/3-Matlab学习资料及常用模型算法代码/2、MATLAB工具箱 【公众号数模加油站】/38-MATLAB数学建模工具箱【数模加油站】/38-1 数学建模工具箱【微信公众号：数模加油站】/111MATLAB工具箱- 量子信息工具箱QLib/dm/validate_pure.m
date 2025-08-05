function pure = validate_pure(a, desc)
%
% validate_pure: is the vector a proper pure state?
%
% Usage: pure = validate_pure(a <,desc>)
%     a         The state to validate
%     desc      The descriptor (optional)
%     pure      The input pure returned untouched
%
% If "a" is not a good pure state (norm 1), an error will be issued.
% Otherwise, nothing will happen and the pure state will be returned unaltered.
%
% This function is very useful (as is validate_dm) to make sure nothing has gone awry in a complicated computation.
%

if (length(size(a)) > 2) || (size(a,2) > 1)
    size(a)
    error ('validate_pure: expected a column vector');
end

if nargin == 2
    if length(a) ~= prod(desc)
        desc
        error(sprintf('validate_pure: vector has %d elements, but %d are expected by descriptor'), length(a), prod(desc));
    end
end

nrm = pure_norm(a);
if ~is_close(nrm,1)
    error (sprintf('validate_pure: vector has norm %g (or 1%+g)', nrm,nrm-1));
end

pure = a;
