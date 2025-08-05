function pure = fully_entangled_state(N, two_param_SU_over_U_p)
%
% Parametrization of a fully entangled bi-partite state with 2N DoF
%
% Usage: pure = fully_entangled_state(N, two_param_SU_over_U_p)
%     N    The DoF of one side of the system.
%          For example, for qbit-qbit entanglement (like the Bell states) N=2
%          For qutrit-qutrit entanglement, N=3
%          For M qubits on each side of the system, N=2M
%     two_param_SU_over_U_p  
%          A row of parameters enough for two param_SU_over_U calls.
%          Call param_SU_over_U_size(N), and double the result
%
% Concept is based on the Schmidt decomposition: Take a known fully entangled
% state and perform local rotations.
%
% Note: This is only for bi-partite entanglement. General multi-partite
% states exhibit a more complex entanglement structure (GHZ v. W, etc).
%

pure = zeros(N^2,1);
pure([1:N].^2) = 1/sqrt(N);

L = param_SU_over_U_size(N);
U1 = param_SU_over_U(two_param_SU_over_U_p(1:L));
U2 = param_SU_over_U(two_param_SU_over_U_p(L+(1:L)));

pure = kron(U1,U2) * pure;

