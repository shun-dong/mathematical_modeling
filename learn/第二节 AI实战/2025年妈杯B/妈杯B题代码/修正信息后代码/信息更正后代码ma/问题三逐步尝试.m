clc;
clear;
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 读取附件一：老城街区地块信息
plot_info = readtable('附件一：老城街区地块信息.xlsx');
plot_info.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% 读取搬迁结果（居民的搬迁信息）
relocation_data = readtable('问题一结果.xlsx');
relocation_data.Properties.VariableNames = {'ResidentPlotID', 'TargetPlotID', 'ResidentPlotArea', 'TargetPlotArea', 'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetFacing', 'TargetIsStreetFacing', 'ResidentCourtyardID', 'TargetCourtyardID', 'Compensation'};

% Step 2: 创建邻接矩阵，表示院落间的毗邻关系
n_courtyards = 107;  % 假设共有107个院落
adjacency_matrix = zeros(n_courtyards, n_courtyards);  % 邻接矩阵初始化为0

% 创建一个cell数组，存储每个院落的地块ID
courtyard_plots = cell(n_courtyards, 1);
for i = 1:height(plot_info)
    courtyard_plots{plot_info.CourtyardID(i)} = [courtyard_plots{plot_info.CourtyardID(i)}, plot_info.PlotID(i)];
end
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
adjacency_matrix(107, 5) = 1;%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
adjacency_matrix(63, 64) = 1;%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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



% 设定不拆迁的收益（已给出固定值）
total_income_no_migration = 3643889900;

% 实际搬迁投入为2000万元
actual_migration_cost = 20000000;  % 2000万

% 初始化性价比数组
m_values = zeros(112, 1);  % 用于存储每次搬迁后的性价比

% 逐步增加搬迁居民数，进行计算
for num_residents_to_move = 1:112  % 从1个居民开始，到112个居民
    % 选择前num_residents_to_move个居民进行搬迁
    current_relocation_data = relocation_data(1:num_residents_to_move, :);
    
    % 随机选择每个居民的搬迁方案
    random_residents = current_relocation_data;
    for i = 1:num_residents_to_move
        % 随机选择一个目标地块
        random_target_idx = randi(height(current_relocation_data));  % 随机选择一个搬迁目标方案
        random_residents.TargetPlotID(i) = current_relocation_data.TargetPlotID(random_target_idx);  % 随机选择目标地块
    end
    
    % 初始化搬迁后的收入
    migrated_income_n = 0;
    
    % 计算搬迁后的租金收入 + 毗邻效益
    for i = 1:num_residents_to_move
        % 获取当前居民的搬迁信息
        relocation_row = random_residents(i, :);
        target_plot_id = relocation_row.TargetPlotID;
        
        % 检查 target_plot_id 是否在有效范围内
        if target_plot_id > n_courtyards || target_plot_id < 1
            disp(['跳过无效的 target_plot_id: ', num2str(target_plot_id)]);
            continue;  % 跳过不在有效范围内的目标地块
        end
        
        % 获取目标地块的面积和朝向
        target_plot_area = plot_info.PlotArea(target_plot_id);
        target_orientation = plot_info.Orientation{target_plot_id};
        
        % 计算目标地块的租金收入（按朝向判断租金）
        if strcmp(target_orientation, '东') || strcmp(target_orientation, '西')
            migrated_income_n = migrated_income_n + target_plot_area * 8 * 3650;  % 10年租金收入
        elseif strcmp(target_orientation, '南') || strcmp(target_orientation, '北')
            migrated_income_n = migrated_income_n + target_plot_area * 15 * 3650;  % 10年租金收入
        else
            migrated_income_n = migrated_income_n + target_plot_area * 30 * 3650;  % 10年租金收入
        end
        
        % 计算毗邻效益：相邻空院落增加20%的租金收益
        for j = 1:n_courtyards
            if adjacency_matrix(target_plot_id, j) == 1 && plot_info.HasResident(j) == 0
                migrated_income_n = migrated_income_n + target_plot_area * 30 * 0.2 * 3650;  % 10年毗邻效益
            end
        end
    end

    % 计算时间损失（4个月的租金损失）
    time_loss_income = 0;
    for i = 1:num_residents_to_move
        % 获取搬迁的地块信息
        relocation_row = random_residents(i, :);
        target_plot_id = relocation_row.TargetPlotID;
        target_plot_area = plot_info.PlotArea(target_plot_id);
        
        % 假设搬迁为东西厢房，计算四个月的租金损失
        time_loss_income = time_loss_income + target_plot_area * 8 * 120;  % 120天的租金损失
    end
    
    % 计算搬迁的总成本：补偿 + 沟通成本 + 时间损失
    total_cost_n = sum(random_residents.Compensation) + 30000 * num_residents_to_move + time_loss_income;  % 总成本
    
    % 计算性价比
    m_values(num_residents_to_move) = (migrated_income_n - total_income_no_migration) / total_cost_n;  % 性价比公式
end

% 绘制性价比随搬迁居民数变化的趋势
figure;
plot(1:112, m_values, '-o', 'LineWidth', 2);
xlabel('搬迁居民数量');
ylabel('性价比 m');
title('搬迁后性价比 m 随搬迁居民数变化的趋势');
grid on;
