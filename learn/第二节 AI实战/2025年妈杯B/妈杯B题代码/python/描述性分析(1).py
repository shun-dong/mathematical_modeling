import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# 读取附件一数据
filename = '附件一：老城街区地块信息.xlsx'
data = pd.read_excel(filename)

# 查看数据的原始列标题
print(data.columns)

# 手动设置有效的列标题
data.columns = ['BlockID', 'YardID', 'BlockArea', 'YardArea', 'Orientation', 'HasResident']

# 显示前几行数据
print(data.head())

# 描述性统计分析
# 计算各个数值列的基本统计量：均值、标准差、最大值、最小值等
print('\n地块面积的描述性统计：')
print(f"均值：{data['BlockArea'].mean()}")
print(f"标准差：{data['BlockArea'].std()}")
print(f"最小值：{data['BlockArea'].min()}")
print(f"最大值：{data['BlockArea'].max()}")

print('\n院落面积的描述性统计：')
print(f"均值：{data['YardArea'].mean()}")
print(f"标准差：{data['YardArea'].std()}")
print(f"最小值：{data['YardArea'].min()}")
print(f"最大值：{data['YardArea'].max()}")

# 可视化：地块面积和院落面积的分布（直方图）
fig, axes = plt.subplots(1, 2, figsize=(12, 6))
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 地块面积分布
axes[0].hist(data['BlockArea'], bins=10)
axes[0].set_title('地块面积分布')
axes[0].set_xlabel('地块面积（平方米）')
axes[0].set_ylabel('频率')

# 院落面积分布
axes[1].hist(data['YardArea'], bins=10)
axes[1].set_title('院落面积分布')
axes[1].set_xlabel('院落面积（平方米）')
axes[1].set_ylabel('频率')

plt.tight_layout()
plt.show()

# 可视化：地块方位分布（柱状图）
plt.figure(figsize=(8, 6))
direction_counts = data['Orientation'].value_counts()
sns.barplot(x=direction_counts.index, y=direction_counts.values)
plt.title('地块方位分布')
plt.xlabel('方位')
plt.ylabel('数量')
plt.show()

# 可视化：是否有住户的分布（饼图）
plt.figure(figsize=(8, 6))
resident_counts = data['HasResident'].value_counts()
plt.pie(resident_counts, labels=['无住户', '有住户'], autopct='%1.1f%%', startangle=90)
plt.title('是否有住户的分布')
plt.show()

# 可视化：院落ID与地块面积的关系（散点图）
plt.figure(figsize=(8, 6))
plt.scatter(data['YardID'], data['BlockArea'])
plt.title('院落ID与地块面积的关系')
plt.xlabel('院落ID')
plt.ylabel('地块面积（平方米）')
plt.show()
