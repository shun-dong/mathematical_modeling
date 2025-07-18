clc;
clear;
resident_ids_to_delete = [3, 5, 7, 9, 14, 18, 29, 30, 31, 34, 38, 39, 40, 41, 49, 50, 74, 75, 76, 77, ...
                          80, 81, 91, 92, 93, 106, 107, 110, 111, 120, 121, 132, 138, 139, 140, 141, 142, ...
                          171, 172, 179, 180, 181, 182, 191, 192, 193, 194, 195, 196, 197, 198, 200, 203, ...
                          204, 206, 207, 210, 211, 215, 220, 224, 225, 235, 238, 239, 240, 241, 242, 243, ...
                          244, 245, 266, 267, 268, 296, 297, 317, 318, 319, 320, 321, 327, 349, 350, 351, ...
                          352, 376, 380, 381, 384, 385, 390, 393, 401, 403, 409, 424, 433, 451, 452, 453, ...
                          454, 455, 459, 461, 462, 468, 469, 475, 477, 478];  % List of ResidentPlotID to remove
% 初始化结果矩阵
results = []; % 存储每个i对应的性价比m
for i = 1:length(resident_ids_to_delete)
relocation_data = readtable('问题一结果.xlsx');
relocation_data.Properties.VariableNames = {'ResidentPlotID', 'TargetPlotID', 'ResidentPlotArea', 'TargetPlotArea', 'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetFacing', 'TargetIsStreetFacing', 'ResidentCourtyardID', 'TargetCourtyardID', 'Compensation'};

plot_info = readtable('附件一：老城街区地块信息.xlsx');
plot_info.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% Step 2: 删除 ResidentPlotID = 3 的行
relocation_data = relocation_data(relocation_data.ResidentPlotID ~= resident_ids_to_delete(i), :);  % 删除 ResidentPlotID 为 3 的行

% 获取新的居民数据
n_residents = height(relocation_data); % 更新居民数量
% Step 2: 创建邻接矩阵，表示院落间的毗邻关系
n_courtyards = 107; % 107个院落
adjacency_matrix = zeros(n_courtyards, n_courtyards);  % 创建一个107x107的矩阵，初始化为0


% 设置毗邻关系（填充邻接矩阵）
adjacency_matrix(11, 12) = 1;
adjacency_matrix(12, 11) = 1;
adjacency_matrix(13, 15) = 1;
adjacency_matrix(15, 13) = 1;
adjacency_matrix(17, 18) = 1;
adjacency_matrix(18, 17) = 1;
adjacency_matrix(19, 17) = 1;
adjacency_matrix(17, 19) = 1;

adjacency_matrix(7, 107) = 1;
adjacency_matrix(107, 7) = 1;
adjacency_matrix(5, 107) = 1;
adjacency_matrix(107, 5) = 1;
adjacency_matrix(20, 21) = 1;
adjacency_matrix(21, 20) = 1;
adjacency_matrix(22, 23) = 1;
adjacency_matrix(23, 22) = 1;
adjacency_matrix(24, 25) = 1;
adjacency_matrix(25, 24) = 1;

% 填充 26 - 37 均毗邻
for i = 26:36
    for j = i+1:37
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 38 - 51 均毗邻
for i = 38:50
    for j = i+1:51
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 52, 53, 54 毗邻
adjacency_matrix(52, 53) = 1;
adjacency_matrix(53, 52) = 1;
adjacency_matrix(53, 54) = 1;
adjacency_matrix(54, 53) = 1;

% 填充 56 和 57 毗邻
adjacency_matrix(56, 57) = 1;
adjacency_matrix(57, 56) = 1;

% 填充 58, 59, 60, 61, 62 毗邻
adjacency_matrix(58, 59) = 1;
adjacency_matrix(59, 58) = 1;
adjacency_matrix(59, 60) = 1;
adjacency_matrix(60, 59) = 1;
adjacency_matrix(60, 61) = 1;
adjacency_matrix(61, 60) = 1;
adjacency_matrix(61, 62) = 1;
adjacency_matrix(62, 61) = 1;

% 填充 63 和 64 毗邻
adjacency_matrix(63, 64) = 1;
adjacency_matrix(64, 63) = 1;

% 填充 66 - 70 毗邻
for i = 66:69
    for j = i+1:70
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 71, 72, 74 毗邻
adjacency_matrix(71, 72) = 1;
adjacency_matrix(72, 71) = 1;
adjacency_matrix(72, 74) = 1;
adjacency_matrix(74, 72) = 1;

% 填充 75 和 76 毗邻
adjacency_matrix(75, 76) = 1;
adjacency_matrix(76, 75) = 1;

% 填充 77 和 78 毗邻
adjacency_matrix(77, 78) = 1;
adjacency_matrix(78, 77) = 1;

% 填充 81, 82, 83 毗邻
adjacency_matrix(81, 82) = 1;
adjacency_matrix(82, 81) = 1;
adjacency_matrix(82, 83) = 1;
adjacency_matrix(83, 82) = 1;

% 填充 85 - 91 毗邻
for i = 85:90
    for j = i+1:91
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 98 - 104 毗邻
for i = 98:103
    for j = i+1:104
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 92 - 95 毗邻
for i = 92:94
    for j = i+1:95
        adjacency_matrix(i, j) = 1;
        adjacency_matrix(j, i) = 1;
    end
end

% 填充 96 和 97 毗邻
adjacency_matrix(96, 97) = 1;
adjacency_matrix(97, 96) = 1;

% 获取地块总数
n_plots = height(plot_info);  % 获取地块的总数量（即plot_info中的行数）

% 获取每个居民的可行搬迁方案
n_residents = 111; % 113个居民，基于 'HasResident' = 1
resident_plots = unique(relocation_data.ResidentPlotID); % 获取所有居民的 ResidentPlotID（113个）

% 初始化搬迁结果
target_plots = NaN(n_residents, 1);  % 每个居民的目标地块
occupied_plots = zeros(n_plots, 1);  % 记录哪些地块已经被占用，防止重复分配

% 创建一个 cell 数组存储每个院落的地块ID
courtyard_plots = cell(n_courtyards, 1);  % 记录每个院落包含的地块ID
for i = 1:n_plots
    courtyard_plots{plot_info.CourtyardID(i)} = [courtyard_plots{plot_info.CourtyardID(i)}, plot_info.PlotID(i)];
end

% 贪心算法进行搬迁决策
for i = 1:n_residents
    % 获取当前居民的所有可行搬迁方案
    possible_targets = relocation_data.TargetPlotID(relocation_data.ResidentPlotID == resident_plots(i));
    
    best_target = -1;
    max_benefit = -Inf;  % 用于记录最优目标地块的效益
    max_full_courtyards = -Inf;  % 用于记录最多能腾出的完整院落数量
    best_area = 0;  % 用于记录最大腾空面积
    
    for j = 1:length(possible_targets)
        target_plot_id = possible_targets(j);
        
        % 跳过 NaN 的目标地块
        if isnan(target_plot_id)
            continue;  % 如果目标地块是NaN，跳过
        end
        
        % 确保该目标地块是有效的（它是一个有效的地块ID）
        if target_plot_id < 1 || target_plot_id > n_plots
            continue;  % 如果目标地块ID无效，则跳过
        end
        
        % 确保该目标地块还未被占用
        if occupied_plots(target_plot_id) == 1
            continue;  % 如果该地块已被占用，跳过
        end
        
        % 计算该目标地块的效益（考虑邻近性、腾出院落的效益等）
        target_courtyard_id = plot_info.CourtyardID(target_plot_id);
        benefit = 0;
        full_courtyards = 0;  % 记录能腾出的完整院落数量
        area = plot_info.PlotArea(target_plot_id);  % 获取目标地块面积
        
        % 计算该地块搬迁后的效益
        for k = 1:n_courtyards
            if adjacency_matrix(target_courtyard_id, k) == 1
                benefit = benefit + 1;  % 假设相邻院落腾空的效益加1
                
                % 计算是否能腾出完整院落
                if all(occupied_plots(courtyard_plots{k}) == 0)
                    full_courtyards = full_courtyards + 1;  % 如果该院落完全腾空，则增加一个完整院落
                end
            end
        end
        
        % 结合效益、腾出完整院落的数量和总面积来选择最优目标地块
        total_benefit = benefit + full_courtyards * 10 + area;  % 通过加权提高腾出完整院落的影响，并增加面积作为优先考虑
        if total_benefit > max_benefit
            max_benefit = total_benefit;
            max_full_courtyards = full_courtyards;
            best_target = target_plot_id;
            best_area = area;  % 更新最佳目标地块的面积
        end
    end
    
    % 将居民迁移到最优目标地块
    if best_target ~= -1
        target_plots(i) = best_target;
        occupied_plots(best_target) = 1;  % 标记该地块为已占用
        % 更新搬迁后的HasResident状态
        plot_info.HasResident(plot_info.PlotID == resident_plots(i)) = 0;  % 原地块HasResident变为0
        plot_info.HasResident(plot_info.PlotID == best_target) = 1;  % 目标地块HasResident变为1
    end
end

% 计算最终腾出的完整院落数量
total_full_courtyards = 0;  % 记录最终腾出的完整院落总数
full_courtyards_list = [];  % 存储腾出的完整院落编号

for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};  % 获取当前院落的所有地块ID
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)  % 检查该院落中是否所有地块都没有居民
        total_full_courtyards = total_full_courtyards + 1;  % 如果是，认为该院落腾空
        full_courtyards_list = [full_courtyards_list, i];  % 将腾空的院落编号加入列表
    end
end





% 计算投资成本：根据每一条搬迁记录查找 Compensation
total_cost = 0;  % 初始化总成本

% 遍历所有居民的搬迁记录，查找对应的 Compensation
for i = 1:n_residents
    % 获取居民的 ResidentPlotID 和 TargetPlotID
    resident_id = resident_plots(i);
    target_id = target_plots(i);
    
    % 在问题一结果数据中查找对应的搬迁记录
    relocation_row = relocation_data(relocation_data.ResidentPlotID == resident_id & relocation_data.TargetPlotID == target_id, :);
    
    % 获取对应的 Compensation（搬迁补偿）
    if ~isempty(relocation_row)
        total_cost = total_cost + relocation_row.Compensation;  % 将每个搬迁的补偿金额累加
    end
end

% 计算沟通成本
communication_cost = 30000 * n_residents;  % 沟通成本：每户3万元

% 计算总投资成本
total_cost = total_cost + communication_cost;  % 总成本 = 搬迁补偿 + 沟通成本



% 计算收入：租金收益（以10年为基础，10 * 365天）
total_income = 0;  % 初始化收入
days_in_10_years = 10 * 365;  % 10年共3650天

for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};  % 获取当前院落的所有地块ID
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)  % 无人居住的院落
        total_income = total_income + plot_info.CourtyardArea(i) * 30 * days_in_10_years;  % 按照 30 元/平米/天出租
    else
        for j = 1:length(courtyard_plots_ids)
            if plot_info.HasResident(courtyard_plots_ids(j)) == 0  % 无人居住的地块
                if strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '东') || strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '西')
                    total_income = total_income + plot_info.PlotArea(courtyard_plots_ids(j)) * 8 * days_in_10_years;  % 东西厢房
                elseif strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '南') || strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '北')
                    total_income = total_income + plot_info.PlotArea(courtyard_plots_ids(j)) * 15 * days_in_10_years;  % 南北厢房
                end
            end
        end
    end
end

% 计算毗邻效益：空置整院毗邻增加20%的收益
for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)
        for j = 1:n_courtyards
            if adjacency_matrix(i, j) == 1 && all(plot_info.HasResident(courtyard_plots{j}) == 0)
                total_income = total_income + plot_info.CourtyardArea(i) * 30 * 0.2 * days_in_10_years;  % 增加毗邻效益
            end
        end
    end
end

% 计算时间损失（四个月的租金损失），考虑毗邻效益
time_loss_income = 0;  % 时间损失的收入损失
time_loss_income_with_neighbour = 0;  % 考虑毗邻效益后的时间损失

% 由于院落数量为107，因此确保i和j都不会超过107
for i = 1:n_courtyards
    % 确保i不会超出最大索引107
    if i > n_courtyards
        continue;
    end
    
    % 检查是否有居民
    if all(plot_info.HasResident(courtyard_plots{i}) == 1)  % 如果该院落有居民，则跳过
        continue;
    end
    
    % 获取地块的朝向
    for j = 1:length(courtyard_plots{i})
        plot_index = courtyard_plots{i}(j);  % 当前地块的索引
        
        % 获取地块的朝向和面积
        plot_orientation = plot_info.Orientation{plot_index};
        plot_area = plot_info.PlotArea(plot_index);
        
        % 计算时间损失
        if strcmp(plot_orientation, '东') || strcmp(plot_orientation, '西')
            time_loss_per_unit = 8;  % 东西厢房屋的租金是 8 元/平米/天
        elseif strcmp(plot_orientation, '南') || strcmp(plot_orientation, '北')
            time_loss_per_unit = 15;  % 南北厢房屋的租金是 15 元/平米/天
        else
            time_loss_per_unit = 30;  % 完整院落的租金是 30 元/平米/天
        end
        
        % 基础时间损失
        time_loss_income = time_loss_income + plot_area * time_loss_per_unit * 120;  % 120天的租金损失

        % 检查毗邻效益
        for k = 1:n_courtyards
            % 检查毗邻关系（确保k也在有效范围内）
            if k > n_courtyards
                continue;
            end
            if adjacency_matrix(i, k) == 1 && all(plot_info.HasResident(courtyard_plots{k}) == 0)
                % 增加毗邻效益：20%的租金损失
                time_loss_income_with_neighbour = time_loss_income_with_neighbour + plot_area * time_loss_per_unit * 120 * 0.2;
            end
        end
    end
end

% 输出总的时间损失（包括毗邻效益）
total_time_loss_income = time_loss_income + time_loss_income_with_neighbour;


% 计算搬迁后的净租金收益，扣除时间损失（包括毗邻效益）
net_income = total_income - total_time_loss_income;  % 搬迁后的净租金收益

% 不拆迁的十年总收益：3643889900（用于计算增量）
no_relocation_income = 3743889900;  % 不拆迁的收益

% 实际搬迁投入为2000万元
investment_cost = 30000000;  % 2000万

% 计算搬迁后的增量收益（搬迁收益 - 不搬迁的收益）
income_increment = net_income - no_relocation_income;

% 计算性价比 m：增量收益 / 实际搬迁投入
m = income_increment / investment_cost;

 % 保存结果到矩阵
    results = [results; resident_ids_to_delete(i), m];  % 将i和对应的m值存入results矩阵

disp(['搬迁十年的性价比 m（搬迁增量收益 / 实际搬迁投入）：', num2str(m)]);

end

