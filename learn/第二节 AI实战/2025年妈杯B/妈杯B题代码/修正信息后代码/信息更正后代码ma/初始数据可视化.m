% 导入附件一数据
filename = '附件一：老城街区地块信息.xlsx';
data = readtable(filename);

% 查看数据的原始列标题（VariableDescriptions属性）
disp(data.Properties.VariableDescriptions);

% 手动设置有效的列标题（根据原始列标题修改）
data.Properties.VariableNames = {'BlockID', 'YardID', 'BlockArea', 'YardArea', 'Orientation', 'HasResident'};

% 显示前几行数据
disp(head(data));

% 描述性统计分析
% 计算各个数值列的基本统计量：均值、标准差、最大值、最小值等
fprintf('\n地块面积的描述性统计：\n');
disp(['均值：', num2str(mean(data.BlockArea))]);
disp(['标准差：', num2str(std(data.BlockArea))]);
disp(['最小值：', num2str(min(data.BlockArea))]);
disp(['最大值：', num2str(max(data.BlockArea))]);

fprintf('\n院落面积的描述性统计：\n');
disp(['均值：', num2str(mean(data.YardArea))]);
disp(['标准差：', num2str(std(data.YardArea))]);
disp(['最小值：', num2str(min(data.YardArea))]);
disp(['最大值：', num2str(max(data.YardArea))]);

% 可视化：地块面积和院落面积的分布（直方图）
figure;
subplot(1,2,1);
histogram(data.BlockArea, 10);
title('地块面积分布');
xlabel('地块面积（平方米）');
ylabel('频率');

subplot(1,2,2);
histogram(data.YardArea, 10);
title('院落面积分布');
xlabel('院落面积（平方米）');
ylabel('频率');

% 可视化：地块方位分布（柱状图）
figure;
direction_counts = countcats(categorical(data.Orientation));
bar(direction_counts);
set(gca, 'XTickLabel', categories(categorical(data.Orientation)));
title('地块方位分布');
xlabel('方位');
ylabel('数量');

% 可视化：是否有住户的分布（饼图）
figure;
resident_counts = groupcounts(data, 'HasResident');  % 获取住户的分布计数
% 使用 'GroupCount' 列代替 'Count'
pie(resident_counts.GroupCount);
legend({'无住户', '有住户'});
title('是否有住户的分布');


% 可视化：院落ID与地块面积的关系（散点图）
figure;
scatter(data.YardID, data.BlockArea);
title('院落ID与地块面积的关系');
xlabel('院落ID');
ylabel('地块面积（平方米）');

