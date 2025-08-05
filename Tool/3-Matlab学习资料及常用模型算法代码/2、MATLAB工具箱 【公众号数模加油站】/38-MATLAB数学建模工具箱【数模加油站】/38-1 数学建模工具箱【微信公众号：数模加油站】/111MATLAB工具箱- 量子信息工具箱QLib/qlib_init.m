%
% QLib.utils_init
%

global QLib;

% Constants - general

QLib.close_enough = 1e-8;

% Constants - physics

SU_gen_cache([1:10]);

QLib.sigma.x = [0  1; 1  0];
QLib.sigma.y = [0 -i; i  0];
QLib.sigma.z = [1  0; 0 -1];
QLib.sigma.I = [1  0; 0  1];
QLib.sigma.plus  = [0 1; 0 0];       % Raising 
QLib.sigma.minus = QLib.sigma.plus'; % Lowering

QLib.Bell.phi_plus  = [ 1  0  0  1]' ./ sqrt(2);
QLib.Bell.phi_minus = [ 1  0  0 -1]' ./ sqrt(2);
QLib.Bell.psi_plus  = [ 0  1  1  0]' ./ sqrt(2);
QLib.Bell.psi_minus = [ 0  1 -1  0]' ./ sqrt(2);
QLib.Bell.base_change = [QLib.Bell.phi_minus QLib.Bell.phi_plus QLib.Bell.psi_minus QLib.Bell.psi_plus];
QLib.Singlet = QLib.Bell.psi_minus;

QLib.GHZ = GHZ();

QLib.gates.CNOT = [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0]; % Notes: 1st qbit is control, 2nd is data
QLib.gates.Hadamard = [1 1; 1 -1] / sqrt(2); 
QLib.gates.swap = [1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1];
QLib.gates.cphase = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 -1];
QLib.gates.Toffoli = Deutsch_gate(pi/2); % 1st & 2nd bits control, 3rd is data

QLib.eps = {};
for k=1:5
    QLib.eps{k} = epsilon_tensor(k);
end
clear k;

% Java objects
% try
%     QLib.jav.param = parametrizations(QLib.close_enough);
% catch
%     warning ('Failed to initiate Java objects (QLib.jav.*). Package will only be partly functional');
% end
