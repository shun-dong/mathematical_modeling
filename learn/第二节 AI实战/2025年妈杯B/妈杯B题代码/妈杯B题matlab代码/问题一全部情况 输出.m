clc;
clear;

% Step 1: 读取数据，并将列标题转化为英文
data = readtable('附件一：老城街区地块信息.xlsx', 'VariableNamingRule', 'preserve'); 
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% Step 1.1: 检查数据的列名，查看实际列标题
disp(data.Properties.VariableNames);  % 输出列名，确认实际的列标题

% 根据输出的列名进行修改，例如假设实际的列名为 '是否有住户'，我们将其修改
% 将表格的列标题更改为英文
data.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% 获取地块的数量
n = height(data); % 获取地块的总数

% 临街房屋编号
streetside_plots = [3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, ...
                    28, 29, 30, 31, 32, 33, 38, 39, 40, 52, 53, 61, 62, 65, 81, 83, 78, 77, 76, 98];

% 朝向与采光等级的关系：正南=正北 > 东厢 > 西厢
% 正南和正北为1档，东厢为2档，西厢为3档
orientation_values = containers.Map({'南', '北', '东', '西'}, {1, 1, 2, 3}); 

% Step 2: 选择有住户的地块（HasResident = 1）
resident_indices = find(data.HasResident == 1); % 找到所有有住户的地块%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da

% Step 3: 计算每个居民的目标区域及其评分
compensation_table = table; % 用于存储最终的补偿结果

for i = 1:length(resident_indices)
    resident_idx = resident_indices(i); % 当前有住户地块的索引
    
    % 获取当前居民地块的面积和采光
    current_area = data.PlotArea(resident_idx);
    current_orientation = data.Orientation{resident_idx};
    current_orientation_value = orientation_values(current_orientation);
    current_is_streetside = ismember(data.PlotID(resident_idx), streetside_plots); % 临街判断
    current_courtyard_id = data.CourtyardID(resident_idx); % 当前居民地块所属的院落ID
    
    % 找到满足条件的目标地块
    possible_targets = []; % 存储符合条件的目标地块索引
    
    for j = 1:n
        if data.HasResident(j) == 0 && data.PlotArea(j) > current_area && data.PlotArea(j) <= current_area * 1.3
            % 目标地块的面积必须大于现有地块面积，且目标地块的面积最多为原面积的1.3倍，同时目标地块没有住户
            target_is_streetside = ismember(data.PlotID(j), streetside_plots); % 临街判断
            target_courtyard_id = data.CourtyardID(j); % 目标地块所属的院落ID
            target_orientation = data.Orientation{j};
            target_orientation_value = orientation_values(target_orientation); % 目标地块的采光评分
            
            % 目标地块的采光不能比现居地块差
            if target_orientation_value <= current_orientation_value
                % 添加符合条件的目标地块
                possible_targets = [possible_targets; j];
            end
        end
    end
    %比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
    % 存储每个居民的搬迁目标地块信息
    for k = 1:length(possible_targets)
        target_idx = possible_targets(k);
        target_courtyard_id = data.CourtyardID(target_idx); % 目标地块所属的院落ID
        compensation_table = [compensation_table; {data.PlotID(resident_idx), data.PlotID(target_idx), data.PlotArea(resident_idx), ...
            data.PlotArea(target_idx), data.Orientation{resident_idx}, data.Orientation{target_idx}, ...
            current_is_streetside, ismember(data.PlotID(target_idx), streetside_plots), current_courtyard_id, target_courtyard_id}];
    end
end


% Step 4: 为表格命名列，替换为中文
compensation_table.Properties.VariableNames = {'居民地块ID', '目标地块ID', '居民地块面积', '目标地块面积', ...
    '居民地块朝向', '目标地块朝向', '居民地块是否临街', '目标地块是否临街', '居民地块所属院落ID', '目标地块所属院落ID'};

% Step 5: 输出结果到Excel文件
writetable(compensation_table, '搬迁补偿方案分析.xlsx');

disp('搬迁补偿方案分析结果已保存至文件 "搬迁补偿方案分析.xlsx"');

