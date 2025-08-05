function mixture = measure (dm, op, on_which, desc)
%
% Perform a projective measurement on a (sub)system, returning the resulting mixed state
%
% Usage: mixture = measure (dm, op<, on_which<, desc>>)
%     dm        The DM of the original state
%     op        The operator on some or all of the DoF
%     on_which  On which Dof does the operator act (optional if op acts on all)
%     desc      DoF descriptor. Optional if all qbits
%
% Note that the resulting DM has the same descriptor as the original DM. If
% you wish for a trace-out-ed version of the DM, consider using the
% collapse function.
%

if nargin < 4
    desc = gen_desc(dm);
end

% Note: When expanding an operator (especially when expanding significantly), 
% it is probably more efficient to act with |psi><psi| x I and sum up
% (meaning work with the eigen of the unexpanded op).
% This is the approach taken in collapse
% One may consider additing a version of "measure" to do the same here

if nargin > 2
    op = expand_op(op, on_which, desc);
end

[v,d] = eig(op);

mixture = zeros(size(dm));
for k=1:size(v)
    evec = v(:,k);
    projector = evec * evec';
    mixture = mixture + projector * trace(projector*dm);
end

