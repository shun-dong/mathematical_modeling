% Step 1: 读取数据
plot_info = readtable('附件一：老城街区地块信息.xlsx');
plot_info.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% Step 2: 获取地块总数
n_plots = height(plot_info);  % 获取地块的总数量（即plot_info中的行数）
n_courtyards = max(plot_info.CourtyardID);  % 获取院落的总数量

% Step 3: 创建一个 cell 数组存储每个院落的地块ID
courtyard_plots = cell(n_courtyards, 1);  % 记录每个院落包含的地块ID
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 填充 courtyard_plots，按照 CourtyardID 将 PlotID 分组
for i = 1:n_plots
    courtyard_plots{plot_info.CourtyardID(i)} = [courtyard_plots{plot_info.CourtyardID(i)}, plot_info.PlotID(i)];
end

% Step 4: 计算搬家之前的完整院落数量
total_empty_courtyards_before = 0;  % 记录搬家之前腾出的完整院落总数

for i = 1:n_courtyards
    courtyard_plots_ids = courtyard_plots{i};  % 获取当前院落的所有地块ID
    if all(plot_info.HasResident(courtyard_plots_ids) == 0)  % 检查该院落中是否所有地块都没有居民
        total_empty_courtyards_before = total_empty_courtyards_before + 1;  % 如果是，认为该院落腾空%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
    end
end

% Step 5: 输出搬家之前的完整院落数量
disp(['搬家之前腾出的完整院落数量: ', num2str(total_empty_courtyards_before)]);
