%% Bartlett 球形检验函数
function [p_value, stat, crit] = bartlett_sphericity_test(corr_matrix)
    % Bartlett's Test: 检验相关矩阵是否为单位矩阵
    [~, stat, ~] = size(corr_matrix); 
    n = size(corr_matrix, 1);
    k = size(corr_matrix, 2);
    
    % 计算 Bartlett's test 统计量
    stat = - (n - 1 - (2 * k + 5) / 6) * log(det(corr_matrix));
    
    % 卡方分布的自由度
    crit = (k * (k - 1)) / 2;
    
    % 根据卡方分布计算 p 值
    p_value = 1 - chi2cdf(stat, crit);
end