function [b, stats, MSE, R2] = build_model(X_data, Y)
    % 添加常数项（截距项）
    X_reg = [ones(size(X_data, 1), 1), X_data];

    % 线性回归：计算回归系数
    [b, bint, r, rint, stats] = regress(Y, X_reg);

    % 计算拟合优度
    R2 = stats(1);  % R^2 拟合优度
    MSE = mean(r.^2);  % 均方误差 MSE

    % 输出回归系数和置信区间
    fprintf('回归系数（b）\n');
    disp(b);
    fprintf('回归系数置信区间\n');
    disp(bint);
    fprintf('回归残差的置信区间\n');
    disp(rint);
    fprintf('p值（统计检验）\n');
    disp(stats(3));  % p值：如果 p值小于 0.05，则模型显著
end