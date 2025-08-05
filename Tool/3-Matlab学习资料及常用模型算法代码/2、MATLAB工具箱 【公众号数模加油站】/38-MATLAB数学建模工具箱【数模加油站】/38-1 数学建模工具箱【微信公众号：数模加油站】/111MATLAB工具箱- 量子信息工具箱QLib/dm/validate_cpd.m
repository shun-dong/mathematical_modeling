function cpd = validate_cpd(a, desc)
%
% validate_cpd: Make sure a vector describes a good cpd. If yes, return unchanged. If not, issue an error
%
% Usage: cpd = validate_cpd(a <,desc>)
%     a        The state to validate
%     desc     The descriptor (optional)
%     cpd      The input cpd returned untouched
%
% If "a" is not a good CPD (column, norm 1 and real), an error will be issued.
% Otherwise, nothing will happen and the CPD will be returned as is.
%
% This function (like validate_dm) is very useful to verify nothing has
% gone awry in a lengthy computation.
%

if (length(size(a)) > 2) || (size(a,2) > 1)
    size(a)
    error ('validate_cpd: expected a column vector');
end

if nargin == 2
    if length(a) ~= prod(desc)
        desc
        error(sprintf('validate_cpd: vector has %d elements, but %d are expected by descriptor'), length(a), prod(desc));
    end
end

if ~isreal(a)
    error ('validate_cpd: vector must be real');
end

if (max(a) > 1) || (min(a) < 0)
    error ('validate_cpd: vector elements must be in the [0..1] range');
end

nrm = sum(a);
if ~is_close(nrm,1)
    error (sprintf('validate_cpd: vector has sum %g (or 1%+g)', nrm,nrm-1));
end

cpd = a;
