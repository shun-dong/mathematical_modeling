import pandas as pd
import numpy as np

# Step 1: 读取数据，并将列标题转化为英文
data = pd.read_excel('附件一：老城街区地块信息.xlsx')

# Step 1.1: 检查数据的列名，查看实际列标题
print('实际列名:')
print(data.columns)  # 输出列名，确认实际的列标题

# Step 2: 将列标题更改为英文
data.columns = ['PlotID', 'CourtyardID', 'PlotArea', 'CourtyardArea', 'Orientation', 'HasResident']
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
# 获取地块的数量
n = len(data)  # 获取地块的总数

# 临街房屋编号
streetside_plots = [3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26,
                    28, 29, 30, 31, 32, 33, 38, 39, 40, 52, 53, 61, 62, 65, 81, 83, 78, 77, 76, 98]

# 朝向与采光等级的关系：正南=正北 > 东厢 > 西厢
orientation_values = {'南': 1, '北': 1, '东': 2, '西': 3}

# Step 3: 选择有住户的地块（HasResident = 1）
resident_indices = data[data['HasResident'] == 1].index.tolist()  # 找到所有有住户的地块

# Step 4: 计算每个居民的目标区域及其评分
compensation_data = []  # 用于存储最终的补偿结果

for resident_idx in resident_indices:
    # 获取当前居民地块的面积和采光
    current_area = data.loc[resident_idx, 'PlotArea']
    current_orientation = data.loc[resident_idx, 'Orientation']#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
    current_orientation_value = orientation_values[current_orientation]
    current_is_streetside = data.loc[resident_idx, 'PlotID'] in streetside_plots  # 临街判断
    current_courtyard_id = data.loc[resident_idx, 'CourtyardID']  # 当前居民地块所属的院落ID

    # 找到满足条件的目标地块
    possible_targets = []  # 存储符合条件的目标地块索引

    for target_idx in range(n):
        if data.loc[target_idx, 'HasResident'] == 0 and data.loc[target_idx, 'PlotArea'] > current_area:
            # 目标地块的面积必须大于现有地块面积，且目标地块没有住户
            target_is_streetside = data.loc[target_idx, 'PlotID'] in streetside_plots  # 临街判断
            target_courtyard_id = data.loc[target_idx, 'CourtyardID']  # 目标地块所属的院落ID
            target_orientation = data.loc[target_idx, 'Orientation']
            target_orientation_value = orientation_values[target_orientation]  # 目标地块的采光评分

            # 目标地块的采光不能比现居地块差
            if target_orientation_value <= current_orientation_value:
                # 添加符合条件的目标地块
                possible_targets.append(target_idx)

    # 存储每个居民的搬迁目标地块信息
    for target_idx in possible_targets:
        target_courtyard_id = data.loc[target_idx, 'CourtyardID']  # 目标地块所属的院落ID
        compensation_data.append([data.loc[resident_idx, 'PlotID'], data.loc[target_idx, 'PlotID'],
                                  data.loc[resident_idx, 'PlotArea'], data.loc[target_idx, 'PlotArea'],
                                  data.loc[resident_idx, 'Orientation'], data.loc[target_idx, 'Orientation'],#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
                                  current_is_streetside, target_is_streetside, current_courtyard_id,
                                  target_courtyard_id])

# Step 5: 将结果存储为 DataFrame
compensation_df = pd.DataFrame(compensation_data, columns=['居民地块ID', '目标地块ID', '居民地块面积', '目标地块面积',
                                                           '居民地块朝向', '目标地块朝向', '居民地块是否临街',
                                                           '目标地块是否临街',
                                                           '居民地块所属院落ID', '目标地块所属院落ID'])

# Step 6: 输出结果到Excel文件
compensation_df.to_excel('搬迁补偿方案分析.xlsx', index=False)

print('搬迁补偿方案分析结果已保存至文件 "搬迁补偿方案分析.xlsx"')
