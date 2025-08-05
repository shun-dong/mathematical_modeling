%
% Show the relationship between fidelity and trace distance for a pair of randomly chosen pure states & DMs
%

clc

disp ('Show the relationship between fidelity and trace distance for a pair of randomly chosen pure states & DMs');
disp (' ');

disp (' '); disp(' ');
disp ('1. Theoretical upper & lower limits: sqrt(1-f^2)..(1-f) as large black dots');
draw2d_func(steps(0,1,1000), @(f) sqrt(1-f^2), 'k-', 'LineWidth', 3); hold on;
draw2d_func(steps(0,1,1000), @(f) 1-f, 'k-', 'LineWidth', 3); hold on;
xlabel ('Fidelity (dm1,dm2)');
ylabel ('Trace distance (dm1,dm2)');
grid on; 
% Reference: Nielsen & Chung (9.110)
drawnow;

N = 1000;
N_pure = 1;
N_fully_mixed = 1;
N_dm_param_1 = 10;
N_dm_param_2 =  3;


disp (' '); disp(' ');
disp ('1. Pure states: Big blue dots');
% Pure states
for Nk = 1:N_pure
    buf = NaNs(1000,2);
    for k=1:N
        dm1 = pure2dm(param_pure_2x(1000*randrow(param_pure_2x_size([2 2]))));
        dm2 = pure2dm(param_pure_2x(1000*randrow(param_pure_2x_size([2 2]))));
        buf(k,:) = [fidelity(dm1,dm2) dist_trace(dm1,dm2)];
    end
    scatter(buf(:,1), buf(:,2), 4); hold on; drawnow;
    disp (sprintf ('    %3dk of %3dk\n', Nk, N_pure));
end

disp (' '); disp(' ');
disp ('2. Classical probability distributions (diagonal matrixes): Green circles');
% Fully mixed states
for Nk = 1:N_fully_mixed
    buf = NaNs(1000,2);
    for k=1:N
        dm1 = diag(param_p_1(1000*randrow(param_p_1_size([2 2]))));
        dm2 = diag(param_p_2x(1000*randrow(param_p_2x_size([2 2]))));
        buf(k,:) = [fidelity(dm1,dm2) dist_trace(dm1,dm2)];
    end
    scatter(buf(:,1), buf(:,2), 3); hold on; drawnow;
    disp (sprintf ('    %3dk of %3dk\n', Nk, N_fully_mixed));
end


disp (' '); disp(' ');
disp ('3. General DMs: small dots. Various colors signify different parametrizations');
while 1
    % DM - 1st parametrization
    for Nk = 1:N_dm_param_1
        buf = NaNs(1000,2);
        for k=1:N
            dm1 = param_dm(1000*randrow(param_dm_size([2 2])));
            dm2 = param_dm(1000*randrow(param_dm_size([2 2])));
            buf(k,:) = [fidelity(dm1,dm2) dist_trace(dm1,dm2)];
        end
        scatter(buf(:,1), buf(:,2), 2); hold on; drawnow;
        disp (sprintf ('    Parametrization 1: %3dk of %3dk\n', Nk, N_dm_param_1));
    end

    % DM - 2nd parametrization
    for Nk = 1:N_dm_param_2
        buf = NaNs(1000,2);
        for k=1:N
            dm1 = param_dm(1000*randrow(param_dm_size([2 2])));
            dm2 = param_dm_2x(1000*randrow(param_dm_2x_size([2 2])));
            buf(k,:) = [fidelity(dm1,dm2) dist_trace(dm1,dm2)];
        end
        scatter(buf(:,1), buf(:,2), 1); hold on; drawnow;
        disp (sprintf ('    Parametrization 2: %3dk of %3dk\n', Nk, N_dm_param_2));
    end
end

