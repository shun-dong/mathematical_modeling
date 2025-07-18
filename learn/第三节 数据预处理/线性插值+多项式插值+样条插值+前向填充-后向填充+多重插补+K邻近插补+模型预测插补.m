% 清空工作区和命令窗口
clear;
clc;
close all;

%% 一、生成示例数据

% 设置随机种子以确保结果可重复
rng(42);

% 生成时间序列数据
time = (1:100)'; % 时间点 1 到 100
% 生成一个正弦波加上一些噪声作为原始数据
original_data = 10*sin(2*pi*time/25) + randn(100,1);

% 人为制造缺失值（20%的缺失）
num_missing = round(0.1 * length(original_data));
missing_indices = randperm(length(original_data), num_missing);
data_with_missing = original_data;
data_with_missing(missing_indices) = NaN;

% 绘制原始数据和含缺失值的数据
figure;
plot(time, original_data, '-b', 'DisplayName', '原始数据');
hold on;
plot(time, data_with_missing, 'or', 'MarkerFaceColor', 'r', 'DisplayName', '含缺失值');
title('原始数据与含缺失值的数据');
xlabel('时间');
ylabel('值');
legend('Location', 'best');
hold off;

%% 二、线性插值（Linear Interpolation）

data_linear_interp = fillmissing(data_with_missing, 'linear');

%% 三、多项式插值（Polynomial Interpolation）


% 找到非缺失值的索引
valid = ~isnan(data_with_missing);
% 多项式阶数
poly_order = 2;

% 拟合多项式
p = polyfit(time(valid), data_with_missing(valid), poly_order);

% 评估多项式
data_poly_interp = data_with_missing;
missing = isnan(data_poly_interp);
data_poly_interp(missing) = polyval(p, time(missing));


%% 四、样条插值（Spline Interpolation）

data_spline_interp = fillmissing(data_with_missing, 'spline');

%% 五、前向填充/后向填充（Forward Fill / Backward Fill）

% 前向填充
data_ffill = fillmissing(data_with_missing, 'previous');

% 后向填充
data_bfill = fillmissing(data_with_missing, 'next');

%% 六、多重插补（Multiple Imputation）

% MATLAB 中没有内置的多重插补函数，但可以使用 Iterative Imputer 进行类似处理
% 使用 IterativeImputer 需要 Statistics and Machine Learning Toolbox

% 转换为表格
T = table(time, data_with_missing, 'VariableNames', {'Time', 'Value'});

% 初始化 Iterative Imputer
options = statset('MaxIter', 10, 'Display', 'off');
imputer = fitlm(T, 'Value ~ Time', 'RobustOpts', 'off');
data_multi_imputed = data_with_missing;

% 手动进行多重插补（简单迭代）
for i = 1:10
    missing = isnan(data_multi_imputed);
    if ~any(missing)
        break;
    end
    % 训练线性回归模型
    model = fitlm(time(~missing), data_multi_imputed(~missing));
    % 预测缺失值
    data_multi_imputed(missing) = predict(model, time(missing));
end

%% 七、K-邻近插补（K-Nearest Neighbors Imputation）

% MATLAB 没有内置的 KNN 插补函数，可以使用简单的 KNN 方法
% 这里实现一个简单的单变量 KNN 插补（k=5）

k = 5;
data_knn_imputed = data_with_missing;

for i = find(isnan(data_knn_imputed))'
    % 找到最近的 k 个已知邻居
    distances = abs(time - time(i));
    valid = ~isnan(data_knn_imputed);
    [sorted_dist, sorted_idx] = sort(distances(valid));
    nearest_k = data_knn_imputed(valid);
    nearest_k = nearest_k(sorted_idx(1:k));
    % 计算邻居的均值作为插补值
    data_knn_imputed(i) = mean(nearest_k);
end

%% 八、模型预测插补（Model-Based Imputation）

% 使用线性回归模型预测缺失值
data_model_imputed = data_with_missing;
missing = isnan(data_model_imputed);

% 训练线性回归模型
mdl = fitlm(time(~missing), data_model_imputed(~missing));

% 预测缺失值
data_model_imputed(missing) = predict(mdl, time(missing));

%% 九、结果可视化对比

figure;
hold on;
% 绘制原始数据
plot(time, original_data, '-b', 'LineWidth', 1.5, 'DisplayName', '原始数据');
% 绘制含缺失值的数据
plot(time, data_with_missing, 'or', 'MarkerFaceColor', 'r', 'DisplayName', '含缺失值');

% 绘制各补充方法的数据
plot(time, data_linear_interp, '-g', 'LineWidth', 1, 'DisplayName', '线性插值');
plot(time, data_poly_interp, '--m', 'LineWidth', 1, 'DisplayName', '多项式插值');
plot(time, data_spline_interp, '-.c', 'LineWidth', 1, 'DisplayName', '样条插值');
plot(time, data_ffill, ':k', 'LineWidth', 1, 'DisplayName', '前向填充');
plot(time, data_bfill, ':y', 'LineWidth', 1, 'DisplayName', '后向填充');
plot(time, data_multi_imputed, '-^', 'Color', [0.5 0 0.5], 'DisplayName', '多重插补');
plot(time, data_knn_imputed, '-s', 'Color', [0 0.5 0], 'DisplayName', 'KNN 插补');
plot(time, data_model_imputed, '-d', 'Color', [0.5 0.5 0], 'DisplayName', '模型预测插补');

title('缺失值补充方法对比');
xlabel('时间');
ylabel('值');
legend('Location', 'best');
grid on;
hold off;

