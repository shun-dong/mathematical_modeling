% --- 使用Lasso回归（Lasso Regression）
function [R2, MSE, Y_hat_lasso] = lasso_regression(X_reg, Y)
    [beta_lasso, FitInfo_lasso] = lasso(X_reg, Y, 'Lambda', 0.1);  % 调整 Lambda 正则化参数
    Y_hat_lasso = X_reg * beta_lasso + FitInfo_lasso.Intercept;  % 预测值
    % 计算 MSE（均方误差）
    MSE = mean((Y - Y_hat_lasso).^2);
    % 计算 R^2（决定系数）
    SSres = sum((Y - Y_hat_lasso).^2);
    SStot = sum((Y - mean(Y)).^2);
    R2 = 1 - SSres/SStot;
end