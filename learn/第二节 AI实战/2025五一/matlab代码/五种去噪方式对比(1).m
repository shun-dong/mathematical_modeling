clc;
clear;

% 1. 读入数据
X = xlsread('3-X.xlsx');  % 大小 10000 × 100

% 2. 数据去噪方法对比

% 2.1 原始数据（无去噪）
X_original = X;

% 2.2 简单移动平均去噪
window_size = 5;  % 移动平均窗口大小
X_denoised_moving = zeros(size(X));
for i = 1:size(X, 2)
    X_denoised_moving(:, i) = movmean(X(:, i), window_size);  % 对每一列数据进行去噪
end

% 2.3 中值滤波去噪
X_denoised_median = zeros(size(X));
for i = 1:size(X, 2)
    X_denoised_median(:, i) = medfilt1(X(:, i), window_size);  % 对每一列数据进行中值滤波
end

% 2.4 高斯滤波去噪
sigma = 2;  % 高斯滤波器的标准差
X_denoised_gaussian = zeros(size(X));
for i = 1:size(X, 2)
    X_denoised_gaussian(:, i) = imgaussfilt(X(:, i), sigma);  % 高斯滤波
end

% 2.5 小波去噪
X_denoised_wavelet = zeros(size(X));
for i = 1:size(X, 2)
    [c, l] = wavedec(X(:, i), 5, 'db4');  % 小波变换
    c = wthresh(c, 's', 0.05);  % 小波去噪（软阈值处理）
    X_denoised_wavelet(:, i) = waverec(c, l, 'db4');  % 小波重构
end

%% 3. 对比不同去噪方法

% 3.1 可视化比较
figure;
subplot(3,2,1);
plot(X(1:100, 1)); % 原始数据
title('原始数据');

subplot(3,2,2);
plot(X_denoised_moving(1:100, 1)); % 移动平均去噪数据
title('移动平均去噪');

subplot(3,2,3);
plot(X_denoised_median(1:100, 1)); % 中值滤波去噪数据
title('中值滤波去噪');

subplot(3,2,4);
plot(X_denoised_gaussian(1:100, 1)); % 高斯滤波去噪数据
title('高斯滤波去噪');

subplot(3,2,5);
plot(X_denoised_wavelet(1:100, 1)); % 小波去噪数据
title('小波去噪');

subplot(3,2,6);
plot(X(1:100, 1) - X_denoised_wavelet(1:100, 1)); % 还可以显示去噪效果差异
title('去噪效果差异');

sgtitle('不同去噪方法对比（前100行）');

%% 3.2 计算去噪前后的误差

% 计算均方误差（MSE）以评估每种去噪方法
MSE_original = mean(X.^2, 'all');  % 原始数据的 MSE

MSE_moving = mean((X - X_denoised_moving).^2, 'all');  % 移动平均去噪的 MSE
MSE_median = mean((X - X_denoised_median).^2, 'all');  % 中值滤波去噪的 MSE
MSE_gaussian = mean((X - X_denoised_gaussian).^2, 'all');  % 高斯滤波去噪的 MSE
MSE_wavelet = mean((X - X_denoised_wavelet).^2, 'all');  % 小波去噪的 MSE

fprintf('=== 去噪方法比较 ===\n');
fprintf('原始数据 MSE = %.4f\n', MSE_original);
fprintf('移动平均去噪 MSE = %.4f\n', MSE_moving);
fprintf('中值滤波去噪 MSE = %.4f\n', MSE_median);
fprintf('高斯滤波去噪 MSE = %.4f\n', MSE_gaussian);
fprintf('小波去噪 MSE = %.4f\n', MSE_wavelet);


