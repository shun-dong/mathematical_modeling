%
% Examine how different DM distance measures relate to each other for random density matrices of various sizes.
%

clc

disp ('Show the relationships between different distance measures for random density matrices');
disp (' ');
disp (sprintf('The program will generate %d pairs of random density matrices and pure states', N));
disp ('It will then compute multiple distance measures between these states, and show every pairing of measures as a scatter plot');
disp ('This will be repeated for qubits, qutrits, etc, with the figure number indicates the size of the density matrix');

dist_names = {'Hilbert Schmidt', 'Trace dist.', 'Kullback-Leibler', 'Bures dist.', 'Bures Angle', 'Fidelity'};

N = 1e5;

sections = [0.7 0.29 0.01]; sections = round([0 cumsum(sections)]*N);
type     = [ 1   2   3];
colors   = {'b', 'r', 'g'};

for desc=2:6
    disp (' '); disp (' ');
    disp (sprintf('Investigating dist(dm1,dm2) for dm of size %dx%d', desc,desc));

    d = NaNs(N,5);

    for k=1:N
        if k > sections(1) && k <= sections(2)
            dm1 = param_dm_rand(desc);
            dm2 = param_dm_2x_rand(desc);
        elseif k > sections(2) && k <= sections(3)
            dm1 = pure2dm(param_pure_1_rand(desc));
            dm2 = pure2dm(param_pure_2x_rand(desc));
        elseif k > sections(3) && k <= sections(4)
            dm1 = pure2dm(param_p_1_sqrt_rand(desc));
            dm2 = pure2dm(param_p_2x_sqrt_rand(desc));
        end

        if rand()>0.5
            [dm1,dm2] = swap(dm1,dm2); % Some of the measures aren't symmetric
        end
        
        d(k,1) = dist_Hilbert_Schmidt(dm1,dm2);
        d(k,2) = dist_trace(dm1,dm2);
        d(k,3) = dist_KL(dm1,dm2);
        d(k,4) = dist_Bures(dm1,dm2);
        d(k,5) = dist_Bures_angle(dm1,dm2);
        d(k,6) = fidelity(dm1,dm2);

        if mod(k,10000) == 0
            disp(sprintf('    Processed %dk of %dk DM pairs', k/1000, N/1000));
        end
        drawnow;
    end

    figure(desc);
    title (sprintf('Various distance measures for random (dm1,dm2) pairs. DM of size %d', desc));
    ng = size(d,2)*(size(d,2)-1)/2; nx = ceil(sqrt(ng)); ny = ceil(ng/nx); g = 1;
    for y=1:size(d,2)
        for x=1:size(d,2)
            if y > x
                subplot(ny,nx, g);
                for z=1:(length(sections)-1)
                    scatter(d((sections(z)+1):sections(z+1),y), d((sections(z)+1):sections(z+1),x), 2, colors{z}); hold on;
                end
                xlabel(dist_names{y}); ylabel(dist_names{x});
                if g <= nx
                    title (sprintf('SU(%d)', desc));
                end
                g = g+1;
                drawnow;
            end
        end
    end
end