% 定义一个函数来简化模型的建立、拟合优度计算和统计检验
function [R2, MSE, p_value] = evaluate_model(X_data, Y)
    % 添加常数项（截距项）
    X_reg = [ones(size(X_data, 1), 1), X_data];
    
    % 线性回归：计算回归系数
    [b, ~, r, ~, stats] = regress(Y, X_reg);
    
    % 拟合优度：R²
    R2 = stats(1);  % 拟合优度 R²
    % 均方误差 MSE
    MSE = mean(r.^2);  % 均方误差 MSE
    % p值（统计检验）
    p_value = stats(3);  % p值：如果 p值小于 0.05，则模型显著
end
