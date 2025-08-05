function [DMs, probability, measured_value, measured_states] = collapse (dm, op, on_which, desc)
%
% Compute the various collapsed "universes" and their probabilities when
% applying a projective measurement on a system
%
% Usage: [DMs<, probability<, measured_value>>] = collapse (dm, op, on_which<, desc>)
%     dm            The universe
%     op            The operator, on some of the DoF
%     on_which      On which DoF does the operator act? (vector)
%     desc          Descriptor of the universe (optional for all qbits)
%     DMs           A cell array (DMs{1}, DMs{2}, ...) of the various
%                   resulting "universes", with the DoF in "on_which" traced out.
%     probability   A vector of probabilities for each "universe"
%     measured_value The value of the measured operator for this "universe"
%     measured_states The states measured when the system collapsed
%
% Notes: 
%     1. length(DMs) == length(probability) == size(op)
%     2. Use "vrand(probability)" to choose into which world you collapse
%

if nargin < 4
    desc = gen_desc(dm);
end

all_dims = 1:length(desc);
rest_of_dims = setdiff(all_dims,on_which);
prod_rest_of_dims = prod(desc(rest_of_dims));
rest_of_op = eye(prod_rest_of_dims) ./ prod_rest_of_dims; 
    % We want a trace-preserving projector extension, so we need this to be unity trace

partial_trace_keep_mask = true(1,length(desc)); partial_trace_keep_mask(on_which) = false;

DMs = {}; measured_state = {};
prob = NaNs(length(op),1);
measured_value = NaNs(length(op),1);
[v,d] = eig(op);
for k=1:size(v)
    evec = v(:,k);
    if nargout >= 4 
        measured_states{k} = evec;
    end
    projector = evec * evec';
    unordered_expanded_projector = kron(projector, rest_of_op);
    expanded_projector = ipermute_dof_dm ([on_which rest_of_dims], unordered_expanded_projector, desc);
    if ~is_close(trace(expanded_projector),1)
        error 'Expanded op not unit trace';
    end
    prob(k) = real(trace(expanded_projector*dm)); % "real" to remove tiny imaginary inaccuracy
    if ~is_close(prob(k),0)
        DMs{k}  = cleanup(partial_trace(expanded_projector*dm, partial_trace_keep_mask, desc)) ./ prob(k); % cleanup will make sure the diagonal is real
        prob(k) = prob(k) * prod_rest_of_dims; % prod_rest_of_dims is for the degeneracy in the projection over untraced dimensions                                                                      
    else
        DMs{k}  = NaNs(size(partial_trace(expanded_projector*dm, partial_trace_keep_mask, desc))); 
        prob(k) = 0;
    end
end

if nargout > 1
    probability = prob;
    if nargout > 2
        measured_value = diag(d);
    end
end