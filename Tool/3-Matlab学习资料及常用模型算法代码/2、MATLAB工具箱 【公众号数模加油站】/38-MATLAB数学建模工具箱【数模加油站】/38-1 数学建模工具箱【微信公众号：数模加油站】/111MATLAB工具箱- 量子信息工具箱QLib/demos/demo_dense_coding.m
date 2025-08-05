%
% Demonstration of dense-coding
%

clc

disp ('This program demonstrates Dense Coding');
disp ('  ');
disp ('The scheme is as follows:');

disp ('A random data qubit:');
data_qubit = param_pure_2x(1000*randrow(param_pure_2x_size([2])))
disp ('The shared singlet:');
shared_qubit = QLib.Singlet
disp ('Overall state:');
overall_state = kron(data_qubit, shared_qubit)
disp ('Hadamard (data):');
overall_state = act_on_pure(overall_state, QLib.gates.Hadamard, [1])
disp ('CNOT (data,Alice):');
overall_state = act_on_pure(overall_state, QLib.gates.CNOT, [1 2])
disp ('Measure (Alice):');
op = diag([0 1 2 3]); % The value we measure is unimportant, as long as its not degenerate
[resulting_DMs, probabilities, measured_values] = collapse (pure2dm(overall_state), op, [1 2]); % [1 2]: Which particles are we measuing?
for k=1:4
    disp (sprintf('With probability %g, the measured bits are %s', probabilities(k), dec2bin(measured_values(k),2)));
    disp ('    The state at Alice (data + her side of the singlet):');
    disp (partial_trace(resulting_DMs{k}, [1 1 0]));
    disp ('    The state at Bob:');
    disp(resulting_DMs{k})
end




