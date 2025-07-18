%% 回归性能指标计算和残差统计
function [metrics, stats] = calculate_metrics(residuals, B, B_hat)
    % 计算误差指标
    MSE = mean(residuals.^2);
    RMSE = sqrt(MSE);
    MAE = mean(abs(residuals));
    SSres = sum(residuals.^2);
    SStot = sum((B - mean(B)).^2);
    R2 = 1 - SSres / SStot;

    metrics = struct('MSE', MSE, 'RMSE', RMSE, 'MAE', MAE, 'R2', R2);

    % 残差统计
    mean_residual = mean(residuals);
    std_residual = std(residuals);
    stats = struct('mean_residual', mean_residual, 'std_residual', std_residual);
end
