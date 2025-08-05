clc

disp ('Demostrate how to take a given multiparticle unitary operator');
disp ('and decompose it using a exponent of an Hermitian operator');
disp ('which is a sum of outer product of single-particle U generators');
disp (' ');




desc = [2 2];
%U = expm(i*0.75*pi*kron(QLib.SU.gen{desc(1)}{1}, QLib.SU.gen{desc(2)}{1}));
%U = param_U_1(randrow(param_U_1_size(prod(desc))));
U = QLib.gates.swap;

[participation, prod_gens] = exp_rep_for_of_unitary_op (U, desc);

H_reconstruct = zeros(size(U));
for k = 1:size(prod_gens.which_gen,1)
    H_reconstruct = H_reconstruct + participation(k) * prod_gens.gen{k};
    
    if ~is_close(participation(k),0)
        fprintf ('[%6d of %6d]  %10g pi   ', k, size(prod_gens.which_gen,1), participation(k)/pi);
        for n=1:size(prod_gens.which_gen,2)
            fprintf ('%3d ', prod_gens.which_gen(k,n));
        end
        fprintf ('\n');
    end
end
U_reconstruct = expm(i*H_reconstruct);

if ~is_close(U,U_reconstruct)
    H = logm(U)/i;
    H
    H_reconstruct
    U
    U_reconstruct
    error ('Failed to reconstruct');
end

disp (' ');
disp ('Operator reconstruction successful');