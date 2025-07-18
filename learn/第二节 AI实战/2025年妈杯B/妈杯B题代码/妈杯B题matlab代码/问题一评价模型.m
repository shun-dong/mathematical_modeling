clc;
clear;

% 读取数据并保留原始列标题
filename = '搬迁补偿方案分析.xlsx';
data = readtable(filename, 'VariableNamingRule', 'preserve'); 
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 查看数据的列名，确认列标题
disp('实际列名:');
disp(data.Properties.VariableNames);  % 显示实际列名

% 根据实际列名调整为英文列名
data.Properties.VariableNames = {'PlotID', 'TargetPlotID', 'ResidentArea', 'TargetArea', 'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetside', 'TargetIsStreetside', 'ResidentCourtyardID', 'TargetCourtyardID'};

% 提取相关数据列（如面积数据）
% 这里只选择了居民地块面积和目标地块面积作为示例
data_matrix = single([data.ResidentArea, data.TargetArea]);  % 使用single减少内存消耗

% 标准化数据（使用最小-最大标准化）
data_norm = (data_matrix - min(data_matrix)) ./ (max(data_matrix) - min(data_matrix));

% Step 3: 计算熵值并求权重
n = size(data_norm, 1);  % 数据行数
m = size(data_norm, 2);  % 数据列数

% 计算每个指标的概率分布
p = data_norm ./ sum(data_norm, 1);

% 计算每个指标的熵值
k = 1 / log(n);  % 常数k
entropy = -k * sum(p .* log(p + eps), 1);  % eps是为了避免log(0)

% 计算每个指标的权重
weight = (1 - entropy) / sum(1 - entropy);  % 权重计算

% 输出权重
disp('每个指标的权重：');
disp(weight);

% Step 4: 计算理想解法
% 计算每个指标的最大值（理想解）%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
ideal_solution = max(data_norm);

% 计算每个方案与理想解的欧几里得距离
distance_to_ideal = sqrt(sum((data_norm - ideal_solution).^2, 2));

% 选择距离最小的方案作为最优方案
[~, ideal_index] = min(distance_to_ideal);

disp('最优搬迁方案ID：');
disp(data.PlotID(ideal_index));  % 假设有 'PlotID' 列表示方案ID

% Step 5: 计算每个方案的补偿金额
% 假设面积补偿与补偿金额直接相关
max_compensation = 150000;  % 最大补偿金额为 15万元
max_increase_pct = 0.30;  % 最大增加比例为 30%

% 计算面积增加比例
area_increase_pct = (data.TargetArea - data.ResidentArea) / data.ResidentArea;

% 计算补偿金额：每增加1%的面积减少5000元，最多30%的面积增加
compensation = max_compensation - max(min(area_increase_pct, max_increase_pct) * max_compensation / 30, 0);

% 将面积补偿金额添加为新列
data.AreaCompensation = compensation;

% Step 6: 计算采光补偿和交通补偿
% 假设朝向不同给予5000补偿
lighting_compensation = (strcmp(data.ResidentOrientation, data.TargetOrientation) == 0) * 30000;  % 若朝向不同，则给予30000补偿

% 临街情况不同给予3000补偿
location_compensation = (strcmp(data.ResidentIsStreetside, data.TargetIsStreetside) == 0) * 20000;  % 临街情况不同

% 计算总补偿金额（面积补偿 + 采光补偿 + 交通补偿）
total_compensation = data.AreaCompensation + lighting_compensation + location_compensation;
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 只取 total_compensation 的第一列
data.TotalCompensation = total_compensation(:, 1);  % 仅取第一列

% 将结果保存为新的表格文件
writetable(data, '问题一结果.xlsx');

disp('计算结果已保存为 "问题一结果.xlsx"');





% 绘制每个指标的权重条形图
figure;
bar(weight);
title('每个指标的权重');
xticks(1:length(weight));
xticklabels({'面积补偿', '总补偿金额', '采光补偿', '交通补偿'});
ylabel('权重');
xlabel('指标');
grid on;

% 绘制每个方案的距离理想解的距离
figure;
bar(distance_to_ideal);
title('每个方案与理想解的距离');
ylabel('距离');
xlabel('方案ID');
xticks(1:n);%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
xticklabels(data.PlotID);
grid on;

