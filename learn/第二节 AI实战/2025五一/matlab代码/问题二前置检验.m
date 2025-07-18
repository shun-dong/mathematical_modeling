clc;
clear;

% 1. 读入数据
A = xlsread('Data.xlsx');    % 大小 10000 × 100
[n, p] = size(A);

% 2. 计算相关矩阵
correlation_matrix = corr(A);

% 3. KMO 检验
% KMO 检验需要计算局部和整体 KMO 值，MATLAB 没有直接的函数提供KMO检验
% 这里通过计算局部 KMO 和总 KMO
kmo_value = kmo_test(correlation_matrix);

% 4. Bartlett's Test (球形检验)
[~, p_val_bartlett, stat_bartlett] = bartlett_sphericity_test(correlation_matrix);

% 5. 输出结果
fprintf('=== KMO 检验 ===\n');
fprintf('KMO 检验值 = %.4f\n', kmo_value);

fprintf('=== Bartlett 球形检验 ===\n');
fprintf('卡方统计量 = %.4f\n', stat_bartlett);
fprintf('p 值 = %.4f\n', p_val_bartlett);




