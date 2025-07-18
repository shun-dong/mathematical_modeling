%% KMO 检验函数
function kmo_val = kmo_test(correlation_matrix)
    % 计算相关矩阵的反矩阵
    inv_corr = inv(correlation_matrix);
    
    % 计算 KMO 值
    partial_corr = sum(sum(inv_corr - eye(size(correlation_matrix)))) / sum(sum(correlation_matrix - eye(size(correlation_matrix))));
    kmo_val = partial_corr / size(correlation_matrix, 1);
end