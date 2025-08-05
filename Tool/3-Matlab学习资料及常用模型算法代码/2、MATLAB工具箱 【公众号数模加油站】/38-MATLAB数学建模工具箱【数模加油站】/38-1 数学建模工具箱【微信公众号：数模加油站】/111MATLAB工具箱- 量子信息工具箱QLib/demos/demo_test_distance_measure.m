%
% Is a given function a good distance measure?
%
% You specify the function, and the program tests the measure for the
% various required properties.
%

clc

distance_measure = @dist_trace;


disp ('Is a given function a good distance measure?');
disp (' '); 
disp ('This program checks this by throwing lots of random matrices at it and checking:');
disp ('    1. Is D(dm,dm) == 0?');
disp ('    2. Is D(dm1,dm2) == D(dm2,dm1)?');
disp ('    3. Is is invariant under unitary transformation?');
disp ('    4. Does it satisfy the triangle inequality?');
disp ('In each step it checks many different DM sizes');
disp ('Note that since a lot of cases are tested, this runs for a looong time');
disp (' '); disp (' ');

disp ('Step 1: Is D(dm,dm) == 0?');
for n=1:1e4
    desc = irand(2,5,1,2);
    SU_gen_cache(prod(desc));
    dm = param_dm(1000*randrow(param_dm_size(desc)));
    if ~is_close(distance_measure(dm,dm),0)
        dm
        error ('Function is not reflective. Not a good metric');
    end
end
disp ('        Seems ok');
disp (' ');

disp ('Step 2: Is D(dm1,dm2) == D(dm2,dm1)?');
for n=1:1e4
    desc = irand(2,5,1,2);
    SU_gen_cache(prod(desc));
    dm1 = param_dm(1000*randrow(param_dm_size(desc)));
    dm2 = param_dm(1000*randrow(param_dm_size(desc)));
    if ~is_close(distance_measure(dm1,dm2),distance_measure(dm2,dm1))
        error ('Function is not symmetric. Not a good metric');
    end
end
disp ('        Seems ok');
disp (' ');

disp ('Step 3: Is is invariant under unitary transformation?');
for n=1:1e3
    desc = irand(2,5,1,2);
    SU_gen_cache(prod(desc));
    dm1 = param_dm(1000*randrow(param_dm_size(desc)));
    dm2 = param_dm(1000*randrow(param_dm_size(desc)));
    d = distance_measure(dm1,dm2);
    for k=1:10
        U = param_U_2(1000*randrow(param_U_2_size(desc)));
        dm1x = U'*dm1*U;
        dm2x = U'*dm2*U;        
        if ~is_close(distance_measure(dm1x,dm2x),d)
            error ('Function is not invariant under unitaries. Not a good metric');
        end
    end
end
disp ('        Seems ok');
disp (' ');

disp ('Step 4: Does it satisfy the triangle inequality?');
disp ('        Is D(dm1,dm3) <= D(dm1,dm2)+D(dm2,dm3) for all dm1,dm2 and dm3?');
disp ('        We''ll check this by randomly choosing dm1 and dm3, and then searching for the dm2 which will minimize the left side of the inequality');
disp ('        Note: This will take A LOT of time');
disp (' ');


found_positive = 0;
for n=1:100
    n
    desc = irand(2,5,1,2);
    SU_gen_cache(prod(desc));
    dm1 = param_dm(1000*randrow(param_dm_size(desc)));
    dm3 = param_dm(1000*randrow(param_dm_size(desc)));

    D13 = distance_measure(dm1,dm3);
    
    [best_p] = fmin_combo(@(p) distance_measure(dm1, param_dm(p)) + distance_measure(param_dm(p), dm3) - D13, ...
        1000*randrow(param_dm_size(desc)), ...
        fmin_combo_opt('print',2));
    dm2 = param_dm(best_p);
    
    the_diff = distance_measure(dm1,dm2) + distance_measure(dm2,dm3) - D13;
    
    if the_diff < 0
        dm1
        dm2
        dm3        
        error ('Not a good measure');
    end
    if ~is_close(the_diff,0)
        found_positive = found_positive+1;
    end
end

if ~found_positive
    disp ('Exact additivity! Weird');
end