function yn = is_cpd_valid(cpd, desc)
%
% is_cpd_valid: Is the vector a proper CPD?
%
% Usage:  yn = is_cpd_valid(cpd, desc)
%     cpd       The cpd to validate
%     desc      The descriptor (optional)
%     yn        Yes or No / Valid or not?
%
% Testing matches the descriptor with the state and validates real, semi-positive, sum 1
%
% See also: validate_cpd
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
