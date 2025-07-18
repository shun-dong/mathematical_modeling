clc;
clear;

% 1. 读入数据
X = xlsread('3-X.xlsx');   % 大小 10000 × 100
Y = xlsread('3-Y.xlsx');   % 大小 10000 × 1

% 2. 数据标准化（可选）
% 数据标准化：对数据进行归一化
X_normalized = (X - min(X)) ./ (max(X) - min(X));  % 数据归一化到 [0, 1]

% 3. 去噪处理
% 3.1 简单移动平均（SMA）
window_size = 100;  % 移动平均窗口大小
X_sma = zeros(size(X));
for i = 1:size(X, 2)
    X_sma(:, i) = movmean(X(:, i), window_size);  % 对每一列数据进行去噪
end

% 3.2 加权移动平均（WMA）
weights = linspace(1, 2, window_size);  % 权重从1到2
X_wma = zeros(size(X));
for i = 1:size(X, 2)
    X_wma(:, i) = filter(weights/sum(weights), 1, X(:, i));  % 加权移动平均
end

% 3.3 中值滤波
X_median = zeros(size(X));
for i = 1:size(X, 2)
    X_median(:, i) = medfilt1(X(:, i), window_size);  % 中值滤波
end

% 3.4 高斯滤波
sigma = 1;  % 高斯滤波的标准差
X_gaussian = zeros(size(X));
for i = 1:size(X, 2)
    X_gaussian(:, i) = imgaussfilt(X(:, i), sigma);  % 高斯滤波
end

% 3.5 小波去噪（使用db4小波）
X_wavelet = zeros(size(X));
for i = 1:size(X, 2)
    [C, L] = wavedec(X(:, i), 5, 'db4');  % 5层小波分解
    C(1:round(length(C)*0.1)) = 0;  % 去除部分高频信号
    X_wavelet(:, i) = waverec(C, L, 'db4');  % 小波重构
end

% 4. 添加常数项（截距项）
X_reg = [ones(size(X_normalized, 1), 1), X_normalized];



% 5. 对不同去噪后的数据进行回归建模并计算精度
methods = {'Original', 'SMA', 'WMA', 'Median', 'Gaussian', 'Wavelet'};
X_denoised = {X_normalized, X_sma, X_wma, X_median, X_gaussian, X_wavelet};


for i = 1:length(methods)
    fprintf('=== %s 方法 ===\n', methods{i});
    
    % 对每种去噪后的数据应用回归模型
    [R2_lasso, MSE_lasso, Y_hat_lasso] = lasso_regression([ones(size(X_denoised{i}, 1), 1), X_denoised{i}], Y);
    fprintf('Lasso Regression:\n');
    fprintf('R^2 = %.4f, MSE = %.4f\n', R2_lasso, MSE_lasso);
    
    [R2_svr, MSE_svr, Y_hat_svr] = svr_regression([ones(size(X_denoised{i}, 1), 1), X_denoised{i}], Y);
    fprintf('SVR:\n');
    fprintf('R^2 = %.4f, MSE = %.4f\n', R2_svr, MSE_svr);
    
    [R2_tree, MSE_tree, Y_hat_tree] = decision_tree_regression([ones(size(X_denoised{i}, 1), 1), X_denoised{i}], Y);
    fprintf('Decision Tree:\n');
    fprintf('R^2 = %.4f, MSE = %.4f\n\n', R2_tree, MSE_tree);
    
    % 绘制实际值 vs 预测值的散点图
    figure;
    subplot(2,2,1);
    scatter(Y, Y_hat_lasso, 10, 'filled');
    hold on;
    min_val = min([Y; Y_hat_lasso]);
    max_val = max([Y; Y_hat_lasso]);
    plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 1.5);
    xlabel('实际值', 'FontSize', 12);
    ylabel('预测值（Lasso）', 'FontSize', 12);
    title('实际值 vs 预测值（Lasso）', 'FontSize', 14);
    grid on;

    % 绘制残差 vs 预测值图
    subplot(2,2,2);
    scatter(Y_hat_lasso, Y - Y_hat_lasso, 10, 'filled');
    xlabel('预测值', 'FontSize', 12);
    ylabel('残差', 'FontSize', 12);
    title('残差 vs 预测值（Lasso）', 'FontSize', 14);
    grid on;

    % 绘制残差直方图
    subplot(2,2,3);
    histogram(Y - Y_hat_lasso, 50, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]);
    xlabel('残差', 'FontSize', 12);
    ylabel('概率密度', 'FontSize', 12);
    title('残差分布（Lasso）', 'FontSize', 14);
    grid on;
    
    % 绘制模型比较的条形图（R² 和 MSE）
    subplot(2,2,4);
    model_names = {'Lasso', 'SVR', 'Decision Tree'};
    R2_values = [R2_lasso, R2_svr, R2_tree];
    MSE_values = [MSE_lasso, MSE_svr, MSE_tree];

    yyaxis left;
    bar(R2_values, 'FaceColor', [0.2, 0.6, 0.8]);
    ylabel('R^2', 'FontSize', 12);
    ylim([0, 1]);

    yyaxis right;
    bar(MSE_values, 'FaceColor', [0.8, 0.2, 0.2]);
    ylabel('MSE', 'FontSize', 12);
    ylim([0, max(MSE_values)*1.2]);

    xticks(1:3);
    xticklabels(model_names);
    title('模型比较：R² 与 MSE', 'FontSize', 14);
    grid on;
end