

% 创建邻接矩阵
num_yards = length(yard_ids);
edges = []; % 初始化边列表为空
%比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
% 填充邻接矩阵（边列表）
for i = 1:length(adjacency_list)
    pair = adjacency_list{i};
    for j = 1:length(pair)
        for k = j+1:length(pair)
            % 确保每次添加的边是标量的形式，避免维度不一致
            idx1 = find(yard_ids == pair(j), 1);  % 使用 '1' 限制只找到第一个匹配项
            idx2 = find(yard_ids == pair(k), 1);  % 使用 '1' 限制只找到第一个匹配项
            % 检查idx1和idx2是否有效（即是否找到匹配项）
            if ~isempty(idx1) && ~isempty(idx2)
                % 添加边到边列表
                edges = [edges; idx1, idx2];  % 追加边
            end
        end
    end
end

% 创建图（使用边列表）
G = graph(edges(:,1), edges(:,2), [], numel(yard_ids));

% 可视化邻接关系
figure;
h = plot(G, 'NodeLabel', yard_ids);

% 将临街房屋编号转换为图中节点索引
street_house_indices = find(ismember(yard_ids, street_houses));

% 标记临街房屋
highlight(h, street_house_indices, 'NodeColor', 'r', 'MarkerSize', 6);

% 设置标题与标签
title('院落邻接关系图');
xlabel('院落编号');
ylabel('邻接关系');

% 备注说明
legend('临街房屋', 'Location', 'best');

