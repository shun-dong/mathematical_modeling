% 清空工作区和命令窗口
clear;
clc;

%% 1. 生成示例数据
% 设置随机种子以确保结果可重复
rng(0);


% 定义均值和标准差
mu = 50;        % 均值
sigma = 10;     % 标准差

% 生成1000个正态分布的随机数
normal_data = mu + sigma * randn(1000, 1);

data =normal_data ;

%% 2. 计算 Z-Score
% 计算数据的均值和标准差
mu = mean(data);
sigma = std(data);

% 计算每个数据点的 Z-Score
z_scores = (data - mu) / sigma;

% 计算绝对值的 Z-Score
abs_z_scores = abs(z_scores);

%% 3. 识别异常值
% 设置 Z-Score 阈值
threshold = 3;

% 标记异常值：|Z| > threshold
outliers = abs_z_scores > threshold;

% 显示异常值的信息
disp('原始数据:');
disp(data);
disp('对应的 Z-Score:');
disp(z_scores);
disp('异常值标记 (1 表示异常值):');
disp(outliers);

%% 4. 可视化结果

% 绘制箱线图，直观展示异常值
figure;
boxplot(data, 'Labels', {'数据值'});
title('箱线图 - 异常值检测');
ylabel('值');

% 绘制散点图，标记异常值
figure;
scatter(1:length(data), data, 'b', 'filled');
hold on;
scatter(find(outliers), data(outliers), 'r', 'filled', 'MarkerEdgeColor','k');
title('散点图 - 异常值检测');
xlabel('数据点索引');
ylabel('值');
legend('正常值', '异常值');
hold off;

%% 5. 删除异常值（可选）
% 根据需要，可以选择删除异常值
data_cleaned = data(~outliers);

% 显示清洗后的数据
disp('清洗后的数据（删除异常值）:');
disp(data_cleaned);

% 绘制清洗后的数据箱线图
figure;
boxplot(data_cleaned, 'Labels', {'清洗后数据'});
title('箱线图 - 清洗后数据');
ylabel('值');
