function [coefs, pures_a, pures_b] = schmidt_decomp(pure, bipartition_mask, desc)
%
% Compute the Schmidt decompositon for a bipartition of a pure state
%
% Usage: [coefs<, pures_a, pures_b>] = schmidt_decomp(pure<, bipartition_mask<, desc>>)
%     pure             The pure state
%     bipartition_mask The bipartition (optional for two qubits)
%     desc             The states's descriptor
%     coefs            The Schmidt coefficients (always real - the phase is
%                      folded into sysB's vectors)
%     pures_a          Matrices containing the pure states of sides A and B.
%     pures_b          Each column is a state.
%
% The function handles degenerate eigenvalues (Schmidt coefficients) correctly
%

global QLib;
if nargin < 3
    desc = gen_desc(pure);
end
if length(desc) == 2 && nargin < 2
    bipartition_mask = [1 0];
end

dm = pure2dm(pure);
dm1 = partial_trace(dm,  bipartition_mask, desc);  
dm2 = partial_trace(dm, ~bipartition_mask, desc); 

[u1,dd1] = eig(dm1); d1 = diag(dd1);
[u2,dd2] = eig(dm2); d2 = diag(dd2);

% The number of coefficients is determined by min (dimension of A, dimension of B)
N = min(size(dm1,1),size(dm2,1));
coefs = zeros(1,N);
pures_of_a = NaNs(size(dm1,1),N);
pures_of_b = NaNs(size(dm2,1),N);

% We'll reorder the particles so that subsystem A is on the left and B is on the right
reordering   = [find(bipartition_mask) find(~bipartition_mask)];
mangled_desc = desc(reordering); 
for k=1:N
    if ~is_close(d1(end-k+1),0)
        pures_of_a(:,k) = u1(:,end-k+1);

        % The coefficient is derived from the eigenvalues of either of the subsystems.
        % If we have eigenvalue degeneracy, we need to search for the match
        % of the eigenvector in sysA and it's counterpart in sysB.
        % The easiest way to find the match (may not be efficient) is by projecting the original
        % pure state using the kron(sysA pure, sysB pure) and verifying
        % we've got something that's not orthogonal to the pure state.
        
        b_candid = find(abs(d2-d1(end-k+1))<QLib.close_enough); % the relevant eigens from sys B
        for zz=1:length(b_candid)
            z = b_candid(zz);
            pures_of_b(:,k) = u2(:,z);
            v = kron(pures_of_a(:,k),pures_of_b(:,k));
            v = ipermute_dof_pure (reordering, v, mangled_desc); % reorder to match the original
            coef_candid = v'*pure; % If we chose the right one
            if is_close(coef_candid*conj(coef_candid), d1(end-k+1)) % We should have a match
                coefs(k) = coef_candid;
                break; % Enough searching
            end
        end

        % Fold the phase of the coefficient into the sysB vector
        abs_coef = abs(coefs(k));
        phasor = abs(coefs(k))/coefs(k);
        pures_of_b(:,k) = pures_of_b(:,k)*phasor;
        coefs(k) = abs_coef;
    else
        coefs(k) = 0;
    end
end


if nargout > 1
    pures_a = pures_of_a;
    pures_b = pures_of_b;
end

