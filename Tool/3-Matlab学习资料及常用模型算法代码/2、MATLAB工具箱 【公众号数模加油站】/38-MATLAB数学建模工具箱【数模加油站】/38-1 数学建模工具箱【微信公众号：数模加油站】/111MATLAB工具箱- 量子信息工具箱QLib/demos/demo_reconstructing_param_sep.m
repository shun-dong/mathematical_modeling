% Given a DM, find the closest separable state and then query for its "construction"'
% You will discover that the separable decompositions resulting from the numeric search are
% anything but intuitive

clc

disp ('Given a DM, find the closest separable state and then query for its "construction"');
disp ('This may take up to a few minutes, depending on CPU');
disp ('   ');
N = 2;
desc = 2*ones(N,1);

target_dm = pure2dm(GHZ(N));
%target_dm = pure2dm(W101(N)); 
%target_dm = tmp_rand_seprable_by_desc(desc);

[rel_ent, best_sep_p] = relative_entanglement(target_dm,desc);

fprintf ('Relative entropy for given state: %g\n', rel_ent);

[sep_dm, sep_vecs, sep_mixing] = param_sep_2x(best_sep_p,desc);

dm_check = zeros(prod(desc));
for k=1:prod(desc)^2
    if 1 || ~is_close(mixing(k),0)
        pos = 1;
        v = 1;
        for m=1:length(desc)
            pos2 = pos + desc(m);
            pure = sep_vecs(pos:(pos2-1),k);
            v = kron(v,pure);
            pos = pos2;
        end
    dm1 = pure2dm(v);
    dm1 = dm1 ./ trace(dm1);
    validate_dm(dm1);
    dm_check = dm_check + sep_mixing(k).*dm1;
    end
end

validate_dm(dm_check);
fprintf ('\n\nEuclidean distance of reconstructed matrix (validate reconstruction): %g\n', Euclidean(sep_dm,dm_check));
fprintf ('\nKL distance (dm, separable): %g\n', dist_KL(target_dm,dm_check));
fprintf ('\nKL distance (separable, dm): %g (just to see if it is symmetric)\n',dist_KL(dm_check,target_dm));
