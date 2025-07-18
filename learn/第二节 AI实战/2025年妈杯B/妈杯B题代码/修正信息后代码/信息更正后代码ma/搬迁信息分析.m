clc;
clear;
% Step 1: 读取数据，并将列标题转化为英文
data = readtable('附件一：老城街区地块信息.xlsx'); 

% 将表格的列标题更改为英文
data.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% 获取地块的数量
n = height(data); % 获取地块的总数

% 朝向与采光等级的关系：正南 > 正北 > 东 > 西
orientation_values = containers.Map({'南', '北', '东', '西'}, [1, 2, 3, 4]); 

% Step 2: 选择有住户的地块（HasResident = 1）
resident_indices = find(data.HasResident == 1); % 找到所有有住户的地块

% 存储每个居民的所有搬迁目标区域
relocation_targets = cell(n, 1); % 存储每个居民的目标区域ID

for i = 1:length(resident_indices)
    resident_idx = resident_indices(i); % 当前有住户地块的索引
    
    % 获取当前居民地块的面积和采光
    current_area = data.PlotArea(resident_idx);
    current_orientation = data.Orientation{resident_idx};
    current_orientation_value = orientation_values(current_orientation);
    
    % 找到满足条件的目标地块
    possible_targets = []; % 存储符合条件的目标地块索引
    for j = 1:n
        if data.HasResident(j) == 0 && data.PlotArea(j) > current_area
            % 目标地块的面积必须大于现有地块面积，且目标地块没有住户
            target_orientation = data.Orientation{j};
            target_orientation_value = orientation_values(target_orientation);
            if target_orientation_value >= current_orientation_value
                % 目标地块的采光可以与现地块相同或更好
                possible_targets = [possible_targets; j]; % 添加符合条件的目标地块
            end
        end
    end
    
    % 存储每个居民可以选择的所有目标地块
    relocation_targets{resident_idx} = possible_targets;
end

% Step 3: 输出每个居民的所有搬迁目标区域
disp('每个居民的所有搬迁目标区域:');
for i = 1:n
    if ~isempty(relocation_targets{i})
        fprintf('居民所在地块ID %d 可以搬迁到以下目标地块IDs: ', data.PlotID(i));
        disp(data.PlotID(relocation_targets{i})');
    else
        fprintf('居民所在地块ID %d 没有合适的搬迁目标区域\n', data.PlotID(i));
    end
end

