%
% A demo utilizing the enhanced search (fmin_combo) to show euivalence
% between the two parametrizations of SU(N)  (param_SU and param_SU_2).
%

clc; 

disp ('Finding the equivalence between the two SU(N) parametrizations (numerically)');


for N=2:8
    NN = N^2-1;    
    for k=1:NN
        fixed_ang = zeros(1,NN); fixed_ang(k) = pi/2;
        fixed_point = param_SU_2(fixed_ang);
        disp(cleanup(fixed_point))
        fprintf ('%2d %4d  Searching ... ', N,k); drawnow;
        [min_point, min_dist, num_reps] = ...
            fmin_combo(@(p) Euclidean(fixed_point,param_SU_1(p*sqrt(N))), ...
            0, zeros(1,NN), ...
            fmin_combo_opt('print',2,'elapsed_time_limit',60));
        if (num_reps > 0) && (min_dist < 1e-6)
            fprintf ('Found: \n'); 
            for p=1:NN
                min_point_2 = cleanup(min_point);
                fprintf ('                      %10.6f\n', min_point_2(p));
            end
            fprintf ('\n');
        else
            fprintf ('Not found (within alloted time)'); 
            disp(fixed_point - param_SU_1(min_point*sqrt(N)));
            disp(min_point./pi)
        end
        drawnow;            
    end
end
