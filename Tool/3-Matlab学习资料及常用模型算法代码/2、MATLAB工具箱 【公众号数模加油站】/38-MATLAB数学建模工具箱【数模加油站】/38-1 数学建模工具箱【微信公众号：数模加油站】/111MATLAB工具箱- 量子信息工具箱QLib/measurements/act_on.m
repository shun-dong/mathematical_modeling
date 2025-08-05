function ret_dm = act_on (dm, op, on_which, desc)
%
% Act with an operator on some of the DoF of a system
%
% Usage: ret_dm = act_on (dm, op, on_which, desc)
%     dm         The DM to act on
%     op         Which operator to use
%     on_which   On which particles does the operator act? 
%                1. Note that ordering is important.
%                2. As implied by the above, on_which contain DoF numbers and is not a mask
%     desc       For the dm, optional for qubits
%     ret_dm     The returned density matrix
%
% If we have a 3 qbit dm, and we want to enable a CNOT, with qbit 3 being
% the control and qbit 2 the data: ret_dm = act_on(dm, QLib.gates.CNOT, [3 1], [2 2 2])
%
% See also expand_op for similar functionality
%

if nargin < 4
    desc = gen_desc(dm);
end

all_dims = 1:length(desc);
rest_of_dims = setdiff(all_dims,on_which);
prod_rest_of_dims = prod(desc(rest_of_dims));
rest_of_op = eye(prod_rest_of_dims);

xdm = permute_dof_dm ([on_which rest_of_dims], dm, desc);
xop = kron(op, rest_of_op);
xdm = xop * xdm * xop';
ret_dm = ipermute_dof_dm ([on_which rest_of_dims], xdm, desc);
