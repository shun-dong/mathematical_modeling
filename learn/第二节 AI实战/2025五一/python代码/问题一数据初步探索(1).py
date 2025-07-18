import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import skew, kurtosis, pearsonr, normaltest


# 1. 数据读取
A = pd.read_excel('A.xlsx', header=None).values  # 大小 10000 × 100
B = pd.read_excel('B.xlsx', header=None).values  # 大小 10000 × 1

# 2. 计算描述性统计量：均值、标准差、偏度、峰度
meansA = np.mean(A, axis=0)
stdsA = np.std(A, axis=0)
skewA = skew(A, axis=0)
kurtA = kurtosis(A, axis=0)

# 计算 B 的描述性统计量
meanB = np.mean(B)
stdB = np.std(B)
skewB = skew(B.flatten())  # 将 B 转为一维数组进行偏度计算
kurtB = kurtosis(B.flatten())  # 将 B 转为一维数组进行峰度计算

# 打印统计量
print('Col\tMean\tStd\tSkewness\tKurtosis')
for i in range(A.shape[1]):
    print(f'{i+1}\t{meansA[i]:.4f}\t{stdsA[i]:.4f}\t{skewA[i]:.4f}\t{kurtA[i]:.4f}')
# 打印 B 的统计量
print(f' B \t{meanB:.4f}\t{stdB:.4f}\t{skewB:.4f}\t{kurtB:.4f}')
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 3. 可视化：A 的直方图矩阵
fig, axes = plt.subplots(10, 10, figsize=(20, 20))
fig.suptitle('Histogram of A columns')
for i in range(A.shape[1]):
    ax = axes[i // 10, i % 10]
    ax.hist(A[:, i], bins=20)
    ax.set_title(f'A_{i+1}', fontsize=8)
    ax.set_xticks([])
    ax.set_yticks([])
plt.tight_layout()

# 4. 可视化：B 的直方图与箱线图
fig, ax = plt.subplots(1, 2, figsize=(12, 6))
ax[0].hist(B, bins=20)
ax[0].set_title('Histogram of B')
sns.boxplot(data=B, ax=ax[1])
ax[1].set_title('Boxplot of B')
plt.show()

# 5. 可选：绘制 QQ-plot 检验正态性
from scipy import stats

fig, ax = plt.subplots(1, 2, figsize=(12, 6))
stats.probplot(A.flatten(), dist="norm", plot=ax[0])
ax[0].set_title('QQ-Plot of all A data')
stats.probplot(B.flatten(), dist="norm", plot=ax[1])
ax[1].set_title('QQ-Plot of B data')
plt.show()

# 2. 分布方式检验 (Lilliefors 正态性检验)
from scipy.stats import normaltest

# 对每一列做正态性检验
alpha = 0.05
p_values = np.zeros(A.shape[1])
is_normal = np.zeros(A.shape[1], dtype=bool)

for i in range(A.shape[1]):
    _, p_val = normaltest(A[:, i])  # 使用normaltest代替lilliefors
    is_normal[i] = p_val > alpha
    p_values[i] = p_val
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 汇总结果
result = pd.DataFrame({
    'Column': np.arange(1, A.shape[1] + 1),
    'IsNormal': is_normal,
    'pValue': p_values
})
print(result)

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 1. p 值 Bar Plot
plt.figure(figsize=(10, 6))
plt.bar(np.arange(1, A.shape[1] + 1), p_values, color='skyblue')
plt.axhline(y=alpha, color='r', linestyle='--', linewidth=2)
plt.xlabel('列编号')
plt.ylabel('p 值')
plt.title('Lilliefors 检验各列 p 值')
plt.grid(True)
plt.show()

# 2. 正态 vs 非正态 Pie Chart
counts = [np.sum(is_normal), np.sum(~is_normal)]
plt.figure(figsize=(6, 6))
plt.pie(counts, labels=['正态列', '非正态列'], autopct='%1.1f%%', startangle=90)
plt.title('各列正态性检验结果分布')
plt.show()

# 3. p 值分布直方图
plt.figure(figsize=(10, 6))
plt.hist(p_values, bins=np.arange(0, 1.05, 0.05), color='salmon')
plt.xlabel('p 值')
plt.ylabel('频数')
plt.title('p 值分布直方图')
plt.grid(True)
plt.show()

# 4. 示例 QQ-Plot（正态列与非正态列各选 4 个）
norm_cols = np.where(is_normal)[0]
non_norm_cols = np.where(~is_normal)[0]
sel_norm = norm_cols[:min(4, len(norm_cols))]
sel_non_norm = non_norm_cols[:min(4, len(non_norm_cols))]

fig, axes = plt.subplots(2, 4, figsize=(15, 8))
for idx, col in enumerate(sel_norm):
    stats.probplot(A[:, col], dist="norm", plot=axes[0, idx])
    axes[0, idx].set_title(f'正态列 QQ: {col+1}')
for idx, col in enumerate(sel_non_norm):
    stats.probplot(A[:, col], dist="norm", plot=axes[1, idx])
    axes[1, idx].set_title(f'非正态列 QQ: {col+1}')
plt.suptitle('QQ-Plot 示例：正态 vs 非正态', fontsize=14)
plt.show()

# 3. 相关性分析
corr_coeff = np.zeros(A.shape[1])
p_values = np.zeros(A.shape[1])

for i in range(A.shape[1]):
    corr_coeff[i], p_values[i] = pearsonr(A[:, i], B.flatten())

# 相关系数的可视化
plt.figure(figsize=(12, 6))
plt.bar(np.arange(1, A.shape[1] + 1), corr_coeff, color='skyblue', edgecolor='black')
plt.axhline(y=0, color='r', linestyle='--', linewidth=2)
plt.xlabel('A 列编号')
plt.ylabel('Pearson \rho')
plt.title('A(:,i) 与 B 的 Pearson 相关系数')
plt.grid(True)
plt.show()

# 相关系数分布直方图
plt.figure(figsize=(10, 6))
plt.hist(corr_coeff, bins=20, color='salmon', edgecolor='none', density=True)
plt.xlabel('Pearson \rho 值')
plt.ylabel('频率')
plt.title('相关系数分布直方图')
plt.grid(True)
plt.show()

# 正相关 vs 负相关 列数 Pie Chart
pos_count = np.sum(corr_coeff > 0)
neg_count = np.sum(corr_coeff < 0)
plt.figure(figsize=(6, 6))
plt.pie([pos_count, neg_count], labels=['正相关', '负相关'], autopct='%1.1f%%', startangle=90)
plt.title('正相关列与负相关列占比')
plt.show()

# Scatter plots: Top 4 正负相关示例
top_pos_idx = np.argsort(corr_coeff)[-4:]
top_neg_idx = np.argsort(corr_coeff)[:4]

fig, axes = plt.subplots(2, 4, figsize=(15, 8))
for idx, col in enumerate(top_pos_idx):
    axes[0, idx].scatter(A[:, col], B, color='b', s=10)
    axes[0, idx].set_title(f'正相关 #{col+1}: ρ={corr_coeff[col]:.2f}')
    axes[0, idx].set_xlabel(f'A(:,{col+1})')
    axes[0, idx].set_ylabel('B')
    axes[0, idx].grid(True)

for idx, col in enumerate(top_neg_idx):
    axes[1, idx].scatter(A[:, col], B, color='r', s=10)
    axes[1, idx].set_title(f'负相关 #{col+1}: ρ={corr_coeff[col]:.2f}')
    axes[1, idx].set_xlabel(f'A(:,{col+1})')
    axes[1, idx].set_ylabel('B')
    axes[1, idx].grid(True)

plt.suptitle('Scatter Examples: Top+ and Top-', fontsize=14)
plt.show()
