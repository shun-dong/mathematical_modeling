function yes_no = is_product(dm, desc)
%
% Is this a pure state/dm
%
% Usage: yes_no = is_product (obj, desc)
%     obj  A density matrix or pure state
%     desc Descriptor of 'obj'. Required for non-qubits
%

if length(dm) == numel(dm)
    dm = pure2dm(dm);
end

if nargin < 2
    desc = gen_desc(dm);
end

dm2 = 1;
mask0 = zeros(1,length(desc));
for k=1:length(desc)
    mask = mask0; mask(k) = 1;
    dm2 = kron(dm2, partial_trace(dm, mask, desc));
end

yes_no = is_close(dm2, dm);