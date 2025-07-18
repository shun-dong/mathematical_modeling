import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Step 1: Read the data and retain the original column names
filename = '搬迁补偿方案分析.xlsx'
data = pd.read_excel(filename)

# Display the actual column names
print('实际列名:')
print(data.columns)  # Display the actual column names
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
# Step 2: Rename columns to English
data.columns = ['PlotID', 'TargetPlotID', 'ResidentArea', 'TargetArea', 'ResidentOrientation',
                'TargetOrientation', 'ResidentIsStreetside', 'TargetIsStreetside',
                'ResidentCourtyardID', 'TargetCourtyardID']

# Step 3: Extract relevant data columns (e.g., area data)
# Here we choose ResidentArea and TargetArea as an example
data_matrix = data[['ResidentArea', 'TargetArea']].astype(np.float32)

# Step 4: Normalize the data (Min-Max normalization)
data_norm = (data_matrix - data_matrix.min()) / (data_matrix.max() - data_matrix.min())#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da

# Step 5: Calculate entropy and weights
n = data_norm.shape[0]  # Number of rows (data points)
m = data_norm.shape[1]  # Number of columns (indicators)

# Calculate the probability distribution for each indicator
p = data_norm / data_norm.sum(axis=0)

# Calculate the entropy for each indicator
k = 1 / np.log(n)  # Constant k
entropy = -k * (p * np.log(p + np.finfo(float).eps)).sum(axis=0)  # Add epsilon to avoid log(0)

# Calculate the weight for each indicator
weight = (1 - entropy) / (1 - entropy).sum()

# Output the weights
print('每个指标的权重：')
print(weight)

# Step 6: Calculate the ideal solution
ideal_solution = data_norm.max()
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
# Calculate the Euclidean distance to the ideal solution for each option
distance_to_ideal = np.sqrt(((data_norm - ideal_solution) ** 2).sum(axis=1))

# Select the option with the smallest distance to the ideal solution
ideal_index = np.argmin(distance_to_ideal)

print('最优搬迁方案ID：')
print(data['PlotID'].iloc[ideal_index])  # Assume 'PlotID' column represents the scheme ID
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# Step 7: Plot the weights of each indicator

plt.figure()
plt.bar(range(len(weight)), weight)
plt.title('每个指标的权重')
# Update labels to match the number of indicators
plt.xticks(range(len(weight)), ['居民地块面积', '目标地块面积'])  # Corrected labels
plt.ylabel('权重')
plt.xlabel('指标')
plt.grid(True)
