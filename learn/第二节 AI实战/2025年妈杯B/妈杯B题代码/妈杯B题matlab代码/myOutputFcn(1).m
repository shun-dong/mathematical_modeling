% Step 9: 设置输出回调函数
function stop = myOutputFcn(x, optimValues, state)
    stop = false;  % 初始不停止求解
    if strcmp(state, 'iter')
        fprintf('Iteration: %d, Best Objective Value: %.4f, Nodes: %d\n', ...
                optimValues.iteration, optimValues.fval, optimValues.node);
    end
end
