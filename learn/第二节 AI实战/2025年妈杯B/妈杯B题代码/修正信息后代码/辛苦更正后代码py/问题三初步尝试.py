import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt

# Step 1: 读取地块信息
plot_info = pd.read_excel('附件一：老城街区地块信息.xlsx')
plot_info.columns = ['PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident']

# Step 2: 读取搬迁结果（居民的搬迁信息）
relocation_data = pd.read_excel('问题一结果.xlsx')
relocation_data.columns = ['ResidentPlotID', 'TargetPlotID', 'ResidentPlotArea', 'TargetPlotArea',
                           'ResidentOrientation', 'TargetOrientation', 'ResidentIsStreetFacing', 'TargetIsStreetFacing',
                           'ResidentCourtyardID', 'TargetCourtyardID', 'Compensation']
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
# Step 3: 创建邻接矩阵，表示院落间的毗邻关系
n_courtyards = 107  # 假设共有107个院落
adjacency_matrix = np.zeros((n_courtyards, n_courtyards), dtype=int)  # 邻接矩阵初始化为0

# 创建一个cell数组，存储每个院落的地块ID
courtyard_plots = {i: [] for i in range(1, n_courtyards + 1)}
for i in range(len(plot_info)):
    courtyard_plots[plot_info['CourtyardID'].iloc[i]].append(plot_info['PlotID'].iloc[i])

# 设置毗邻关系（填充邻接矩阵）
# Step 2: 设置毗邻关系（填充邻接矩阵）
adjacency_matrix[10, 11] = 1
adjacency_matrix[11, 10] = 1
adjacency_matrix[12, 14] = 1
adjacency_matrix[14, 12] = 1
adjacency_matrix[16, 17] = 1
adjacency_matrix[17, 16] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
adjacency_matrix[18, 16] = 1
adjacency_matrix[16, 18] = 1

adjacency_matrix[6, 106] = 1
adjacency_matrix[106, 6] = 1
adjacency_matrix[4, 106] = 1
adjacency_matrix[106, 4] = 1
adjacency_matrix[19, 20] = 1
adjacency_matrix[20, 19] = 1
adjacency_matrix[21, 22] = 1
adjacency_matrix[22, 21] = 1
adjacency_matrix[23, 24] = 1
adjacency_matrix[24, 23] = 1

# 填充 26 - 37 均毗邻
for i in range(25, 36):
    for j in range(i + 1, 37):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 38 - 51 均毗邻
for i in range(37, 50):
    for j in range(i + 1, 51):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 52, 53, 54 毗邻
adjacency_matrix[51, 52] = 1
adjacency_matrix[52, 51] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
adjacency_matrix[52, 53] = 1
adjacency_matrix[53, 52] = 1
adjacency_matrix[53, 54] = 1
adjacency_matrix[54, 53] = 1

# 填充 56 和 57 毗邻
adjacency_matrix[55, 56] = 1
adjacency_matrix[56, 55] = 1

# 填充 58, 59, 60, 61, 62 毗邻
for i in range(57, 61):
    for j in range(i + 1, 62):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 63 和 64 毗邻
adjacency_matrix[62, 63] = 1
adjacency_matrix[63, 62] = 1

# 填充 66 - 70 毗邻
for i in range(65, 69):
    for j in range(i + 1, 71):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 71, 72, 74 毗邻
adjacency_matrix[70, 71] = 1
adjacency_matrix[71, 70] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
adjacency_matrix[71, 73] = 1
adjacency_matrix[73, 71] = 1

# 填充 75 和 76 毗邻
adjacency_matrix[74, 75] = 1
adjacency_matrix[75, 74] = 1

# 填充 77 和 78 毗邻
adjacency_matrix[76, 77] = 1
adjacency_matrix[77, 76] = 1

# 填充 81, 82, 83 毗邻
adjacency_matrix[80, 81] = 1
adjacency_matrix[81, 80] = 1
adjacency_matrix[81, 82] = 1
adjacency_matrix[82, 81] = 1
adjacency_matrix[82, 83] = 1
adjacency_matrix[83, 82] = 1

# 填充 85 - 91 毗邻
for i in range(84, 90):
    for j in range(i + 1, 92):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 98 - 104 毗邻
for i in range(97, 103):
    for j in range(i + 1, 105):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 92 - 95 毗邻
for i in range(91, 94):
    for j in range(i + 1, 95):
        adjacency_matrix[i, j] = 1
        adjacency_matrix[j, i] = 1

# 填充 96 和 97 毗邻
adjacency_matrix[95, 96] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
adjacency_matrix[96, 95] = 1


# Step 4: 设定不拆迁的收益（已给出固定值）
total_income_no_migration = 3643889900

# 实际搬迁投入为2000万元
actual_migration_cost = 20000000  # 2000万

# 初始化性价比数组
m_values = np.zeros(112)  # 用于存储每次搬迁后的性价比

# 逐步增加搬迁居民数，进行计算
for num_residents_to_move in range(1, 113):  # 从1个居民开始，到112个居民
    # 选择前num_residents_to_move个居民进行搬迁
    current_relocation_data = relocation_data.iloc[:num_residents_to_move, :]

    # 随机选择每个居民的搬迁方案
    random_residents = current_relocation_data.copy()
    for i in range(num_residents_to_move):
        # 随机选择一个目标地块
        random_target_idx = random.randint(0, len(current_relocation_data) - 1)  # 随机选择一个搬迁目标方案
        random_residents.loc[i, 'TargetPlotID'] = current_relocation_data.iloc[random_target_idx][
            'TargetPlotID']  # 随机选择目标地块

    # 初始化搬迁后的收入
    migrated_income_n = 0

    # 计算搬迁后的租金收入 + 毗邻效益
    for i in range(num_residents_to_move):
        # 获取当前居民的搬迁信息
        relocation_row = random_residents.iloc[i, :]
        target_plot_id = relocation_row['TargetPlotID']

        # 检查 target_plot_id 是否在有效范围内
        if target_plot_id > n_courtyards or target_plot_id < 1:
            print(f'跳过无效的 target_plot_id: {target_plot_id}')
            continue  # 跳过不在有效范围内的目标地块

        # 获取目标地块的面积和朝向
        target_plot_area = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'PlotArea'].iloc[0]
        target_orientation = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'Orientation'].iloc[0]

        # 计算目标地块的租金收入（按朝向判断租金）
        if target_orientation in ['东', '西']:#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
            migrated_income_n += target_plot_area * 8 * 3650  # 10年租金收入
        elif target_orientation in ['南', '北']:
            migrated_income_n += target_plot_area * 15 * 3650  # 10年租金收入
        else:
            migrated_income_n += target_plot_area * 30 * 3650  # 10年租金收入

        # 计算毗邻效益：相邻空院落增加20%的租金收益
        for j in range(n_courtyards):
            if adjacency_matrix[target_plot_id - 1, j] == 1 and \
                    plot_info.loc[plot_info['PlotID'] == j + 1, 'HasResident'].iloc[0] == 0:
                migrated_income_n += target_plot_area * 30 * 0.2 * 3650  # 10年毗邻效益

    # 计算时间损失（4个月的租金损失）
    time_loss_income = 0
    for i in range(num_residents_to_move):
        # 获取搬迁的地块信息
        relocation_row = random_residents.iloc[i, :]
        target_plot_id = relocation_row['TargetPlotID']
        target_plot_area = plot_info.loc[plot_info['PlotID'] == target_plot_id, 'PlotArea'].iloc[0]

        # 假设搬迁为东西厢房，计算四个月的租金损失
        time_loss_income += target_plot_area * 8 * 120  # 120天的租金损失

    # 计算搬迁的总成本：补偿 + 沟通成本 + 时间损失
    total_cost_n = random_residents['Compensation'].sum() + 30000 * num_residents_to_move + time_loss_income  # 总成本

    # 计算性价比
    m_values[num_residents_to_move - 1] = (migrated_income_n - total_income_no_migration) / total_cost_n  # 性价比公式
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 绘制性价比随搬迁居民数变化的趋势
plt.plot(range(1, 113), m_values, marker='o', linestyle='-', linewidth=2)
plt.xlabel('搬迁居民数量')
plt.ylabel('性价比 m')
plt.title('搬迁后性价比 m 随搬迁居民数变化的趋势')
plt.grid(True)
plt.show()
