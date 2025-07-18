% 清空工作区和命令窗口
clear;
clc;
close all;

%% 一、生成示例数据

% 设置随机种子以确保结果可重复
rng(42);

% 生成1000个二维正态分布的正常数据点
mu = [50, 50];        % 均值
sigma = [5, 5];       % 标准差
num_normal = 1000;
normal_data = mvnrnd(mu, diag(sigma.^2), num_normal);

% 添加异常值（50个）
num_outliers = 50;
outliers = [randn(num_outliers,1)*20 + 100, randn(num_outliers,1)*20 + 100];
data = [normal_data; outliers];

% 绘制原始数据
figure;
scatter(normal_data(:,1), normal_data(:,2), 10, 'b', 'filled');
hold on;
scatter(outliers(:,1), outliers(:,2), 50, 'r', 'filled', 'MarkerEdgeColor','k');
title('原始数据集');
xlabel('X1');
ylabel('X2');
legend('正常值', '异常值');
hold off;

%% 二、Z-Score（标准分数）法

% 计算每个维度的Z-Score
z_scores = abs(zscore(data));

% 定义阈值
threshold_z = 3;

% 标记异常值：任意一个维度的Z-Score超过阈值
outliers_z = any(z_scores > threshold_z, 2);

% 显示检测到的异常值数量
num_detected_z = sum(outliers_z);
disp(['Z-Score 方法检测到的异常值数量: ', num2str(num_detected_z)]);

%% 三、IQR（四分位距）法

% 计算每个维度的四分位数
Q1 = prctile(data, 25);
Q3 = prctile(data, 75);
IQR_val = Q3 - Q1;

% 定义上下界限
lower_bound = Q1 - 1.5 * IQR_val;
upper_bound = Q3 + 1.5 * IQR_val;

% 标记异常值：任意一个维度的数据点超出上下界限
outliers_iqr = (data < lower_bound) | (data > upper_bound);
outliers_iqr = any(outliers_iqr, 2);

% 显示检测到的异常值数量
num_detected_iqr = sum(outliers_iqr);
disp(['IQR 方法检测到的异常值数量: ', num2str(num_detected_iqr)]);

%% 四、DBSCAN 聚类分析

% 设置 DBSCAN 参数
epsilon = 5;   % 邻域半径
MinPts = 5;    % 最小邻域内点数

% 使用 DBSCAN 进行聚类
labels_dbscan = dbscan(data, epsilon, MinPts);

% DBSCAN 将噪声点标记为 -1
outliers_dbscan = (labels_dbscan == -1);

% 显示检测到的异常值数量
num_detected_dbscan = sum(outliers_dbscan);
disp(['DBSCAN 方法检测到的异常值数量: ', num2str(num_detected_dbscan)]);

%% 五、隔离森林（Isolation Forest）替代方法：One-Class SVM

% 使用 MATLAB 的 fitcsvm 进行 One-Class SVM
% 将标签设为 +1 表示正常，-1 表示异常
% 注意：One-Class SVM 需要调整参数以适应数据

% 训练 One-Class SVM
SVMModel = fitcsvm(data, ones(size(data,1),1), 'KernelFunction','rbf', ...
    'Standardize',true, 'OutlierFraction',0.05, 'Nu',0.05);

% 预测异常值
[label_svm, score_svm] = predict(SVMModel, data);

% One-Class SVM 将异常值标记为 -1
outliers_svm = (label_svm == -1);

% 显示检测到的异常值数量
num_detected_svm = sum(outliers_svm);
disp(['One-Class SVM 方法检测到的异常值数量: ', num2str(num_detected_svm)]);

%% 六、结果可视化

% 定义颜色和标记
colors = lines(4); % 不同方法的颜色
figure;

% 绘制正常值
scatter(data(~outliers_z,1), data(~outliers_z,2), 10, colors(1,:), 'filled');
hold on;

% 绘制 Z-Score 检测到的异常值
scatter(data(outliers_z,1), data(outliers_z,2), 50, 'MarkerEdgeColor', colors(1,:), ...
    'MarkerFaceColor', colors(1,:), 'Marker','x', 'DisplayName','Z-Score 异常值');

% 绘制 IQR 检测到的异常值
scatter(data(outliers_iqr,1), data(outliers_iqr,2), 50, 'MarkerEdgeColor', colors(2,:), ...
    'MarkerFaceColor', colors(2,:), 'Marker','o', 'DisplayName','IQR 异常值');

% 绘制 DBSCAN 检测到的异常值
scatter(data(outliers_dbscan,1), data(outliers_dbscan,2), 50, 'MarkerEdgeColor', colors(3,:), ...
    'MarkerFaceColor', colors(3,:), 'Marker','d', 'DisplayName','DBSCAN 异常值');

% 绘制 One-Class SVM 检测到的异常值
scatter(data(outliers_svm,1), data(outliers_svm,2), 50, 'MarkerEdgeColor', colors(4,:), ...
    'MarkerFaceColor', colors(4,:), 'Marker','s', 'DisplayName','One-Class SVM 异常值');

title('异常值检测结果比较');
xlabel('X1');
ylabel('X2');
legend('正常值', 'Z-Score 异常值', 'IQR 异常值', 'DBSCAN 异常值', 'One-Class SVM 异常值', 'Location','best');
hold off;

