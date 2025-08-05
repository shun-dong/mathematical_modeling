clc         

disp ('Demostrate how to take a given multipartitle density matrix');
disp ('and decompose it using a sum of operators derived from the');
disp ('single-operator SU prod_gens');
disp (' ');

desc = [2 2];

%dm = param_dm(randrow(param_dm_size(desc)));  % A random DM of size "desc"
%dm = pure2dm(QLib.Bell.phi_plus);             % Bell's phi+
%dm = pure2dm(QLib.Singlet);                   % Singlet
%dm = pure2dm([1 0 0 0]');                   % Up-up
%dm = QLib.gates.swap;                         % The swap gate
dm = QLib.gates.CNOT;                         % The CNOT gate
%dm = zeros(4,4); dm(1,1)=1/2; dm(4,4)=1/2;    % 1/2 up up & 1/2 down down

prod_gens = prod_SU_gens(desc);

dm_reconst = zeros(size(dm));

factors = find_span(dm, prod_gens.gen{:});

for k = 1:size(prod_gens.which_gen,1)
    g = prod_gens.gen{k};
    factor = factors(k);
    if ~is_close(factor,0)
        for k2=1:size(prod_gens.which_gen,2)
            fprintf ('%3d ', prod_gens.which_gen(k,k2));
        end
        fprintf (': '); disp(factor);
    end
    dm_reconst = dm_reconst + factor * g;
end

if ~is_close(dm,dm_reconst)
    dm
    dm_reconst
    error ('Bloody hell!');
end
