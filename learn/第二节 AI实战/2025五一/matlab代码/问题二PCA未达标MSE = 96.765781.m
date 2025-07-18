
clc;
clear;

%% 1. 读入数据
Data = xlsread('Data.xlsx');    % 大小 10000 × 1000
[n, p] = size(Data);

%% 2. 数据标准化
% 标准化数据：PCA 要求数据是零均值和单位方差
Data_normalized = (Data - mean(Data)) ./ std(Data);

%% 3. 使用 PCA 降维
% 保留 95% 的方差，自动选择主成分数目
[coeff, score, ~, ~, explained] = pca(Data_normalized);

% 选择合适的主成分数目，保留 95% 方差
cumulative_variance = cumsum(explained);
num_components = find(cumulative_variance >= 99, 1);

% 降维：选择前 num_components 个主成分
Data_reduced = score(:, 1:num_components);  % 降维后的数据

%% 4. 计算压缩效率
% 原始数据的存储大小
original_size = numel(Data);

% 降维后数据的存储大小（包括主成分和样本数）
compressed_size = numel(Data_reduced) + num_components * n;  % 包含主成分系数和样本数

% 压缩比
compression_ratio = original_size / compressed_size;

% 存储空间节省率
storage_savings = 1 - compressed_size / original_size;

fprintf('=== 数据压缩效率 ===\n');
fprintf('压缩比 = %.4f\n', compression_ratio);
fprintf('存储空间节省率 = %.4f\n', storage_savings);

%% 5. 数据还原
% 使用 PCA 逆变换将数据还原到原空间
Data_reconstructed = Data_reduced * coeff(:, 1:num_components)' + mean(Data);

% 6. 计算还原数据的 MSE（均方误差）
MSE = mean((Data - Data_reconstructed).^2, 'all');
fprintf('=== 数据还原准确度 ===\n');
fprintf('MSE = %.6f\n', MSE);

if MSE <= 0.005
    fprintf('还原数据的准确度满足要求，MSE ≤ 0.005\n');
else
    fprintf('还原数据的准确度未满足要求，MSE > 0.005\n');
end

%% 7. 可视化还原效果
% 可视化还原前后数据的差异
figure;
subplot(1,2,1);
imagesc(Data(1:50, 1:50)); % 显示数据前 50 行 50 列
colorbar;
title('原始数据（前 50 行 50 列）');

subplot(1,2,2);
imagesc(Data_reconstructed(1:50, 1:50)); % 显示还原数据前 50 行 50 列
colorbar;
title('还原数据（前 50 行 50 列）');
