import pandas as pd
import numpy as np

# Step 1: 读取地块信息
plot_info = pd.read_excel('附件一：老城街区地块信息.xlsx')
plot_info.columns = ['PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident']

# 院落数量#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
n_courtyards = 107
adjacency_matrix = np.zeros((n_courtyards, n_courtyards), dtype=int)  # 初始化邻接矩阵为0

# 创建一个字典，存储每个院落的地块ID
courtyard_plots = {i: [] for i in range(1, n_courtyards + 1)}  # 用1到107作为键

# 填充每个院落的地块ID#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
for i in range(len(plot_info)):
    courtyard_plots[plot_info['CourtyardID'].iloc[i]].append(plot_info['PlotID'].iloc[i])

# Step 2: 设置毗邻关系（填充邻接矩阵）
adjacency_matrix[10, 11] = 1
adjacency_matrix[11, 10] = 1
adjacency_matrix[12, 14] = 1
adjacency_matrix[14, 12] = 1
adjacency_matrix[16, 17] = 1
adjacency_matrix[17, 16] = 1
adjacency_matrix[18, 16] = 1
adjacency_matrix[16, 18] = 1

adjacency_matrix[6, 106] = 1
adjacency_matrix[106, 6] = 1
adjacency_matrix[4, 106] = 1
adjacency_matrix[106, 4] = 1
adjacency_matrix[19, 20] = 1
adjacency_matrix[20, 19] = 1
adjacency_matrix[21, 22] = 1
adjacency_matrix[22, 21] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
adjacency_matrix[52, 51] = 1
adjacency_matrix[52, 53] = 1
adjacency_matrix[53, 52] = 1
adjacency_matrix[53, 54] = 1
adjacency_matrix[54, 53] = 1

# 填充 56 和 57 毗邻
adjacency_matrix[55, 56] = 1#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
adjacency_matrix[71, 70] = 1
adjacency_matrix[71, 73] = 1
adjacency_matrix[73, 71] = 1
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
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
adjacency_matrix[95, 96] = 1
adjacency_matrix[96, 95] = 1


# Step 3: 计算不进行搬迁直接进行十年运行的盈利
total_income_no_migration = 0  # 初始化不搬迁的总收入
days_in_10_years = 10 * 365  # 10年共3650天

# 计算每个地块的收入
for i in range(len(plot_info)):
    if plot_info['HasResident'].iloc[i] == 0:  # 无人居住的地块
        # 对于完全空的地块，租金按 30 元/平米/天计算
        total_income_no_migration += plot_info['PlotArea'].iloc[i] * 30 * days_in_10_years
    else:
        # 对于有居民的地块，计算租金收入
        plot_orientation = plot_info['Orientation'].iloc[i]
        plot_area = plot_info['PlotArea'].iloc[i]

        if plot_orientation in ['东', '西']:
            # 东西厢房屋的租金是 8 元/平米/天
            total_income_no_migration += plot_area * 8 * days_in_10_years
        elif plot_orientation in ['南', '北']:
            # 南北厢房屋的租金是 15 元/平米/天
            total_income_no_migration += plot_area * 15 * days_in_10_years
        else:
            # 如果是完整院落，租金是 30 元/平米/天
            total_income_no_migration += plot_area * 30 * days_in_10_years

# Step 4: 计算毗邻效益：空院落毗邻增加20%的收益
for i in range(1, n_courtyards + 1):  # 确保 i 从 1 开始到 n_courtyards
    # 获取当前院落的所有地块
    courtyard_plots_ids = courtyard_plots[i]

    # 检查该院落是否完全空闲（即所有地块都没有居民）
    if all(plot_info.loc[plot_info['PlotID'].isin(courtyard_plots_ids), 'HasResident'] == 0):  # 如果该院落完全空闲
        for j in range(1, n_courtyards + 1):  # 确保 j 从 1 开始到 n_courtyards
            # 如果当前院落与其他空院落相邻，且不是自己与自己相邻
            if adjacency_matrix[i - 1, j - 1] == 1 and all(
                    plot_info.loc[plot_info['PlotID'].isin(courtyard_plots[j]), 'HasResident'] == 0) and i != j:
                # 增加毗邻效益（20%）
                total_income_no_migration += plot_info.loc[plot_info['CourtyardID'] == i, 'CourtyardArea'].iloc[
                                                 0] * 30 * 0.2 * days_in_10_years

# 输出不搬迁的总收入
print(f"不搬迁的十年总收益：{total_income_no_migration}")

# Step 5: 假设搬迁后的总盈利（从搬迁后的计算结果得出）
migrated_income = 4506529160  # 假设搬迁后的十年收入
total_cost = 22725267.5596  # 假设搬迁的实际投入

# Step 6: 计算性价比 m
m = (migrated_income - total_income_no_migration) / total_cost  # 性价比 = (搬迁后总盈利 - 不搬迁总盈利) / 实际搬迁投入

# 输出性价比
print(f"搬迁后总盈利比于不搬迁的增量 / 实际搬迁投入的性价比 m：{m}")
