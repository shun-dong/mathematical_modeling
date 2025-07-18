clc;
clear;

% 1. 读入数据
X = xlsread('3-X.xlsx');   % 大小 10000 × 100
Y = xlsread('3-Y.xlsx');   % 大小 10000 × 1

% 2. 数据标准化（可选）
% 数据标准化：对数据进行归一化
X_normalized = (X - min(X)) ./ (max(X) - min(X));  % 数据归一化到 [0, 1]

% 3. 去噪方法
% 3.1 简单移动平均（SMA）
window_size = 5;  % 移动平均窗口大小
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

% 4. 回归模型评估（使用所有去噪方法）
methods = {'SMA', 'WMA', 'Median', 'Gaussian', 'Wavelet'};
X_denoised = {X_sma, X_wma, X_median, X_gaussian, X_wavelet};

% 存储回归精度（R^2 和 MSE）
results = struct();

for i = 1:length(methods)
    % 添加常数项（截距项）
    X_reg = [ones(size(X_denoised{i}, 1), 1), X_denoised{i}];
    
    % 线性回归：计算回归系数
    [b, bint, r, rint, stats] = regress(Y, X_reg);
    
    % 拟合优度 R^2 和 MSE
    R2 = stats(1);  % 拟合优度 R^2
    MSE = mean(r.^2);  % 均方误差 MSE
    
    % 存储结果
    results.(methods{i}).R2 = R2;
    results.(methods{i}).MSE = MSE;
end

% 输出每种方法的结果
for i = 1:length(methods)
    fprintf('=== %s 方法 ===\n', methods{i});
    fprintf('R^2 = %.4f\n', results.(methods{i}).R2);
    fprintf('MSE = %.4f\n\n', results.(methods{i}).MSE);
end



