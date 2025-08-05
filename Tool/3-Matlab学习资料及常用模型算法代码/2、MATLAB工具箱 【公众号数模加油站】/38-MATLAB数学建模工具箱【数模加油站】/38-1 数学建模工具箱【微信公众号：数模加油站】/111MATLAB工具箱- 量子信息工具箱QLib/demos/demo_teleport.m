%
% Demonstrate how QLib implements teleportation
%

clc

disp ('This program demonstrates Teleportation');
disp ('  ');
disp ('The scheme is as follows:');

disp ('  ');
disp ('Preparation');
disp ('-----------');
disp ('A random data qubit:');
data_qubit = cannonize_pure(param_pure_2x(1000*randrow(param_pure_2x_size([2]))));
disp ('The shared singlet:');
shared_qubit = QLib.Singlet
disp ('Overall state:');
overall_state = kron(data_qubit, shared_qubit)

DATA_PARTICLE = 1;
ALICE_SINGLET = 2;
BOB_SINGLET   = 3;

disp ('  ');
disp ('Action on Alice''s side');
disp ('----------------------');
disp ('CNOT (data,Alice):');
overall_state = act_on_pure(overall_state, QLib.gates.CNOT, [DATA_PARTICLE ALICE_SINGLET])
disp ('Hadamard (data):');
overall_state = act_on_pure(overall_state, QLib.gates.Hadamard, [DATA_PARTICLE])
disp ('  ');
disp ('Measure on Alice''s side');
disp ('-----------------------');
op = diag([0 1 2 3]); % The value we measure is unimportant, as long as its not degenerate
[resulting_DMs, probabilities, measured_values, measured_states] = collapse (pure2dm(overall_state), op, [1 2]); % [1 2]: Which particles are we measuing?
resulting_states = {};
for k=1:4
    resulting_states{k} = cannonize_pure(dm2pure(resulting_DMs{k}));
end
for k=1:4    
    disp (sprintf('With probability %g, the measured bits are %s', probabilities(k), dec2bin(measured_values(k),2)));
    disp ('    The state at Alice (data + her side of the singlet):');
    disp (cannonize_pure(measured_states{k}));
    disp ('    The state at Bob:');
    disp(resulting_states{k})
end

disp ('  ');
disp ('Correcting the state on Bob''s side');
disp ('----------------------------------');
for k=1:4
    switch measured_values(k)
        case 0
            disp ('00: Act with Y: (Y=iZ*X)');
            final_bob_state = cannonize_pure(QLib.sigma.y * resulting_states{k})
        case 1
            disp ('01: Act with X:');
            final_bob_state = cannonize_pure(QLib.sigma.z * resulting_states{k})
        case 2
            disp ('10: Act with Z:');
            final_bob_state = cannonize_pure(QLib.sigma.x * resulting_states{k})
        case 3
            disp ('11: Act with Y:');
            final_bob_state = cannonize_pure(QLib.sigma.I * resulting_states{k})
    end
end


