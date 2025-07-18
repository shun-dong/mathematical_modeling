clc;
clear;

% 读取数据
relocation_data = readtable('问题一结果.xlsx');
relocation_data.Properties.VariableNames = {'ResidentPlotID', 'TargetPlotID', 'ResidentPlotArea', 'TargetPlotArea', 'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetFacing', 'TargetIsStreetFacing', 'ResidentCourtyardID', 'TargetCourtyardID', 'Compensation'};

plot_info = readtable('附件一：老城街区地块信息.xlsx');
plot_info.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 创建邻接矩阵，表示院落间的毗邻关系
n_courtyards = 107; % 107个院落
adjacency_matrix = zeros(n_courtyards, n_courtyards);  % 创建一个107x107的矩阵，初始化为0
% 设置毗邻关系（填充邻接矩阵，具体数据根据实际情况）
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
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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

% 填充 63 和 64 毗邻%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
n_residents = 112; % 113个居民，基于 'HasResident' = 1
resident_plots = unique(relocation_data.ResidentPlotID); % 获取所有居民的 ResidentPlotID（113个）

% 初始化搬迁结果
% 初始化搬迁结果
target_plots = NaN(n_residents, 1);  % 每个居民的目标地块
occupied_plots = zeros(n_plots, 1);  % 记录哪些地块已经被占用，防止重复分配

% 创建一个 cell 数组存储每个院落的地块ID
courtyard_plots = cell(n_courtyards, 1);  % 记录每个院落包含的地块ID
for i = 1:n_plots
    courtyard_plots{plot_info.CourtyardID(i)} = [courtyard_plots{plot_info.CourtyardID(i)}, plot_info.PlotID(i)];
end

% 初始化成本和收入
total_cost = 0;  % 总成本初始化为0
total_income = 0;  % 总收入
total_full_courtyards = 0;  % 总腾出院落数
total_full_courtyards_area = 0;  % 总腾出院落面积
communication_cost = 30000 * n_residents;  % 总沟通成本，3万元每户
total_profit = 0;  % 总盈利

% 贪心算法进行搬迁决策
for i = 1:n_residents
    % 获取当前居民的所有可行搬迁方案
    possible_targets = relocation_data.TargetPlotID(relocation_data.ResidentPlotID == resident_plots(i));
    
    best_target = -1;
    max_benefit = -Inf;  % 用于记录最优目标地块的效益
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
        area = plot_info.PlotArea(target_plot_id);  % 获取目标地块面积
        
        % 计算该地块搬迁后的效益
        for k = 1:n_courtyards
            if adjacency_matrix(target_courtyard_id, k) == 1
                benefit = benefit + 1;  % 假设相邻院落腾空的效益加1
            end
        end
        
        % 结合效益和面积来选择最优目标地块
        total_benefit = benefit + area;  % 通过加权提高腾出完整院落的影响，并增加面积作为优先考虑
        if total_benefit > max_benefit
            max_benefit = total_benefit;
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
        
        % 更新成本
        relocation_row = relocation_data(relocation_data.ResidentPlotID == resident_plots(i) & relocation_data.TargetPlotID == best_target, :);
        total_cost = total_cost + relocation_row.Compensation + 30000;  % 加上搬迁补偿和沟通成本
    end
end

% 初始化腾出完整院落列表
full_courtyards_list = [];

% 计算最终腾出的完整院落数量及面积
for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};  % 获取当前院落的所有地块ID
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)  % 检查该院落中是否所有地块都没有居民
        total_full_courtyards = total_full_courtyards + 1;  % 如果是，认为该院落腾空
        total_full_courtyards_area = total_full_courtyards_area + plot_info.CourtyardArea(i);  % 加上该院落的总面积
        full_courtyards_list = [full_courtyards_list, plot_info.CourtyardID(i)];  % 将腾空的院落ID加入列表
    else
        % 计算有居民的院落面积
        vacant_area = 0;
        for j = 1:length(courtyard_plots_ids)
            if plot_info.HasResident(courtyard_plots_ids(j)) == 0
                vacant_area = vacant_area + plot_info.PlotArea(courtyard_plots_ids(j));  % 计算未居住地块的面积
            end
        end
        total_full_courtyards_area = total_full_courtyards_area + vacant_area;  % 加上该院落未居住地块的面积
    end
end

% 计算最终的收入
for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};  % 获取当前院落的所有地块ID
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)  % 无人居住的院落
        total_income = total_income + plot_info.CourtyardArea(i) * 30;  % 按照 30 元/平米/天出租
    else
        for j = 1:length(courtyard_plots_ids)
            if plot_info.HasResident(courtyard_plots_ids(j)) == 0  % 无人居住的地块
                if strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '东') || strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '西')
                    total_income = total_income + plot_info.PlotArea(courtyard_plots_ids(j)) * 8;  % 东西厢房
                elseif strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '南') || strcmp(plot_info.Orientation(courtyard_plots_ids(j)), '北')
                    total_income = total_income + plot_info.PlotArea(courtyard_plots_ids(j)) * 15;  % 南北厢房
                end
            end
        end
    end
end

% 计算盈利（扣除搬迁成本和沟通成本）
total_profit = total_income * 10 - total_cost;  % 十年的总收入减去总成本

% 输出结果
disp(['总成本：', num2str(total_cost(1))]);  % 输出total_cost
disp(['总收入：', num2str(total_income * 10)]);  % 计算十年收入
disp(['总盈利：', num2str(total_profit(1))]);  % 输出总盈利
disp(['腾出完整院落的数量：', num2str(total_full_courtyards)]);
disp(['腾出完整院落的总面积：', num2str(total_full_courtyards_area)]);

% 输出搬迁结果
disp('搬迁结果：');
disp('居民地块ID    目标地块ID');
for i = 1:n_residents
    fprintf('居民 %d 的地块ID: %d -> 目标地块ID: %d\n', ...
        i, resident_plots(i), target_plots(i));
end

% 输出腾出的完整院落ID
disp('腾出的完整院落ID:');
disp(full_courtyards_list);