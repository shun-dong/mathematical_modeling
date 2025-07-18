% --- 使用支持向量回归（SVR）
function [R2, MSE, Y_hat_svr] = svr_regression(X_reg, Y)
    svr_model = fitrsvm(X_reg, Y, 'KernelFunction', 'linear', 'Standardize', true);
    Y_hat_svr = predict(svr_model, X_reg);  % 预测值
    % 计算 MSE（均方误差）
    MSE = mean((Y - Y_hat_svr).^2);
    % 计算 R^2（决定系数）
    SSres = sum((Y - Y_hat_svr).^2);
    SStot = sum((Y - mean(Y)).^2);
    R2 = 1 - SSres/SStot;
end
