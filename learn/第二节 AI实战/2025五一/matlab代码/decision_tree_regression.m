% --- 使用决策树回归（Decision Tree Regression）
function [R2, MSE, Y_hat_tree] = decision_tree_regression(X_reg, Y)
    tree_model = fitrtree(X_reg, Y);
    Y_hat_tree = predict(tree_model, X_reg);  % 预测值
    % 计算 MSE（均方误差）
    MSE = mean((Y - Y_hat_tree).^2);
    % 计算 R^2（决定系数）
    SSres = sum((Y - Y_hat_tree).^2);
    SStot = sum((Y - mean(Y)).^2);
    R2 = 1 - SSres/SStot;
end