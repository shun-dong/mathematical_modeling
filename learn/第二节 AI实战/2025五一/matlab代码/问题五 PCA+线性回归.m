clc;
clear;

% 1. 读入数据
X = xlsread('5-X.xlsx');   % 大小 10000 × 100
Y = xlsread('5-Y.xlsx');   % 大小 10000 × 1

% 2. 数据标准化（可选）
% 数据标准化：对数据进行归一化
X_normalized = (X - min(X)) ./ (max(X) - min(X));  % 数据归一化到 [0, 1]

% 3. PCA 降维
% 使用 PCA 将数据降至 20 个主成分（可根据需要调整维度）
[coeff, score, ~, ~, explained] = pca(X_normalized);
% 选择保留的主成分数量（这里选择 95% 的方差）
num_components = find(cumsum(explained) >= 95, 1);  % 找到保留95%方差时的主成分数量
X_reduced = score(:, 1:num_components);  % 降维后的数据

% 4. 重构模型：使用降维后的数据建立与 Y 之间的关系
% 添加常数项（截距项）
X_reg = [ones(size(X_reduced, 1), 1), X_reduced];  % 10000 × (num_components + 1)

% 使用线性回归建立模型
[b, bint, r, rint, stats] = regress(Y, X_reg);

% 5. 评估模型性能：计算 MSE 和 R²
Y_hat_reconstructed = X_reg * b;  % 使用重构模型进行预测
MSE = mean((Y - Y_hat_reconstructed).^2);  % 均方误差
SSres = sum((Y - Y_hat_reconstructed).^2);
SStot = sum((Y - mean(Y)).^2);
R2 = 1 - SSres / SStot;  % R²

fprintf('重构模型的 MSE = %.4f\n', MSE);
fprintf('重构模型的 R² = %.4f\n', R2);

% 6. 结果可视化：显示原始数据和重构数据的比较
figure;
subplot(1, 2, 1);
scatter(Y, Y_hat_reconstructed, 10, 'filled');
hold on;
min_val = min([Y; Y_hat_reconstructed]);
max_val = max([Y; Y_hat_reconstructed]);
plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 1.5);
xlabel('实际值', 'FontSize', 12);
ylabel('重构预测值', 'FontSize', 12);
title('实际值 vs 重构预测值', 'FontSize', 14);
grid on;

subplot(1, 2, 2);
histogram(Y - Y_hat_reconstructed, 50, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('残差', 'FontSize', 12);
ylabel('概率密度', 'FontSize', 12);
title('残差分布', 'FontSize', 14);
grid on;

