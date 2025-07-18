% Step 1: 读取数据，并将列标题转化为英文
data = readtable('附件一：老城街区地块信息.xlsx');

% 将表格的列标题更改为英文
data.Properties.VariableNames = {'PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident'};

% Step 2: 定义补偿参数
max_area_increase = 0.30; % 最大面积补偿比例为30%
compensation_budget = 200000; % 每位居民的修缮预算上限为20万元
% 为了简化，给每个方位赋予一个数字值，方便计算采光补偿
orientation_values = containers.Map({'南', '北', '东', '西'}, [1, 2, 3, 4]); % 为方位定义数值

% Step 3: 定义地块之间的毗邻关系
% Step 3: 定义地块之间的毗邻关系
adjacency = containers.Map( ...
    {11, 13, 17, 7, 5, 20, 22, 26, 38, 52, 56, 58, 63, 66, 71, 75, 77, 81, 85, 98, 92, 96}, ...
    { [12], [15], [18], [107], [107], [21], [23], [37], [51], [53], [57], [59], [64], [70], [72], [76], [78], [82, 83], [91], [104], [95], [97] });


% Step 4: 循环遍历每个地块，计算每户居民的补偿
n = height(data); % 地块的总数
compensations = zeros(n, 3); % 初始化一个矩阵，用于存储面积、采光和修缮的补偿

for i = 1:n
    % Step 4.1: 面积补偿
    current_area = data.PlotArea(i); % 当前地块的面积
    max_area = current_area * (1 + max_area_increase); % 允许的最大面积（当前面积 + 30%）
    compensations(i, 1) = max_area - current_area; % 面积补偿为最大面积减去当前面积

    % Step 4.2: 采光补偿
    orientation = data.Orientation{i}; % 获取当前地块的方位
    original_orientation_value = orientation_values(orientation); % 获取当前地块方位的数值
    
    % 假设新的地块采光情况与原地块相同，这里是简化的采光补偿逻辑
    new_orientation_value = original_orientation_value; % 默认假设新地块采光值不低于原地块
    compensations(i, 2) = max(0, original_orientation_value - new_orientation_value); % 确保新的采光不低于原地块

    % Step 4.3: 修缮补偿
    if compensations(i, 1) > 0 || compensations(i, 2) > 0
        % 如果面积或采光补偿有变化，假设修缮费用与补偿成正比
        repair_cost = compensations(i, 1) * 500 + compensations(i, 2) * 200; % 简化的修缮费用模型
        repair_cost = min(repair_cost, compensation_budget); % 修缮费用不能超过预算上限
        compensations(i, 3) = repair_cost; % 存储修缮费用
    end
end

% Step 5: 定义优化模型，最大化腾出的空地块的面积
% 我们将创建一个决策变量x，表示是否搬迁某一住户，1表示搬迁，0表示不搬迁
x = optimvar('x', n, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

% 定义目标函数：最大化腾出的空地块的总面积
objective = sum(x .* data.PlotArea); % 目标是搬迁后腾出的地块面积总和

% Step 6: 定义约束条件，确保相邻的地块搬迁一起
% Step 6: 定义约束条件，确保相邻的地块搬迁一起
constraints = [];
for i = 1:n
    if isKey(adjacency, i)  % 只有当地块 i 在邻接关系中时，才检查其毗邻关系
        adj_blocks = adjacency(i);  % 获取地块 i 的毗邻地块
        for j = adj_blocks
            if j > i  % 只检查一次，避免重复
                % 添加约束，确保 i 和 j 一起搬迁
                constraints = [constraints, x(i) == x(j)];
            end
        end
    end
end

% Step 7: 求解优化问题
% 创建优化问题
problem = optimproblem('Objective', objective); 

% 将约束添加到优化问题中
problem.Constraints = constraints; 

% 求解优化问题，获取最优解
[sol, fval] = solve(problem); % 获取最优解和最优目标值

% 显示结果
fprintf('腾出的空地块总面积: %f\n', fval); % 打印最终腾出的空地块总面积
disp('最终的搬迁计划:');
disp(sol.x); % 显示每个居民的搬迁决策（0为不搬迁，1为搬迁）
