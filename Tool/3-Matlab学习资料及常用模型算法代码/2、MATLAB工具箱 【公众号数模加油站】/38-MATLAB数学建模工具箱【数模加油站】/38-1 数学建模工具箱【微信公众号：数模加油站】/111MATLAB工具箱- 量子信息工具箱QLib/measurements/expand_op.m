function ret_op = expand_op(op, on_which, desc)
%
% Expand / reorder DoF in an operator to fit a state
%
% Usage: ret_op = expand_op(op, on_which, desc)
%     op         The operator to expand
%     on_which   On which particles does the operator act? Note that ordering is important.
%     desc       For the resulting operator. Required
%     ret_op     The returned opreator
%
% If we have a 3 qbit dm, and we want to change CNOT so it acts on bits 1 and 3, 
% with qbit 3 being the control and qbit 2 the data: 
% cnot3 = expand_op(QLib.gates.CNOT, [3 1], [2 2 2])
%
% See also act_on for similar functionality
%

all_dims = 1:length(desc);
rest_of_dims = setdiff(all_dims,on_which);

prod_rest_of_dims = prod(desc(rest_of_dims));
rest_of_op = eye(prod_rest_of_dims);
unordered_op = kron(op, rest_of_op);

ret_op = ipermute_dof_dm ([on_which rest_of_dims], unordered_op, desc);
