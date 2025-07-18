clc;
clear;

% 1. 读入数据
X = xlsread('3-X.xlsx');   % 大小 10000 × 100
Y = xlsread('3-Y.xlsx');   % 大小 10000 × 1

% 2. 数据预处理
% 2.1 去噪：这里使用简单的移动平均去噪
window_size = 5;  % 移动平均窗口大小
X_denoised = zeros(size(X));
for i = 1:size(X, 2)
    X_denoised(:, i) = movmean(X(:, i), window_size);  % 对每一列数据进行去噪
end

% 2.2 数据标准化：将数据标准化为零均值单位方差
X_normalized = (X_denoised - mean(X_denoised)) ./ std(X_denoised);

% 3. 建立线性回归模型
% 添加常数项（截距项）
X_reg = [ones(size(X_normalized, 1), 1), X_normalized];

% 线性回归：计算回归系数
[b, bint, r, rint, stats] = regress(Y, X_reg);

% 4. 模型拟合优度计算
R2 = stats(1);  % 拟合优度 R^2
MSE = mean(r.^2);  % 均方误差 MSE

fprintf('=== 模型拟合优度 ===\n');
fprintf('R^2 = %.4f\n', R2);
fprintf('MSE = %.4f\n', MSE);

% 5. 统计检验（回归系数的显著性检验）
fprintf('=== 统计检验结果 ===\n');
fprintf('回归系数（b）\n');
disp(b);
fprintf('回归系数置信区间\n');
disp(bint);
fprintf('回归残差的置信区间\n');
disp(rint);
fprintf('p值（统计检验）\n');
disp(stats(3));  % p值：如果 p值小于 0.05，则模型显著

% 6. 可视化拟合效果
% 6.1 绘制实际值 vs 预测值
Y_hat = X_reg * b;  % 预测值
figure;
scatter(Y, Y_hat, 10, 'filled');
hold on;
min_val = min([Y; Y_hat]); 
max_val = max([Y; Y_hat]);
plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 1.5);
xlabel('实际值', 'FontSize', 12);
ylabel('预测值', 'FontSize', 12);
title('实际值 vs 预测值', 'FontSize', 14);
grid on; box on;

% 6.2 残差图：预测值与残差之间的关系
figure;
scatter(Y_hat, r, 10, 'filled');
xlabel('预测值', 'FontSize', 12);
ylabel('残差', 'FontSize', 12);
title('预测值 vs 残差', 'FontSize', 14);
grid on;

% 6.3 残差直方图
figure;
histogram(r, 50, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('残差', 'FontSize', 12);
ylabel('概率密度', 'FontSize', 12);
title('残差分布', 'FontSize', 14);
grid on;
