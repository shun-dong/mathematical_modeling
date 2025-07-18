clc;
clear;

% 模拟的结果数据
methods = {'Original', 'SMA', 'WMA', 'Median', 'Gaussian', 'Wavelet'};
models = {'Lasso', 'SVR', 'Decision Tree'};

R2_values = [
    0.9968, 0.9986, 0.9096;  % Original
    0.0087, 0.0053, 0.8447;  % SMA
    0.0051, 0.0051, 0.8449;  % WMA
    0.0060, 0.0035, 0.8071;  % Median
    0.5582, 0.5597, 0.8961;  % Gaussian
    0.9012, 0.9042, 0.9063   % Wavelet
];

MSE_values = [
    0.9746, 0.4415, 27.7116;   % Original
    303.8602, 304.9090, 47.6168;  % SMA
    304.9636, 304.9589, 47.5484;  % WMA
    304.6885, 305.4618, 59.1167;  % Median
    135.4328, 134.9688, 31.8380;  % Gaussian
    30.2879, 29.3737, 28.7086    % Wavelet
];

% 绘制模型性能比较的条形图（R² 和 MSE）
figure('Name', '模型比较（R^2 与 MSE）', 'Position', [200, 200, 1200, 800]);

% 绘制 R² 和 MSE 条形图
for i = 1:length(methods)
    subplot(3, 2, i);
    hold on;
    
    % 绘制 R² 条形图
    bar(R2_values(i,:), 'FaceColor', [0.2, 0.6, 0.8], 'BarWidth', 0.4);
    % 绘制 MSE 条形图
    yyaxis right;
    bar(MSE_values(i,:), 'FaceColor', [0.8, 0.2, 0.2], 'BarWidth', 0.4);
    
    % 设置 y 轴标签
    yyaxis left;
    ylabel('R^2', 'FontSize', 12);
    yyaxis right;
    ylabel('MSE', 'FontSize', 12);
    
    xticks(1:3);
    xticklabels(models);
    title(sprintf('%s 方法', methods{i}), 'FontSize', 14);
    grid on;
    hold off;
end

% 绘制实际值与预测值的散点图
figure('Name', '实际值 vs 预测值', 'Position', [200, 200, 1200, 800]);
for i = 1:length(methods)
    for j = 1:length(models)
        subplot(6, 3, (i-1)*3 + j);
        scatter(rand(100, 1) * 500, rand(100, 1) * 500, 10, 'filled'); % 实际数据与预测数据
        hold on;
        min_val = min([rand(100, 1); rand(100, 1)]); 
        max_val = max([rand(100, 1); rand(100, 1)]);
        plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 1.5);
        xlabel('实际值', 'FontSize', 12);
        ylabel('预测值', 'FontSize', 12);
        title(sprintf('%s - %s', methods{i}, models{j}), 'FontSize', 14);
        grid on;
        hold off;
    end
end

% 绘制残差 vs 预测值图
figure('Name', '残差 vs 预测值', 'Position', [200, 200, 1200, 800]);
for i = 1:length(methods)
    for j = 1:length(models)
        subplot(6, 3, (i-1)*3 + j);
        scatter(rand(100, 1) * 500, rand(100, 1) * 100, 10, 'filled'); % 残差与预测值关系
        xlabel('预测值', 'FontSize', 12);
        ylabel('残差', 'FontSize', 12);
        title(sprintf('%s - %s', methods{i}, models{j}), 'FontSize', 14);
        grid on;
    end
end

% 绘制残差分布直方图
figure('Name', '残差分布直方图', 'Position', [200, 200, 1200, 800]);
for i = 1:length(methods)
    for j = 1:length(models)
        subplot(6, 3, (i-1)*3 + j);
        histogram(rand(100, 1) * 50, 20, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]);
        xlabel('残差', 'FontSize', 12);
        ylabel('概率密度', 'FontSize', 12);
        title(sprintf('%s - %s', methods{i}, models{j}), 'FontSize', 14);
        grid on;
    end
end
