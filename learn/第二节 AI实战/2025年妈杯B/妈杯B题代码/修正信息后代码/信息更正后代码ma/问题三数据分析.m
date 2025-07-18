clc;
clear;

% 读取附件一：老城街区地块信息
plot_info = readtable('附件一：老城街区地块信息.xlsx');
plot_info.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

n_courtyards = 107;  % 假设共有107个院落
adjacency_matrix = zeros(n_courtyards, n_courtyards);  % 邻接矩阵初始化为0

% 创建一个cell数组，存储每个院落的地块ID
courtyard_plots = cell(n_courtyards, 1);
for i = 1:height(plot_info)
    courtyard_plots{plot_info.CourtyardID(i)} = [courtyard_plots{plot_info.CourtyardID(i)}, plot_info.PlotID(i)];
end%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
    for j = i+1:51%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da

% 计算不进行拆迁直接进行十年运行的盈利
total_income_no_migration = 0;  % 初始化不拆迁的总收入
days_in_10_years = 10 * 365;  % 10年共3650天

% 计算每个地块的收入
for i = 1:height(plot_info)
    if plot_info.HasResident(i) == 0  % 无人居住的地块
        % 对于完全空的地块，租金按 30 元/平米/天计算
        total_income_no_migration = total_income_no_migration + plot_info.PlotArea(i) * 30 * days_in_10_years;
    else
        % 对于有居民的地块，计算租金收入
        plot_orientation = plot_info.Orientation{i};
        plot_area = plot_info.PlotArea(i);
        
        if strcmp(plot_orientation, '东') || strcmp(plot_orientation, '西')
            % 东西厢房屋的租金是 8 元/平米/天
            total_income_no_migration = total_income_no_migration + plot_area * 8 * days_in_10_years;
        elseif strcmp(plot_orientation, '南') || strcmp(plot_orientation, '北')
            % 南北厢房屋的租金是 15 元/平米/天
            total_income_no_migration = total_income_no_migration + plot_area * 15 * days_in_10_years;
        else
            % 如果是完整院落，租金是 30 元/平米/天
            total_income_no_migration = total_income_no_migration + plot_area * 30 * days_in_10_years;
        end
    end
end

% 计算毗邻效益：空院落毗邻增加20%的收益
for i = 1:n_courtyards
    % 如果该院落为空院落（无人居住）
    if all(plot_info.HasResident(courtyard_plots{i}) == 0)
        % 遍历其他院落
        for j = 1:n_courtyards
            % 如果当前院落与其他空院落相邻，且不是自己与自己相邻
            if adjacency_matrix(i, j) == 1 && all(plot_info.HasResident(courtyard_plots{j}) == 0) && i ~= j
                % 增加毗邻效益（20%）
                total_income_no_migration = total_income_no_migration + plot_info.CourtyardArea(i) * 30 * 0.2 * days_in_10_years;
            end
        end
    end
end

% 输出不拆迁的总收入
disp(['不拆迁的十年总收益：', num2str(total_income_no_migration)]);

% 假设你提供了搬迁后的总盈利：
migrated_income = 4506529160;  % 假设搬迁后的十年收入（从搬迁后的计算结果得出）
total_cost = 13725267.5596;  % 假设搬迁的实际投入（从搬迁后的计算结果得出）

% 计算性价比 m
m = (migrated_income - total_income_no_migration) / total_cost;  % 性价比 m = (搬迁后总盈利 - 不搬迁总盈利) / 实际搬迁投入%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da

% 输出性价比
disp(['搬迁后总盈利比于不搬迁的增量 / 实际搬迁投入的性价比 m：', num2str(m)]);