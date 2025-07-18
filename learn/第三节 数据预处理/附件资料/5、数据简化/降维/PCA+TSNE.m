% 清空工作区和命令窗口
clear;
clc;
close all;

%% 一、生成合成数据

% 设置随机种子以确保结果可重复
rng(42);

% 定义参数
num_samples = 300;       % 总样本数
num_features = 10;       % 特征维度
num_classes = 3;         % 类别数
samples_per_class = num_samples / num_classes;

% 初始化数据和标签
X = zeros(num_samples, num_features);
y = zeros(num_samples, 1);

% 为每个类别生成数据
for class = 1:num_classes
    idx_start = (class-1)*samples_per_class + 1;
    idx_end = class*samples_per_class;
    
    % 每个类别的均值向量不同
    mu = zeros(1, num_features);
    mu(1:3) = class * 5;  % 前3个特征的均值随类别变化
    
    % 协方差矩阵为单位矩阵
    Sigma = eye(num_features);
    
    % 生成多元正态分布数据
    X(idx_start:idx_end, :) = mvnrnd(mu, Sigma, samples_per_class);
    y(idx_start:idx_end) = class;
end

% 将数据转换为表格
data = array2table(X, 'VariableNames', strcat('Feature', string(1:num_features)));
data.Class = categorical(y);

% 可视化部分原始特征（前两个特征）
figure;
gscatter(data.Feature1, data.Feature2, data.Class, 'rgb', 'o^s');
title('合成数据的前两个特征');
xlabel('Feature1');
ylabel('Feature2');
legend('Class 1', 'Class 2', 'Class 3');
grid on;

%% 二、主成分分析（PCA）

% 标准化数据（均值为0，方差为1）
X_pca = X;
X_pca = (X_pca - mean(X_pca)) ./ std(X_pca);

% 执行PCA，保留2个主成分
[coeff, score, ~, ~, explained] = pca(X_pca);

% 选择前2个主成分
pca_2D = score(:, 1:2);

% 创建表格用于绘图
data_pca = array2table(pca_2D, 'VariableNames', {'PC1', 'PC2'});
data_pca.Class = data.Class;

% 可视化PCA结果
figure;
gscatter(data_pca.PC1, data_pca.PC2, data_pca.Class, 'rgb', 'o^s');
title(['PCA降维结果 (解释方差前2个主成分: ' num2str(sum(explained(1:2)), '%.2f') '%)']);
xlabel('主成分 1');
ylabel('主成分 2');
legend('Class 1', 'Class 2', 'Class 3');
grid on;


%% 三、t-SNE（t-分布随机邻域嵌入）

% 标准化数据
X_tsne = X;
X_tsne = (X_tsne - mean(X_tsne)) ./ std(X_tsne);

% 执行t-SNE，降到2维
% 设置一些常用参数，如perplexity和学习率
% 根据数据集大小和结构，perplexity可以调整
perplexity = 30;
learn_rate = 200;
tsne_2D = tsne(X_tsne, 'NumDimensions', 2, 'Perplexity', perplexity, 'LearnRate', learn_rate, 'Verbose', 1);

% 创建表格用于绘图
data_tsne = array2table(tsne_2D, 'VariableNames', {'Dim1', 'Dim2'});
data_tsne.Class = data.Class;

% 可视化t-SNE结果
figure;
gscatter(data_tsne.Dim1, data_tsne.Dim2, data_tsne.Class, 'rgb', 'o^s');
title('t-SNE降维结果');
xlabel('维度 1');
ylabel('维度 2');
legend('Class 1', 'Class 2', 'Class 3');
grid on;


