clc;
clear;

%% 1. 读入数据
Data = xlsread('Data.xlsx');    % 大小 10000 × 1000
[n, p] = size(Data);            % n: 样本数，p: 特征数

%% 2. 标准化数据（可选）
% 数据标准化：NMF 对数据进行非负约束，最好先将数据做标准化处理
Data_normalized = (Data - min(Data)) ./ (max(Data) - min(Data)); % 数据归一化到 [0, 1]

% 3. 变量初始化
min_MSE = Inf;  % 最小 MSE 初始为无穷大
best_k = 0;     % 最优维度初始化

% 4. 遍历 10 到 100 维进行降维并计算 MSE
for k = 10:100
    % 进行 NMF 降维
    [W, H] = nnmf(Data_normalized, k);  % W 是 n×k，H 是 k×p

    % 使用 NMF 逆变换进行数据还原
    Data_reconstructed = W * H;

    % 计算还原数据的 MSE（均方误差）
    MSE = mean((Data_normalized - Data_reconstructed).^2, 'all');

    % 更新最小 MSE 和对应的最佳维度
    if MSE < min_MSE
        min_MSE = MSE;
        best_k = k;
    end
end

% 输出最优的降维维度和对应的 MSE
fprintf('=== 最优降维维度 ===\n');
fprintf('最优维度 = %d\n', best_k);
fprintf('对应的 MSE = %.6f\n', min_MSE);
%% 3. 使用 NMF 进行降维
% 假设我们选择降到 k 个维度，这里选择 k=50 作为示例
k = 15;  % 降到 50 维
[W, H] = nnmf(Data_normalized, k);  % W 是 n×k，H 是 k×p

% W: 表示原始数据在低维空间中的表示（每个样本的低维表示）
% H: 表示低维空间的基矩阵

%% 4. 计算压缩效率
% 原始数据存储大小
original_size = numel(Data);

% 降维后数据存储大小（W 和 H）
compressed_size = numel(W) + numel(H);  % 存储 W 和 H

% 压缩比
compression_ratio = original_size / compressed_size;

% 存储空间节省率
storage_savings = 1 - compressed_size / original_size;

fprintf('=== 数据压缩效率 ===\n');
fprintf('压缩比 = %.4f\n', compression_ratio);
fprintf('存储空间节省率 = %.4f\n', storage_savings);

%% 5. 数据还原（使用 NMF 逆变换）
Data_reconstructed = W * H;  % 使用 W 和 H 重构数据

% 6. 计算还原数据的 MSE（均方误差）
MSE = mean((Data_normalized - Data_reconstructed).^2, 'all');
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

