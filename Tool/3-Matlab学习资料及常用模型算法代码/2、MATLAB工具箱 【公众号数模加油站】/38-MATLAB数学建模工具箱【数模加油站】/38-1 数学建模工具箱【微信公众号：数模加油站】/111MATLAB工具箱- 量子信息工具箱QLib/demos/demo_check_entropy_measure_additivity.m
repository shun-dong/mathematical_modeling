% Check the additivity of any entropy measure

clc

%ent_measure = @S_Von_Neumann
%ent_measure = @(x) linear_entropy(x,2)
ent_measure = @(dm) relative_entropy(dm,gen_desc(dm),'print','2','fminunc',optimset('MaxFunEvals',1e4));

save_results_in_detail = true;

N = 100;

fprintf ('Testing additivity over %d random DM pairs ...\n\n', N);
subadditive = 0;
superadditive = 0;
additive = 0;

if save_results_in_detail
    if 1 && exist('demo_check_entropy_measure_additivity_save.mat','file')
        load ('demo_check_entropy_measure_additivity_save.mat');
        start_point = length(save_dm1) + 1;
    else
        save_dm1 = {};
        save_dm2 = {};
        save_ent_12 = [];
        save_ent_1 = [];
        save_ent_2 = [];
        start_point = 1;
    end
else
    start_point = 1;
end


for k=start_point:N
    dm1 = param_dm_rand([2 2]);
    dm2 = param_dm_rand([2 2]);

    dm = kron(dm1,dm2);

    fprintf ('    %4d of %d: ', k,N); drawnow;

    ent_12 = ent_measure(dm);
    ent_1 = ent_measure(dm1);
    ent_2 = ent_measure(dm2);

    if save_results_in_detail
        save_dm1{k} = dm1;
        save_dm2{k} = dm2;
        save_ent_12(k) = ent_12;
        save_ent_1(k) = ent_1;
        save_ent_2(k) = ent_2;
        save ('demo_check_entropy_measure_additivity_save');
    end

    if is_close(ent_12, ent_1 + ent_2)
        additive = additive + 1;
        fprintf ('=  (additive)\n');
    elseif ent_12 < ent_1 + ent_2
        subadditive = subadditive + 1;
        fprintf ('<  (subadditive %g)\n', ent_1 + ent_2 - ent_12);
    else
        superadditive = superadditive + 1;
        fprintf ('>  (superadditive %g)\n', ent_12 - ent_1 - ent_2);
    end
end

fprintf ('\n\n');
fprintf ('Additive (AB = A+B):         %8.4f%%\n', additive/N*100);
fprintf ('Sub-additive (AB < A+B):     %8.4f%%\n', subadditive/N*100);
fprintf ('Super-additive (AB > A+B):   %8.4f%%\n', superadditive/N*100);
fprintf ('\n\n');
