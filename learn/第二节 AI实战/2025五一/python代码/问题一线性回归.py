import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
import statsmodels.api as sm

# 1. 数据读取
A = pd.read_excel('A.xlsx', header=None).values  # 大小 10000 × 100
B = pd.read_excel('B.xlsx', header=None).values  # 大小 10000 × 1
n, p = A.shape

# 2. 构造回归矩阵（含常数项）
X = np.column_stack([np.ones(n), A])  # n×(p+1)

# 3. 最小二乘估计 β = [β0; β1…βp]
beta = np.linalg.lstsq(X, B, rcond=None)[0]  # (p+1)×1

# 4. 预测与残差
B_hat = X.dot(beta)
residuals = B - B_hat

# 5. 误差指标计算
MSE = np.mean(residuals**2)
RMSE = np.sqrt(MSE)
MAE = np.mean(np.abs(residuals))
SSres = np.sum(residuals**2)
SStot = np.sum((B - np.mean(B))**2)
R2 = 1 - SSres / SStot

print('=== 回归性能指标 ===')
print(f'MSE   = {MSE:.4e}')
print(f'RMSE  = {RMSE:.4e}')
print(f'MAE   = {MAE:.4e}')
print(f'R^2   = {R2:.4f}\n')

# 6. 残差标准误差、t 检验（可选）
sigma2 = SSres / (n - (p + 1))
CovB = sigma2 * np.linalg.inv(X.T.dot(X))
seBeta = np.sqrt(np.diag(CovB))
tStat = beta.flatten() / seBeta
pVals = 2 * (1 - stats.t.cdf(np.abs(tStat), n - (p + 1)))

# 输出t检验结果
print('=== t 检验 ===')
for i in range(len(beta)):
    print(f'β{i}: t统计量 = {tStat[i]:.4f}, p值 = {pVals[i]:.4f}')

# 可视化部分
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 7.1 实际 vs 预测
plt.figure('Actual vs Predicted', figsize=(8, 6))
plt.scatter(B, B_hat, s=10, c='blue', label='预测值 vs 实际值')
plt.plot([min(B.min(), B_hat.min()), max(B.max(), B_hat.max())], [min(B.min(), B_hat.min()), max(B.max(), B_hat.max())], 'r--', lw=1.5)
plt.xlabel('实际 B', fontsize=12)
plt.ylabel('预测 ^B', fontsize=12)
plt.title('实际值 vs 预测值', fontsize=14)
plt.grid(True)
plt.show()

# 7.2 残差直方图
plt.figure('Residuals Histogram', figsize=(8, 6))
plt.hist(residuals, bins=50, density=True, color='skyblue')
plt.xlabel('残差', fontsize=12)
plt.ylabel('概率密度', fontsize=12)
plt.title('残差分布', fontsize=14)
plt.grid(True)
plt.show()

# 7.3 残差序列图
plt.figure('Residuals vs Index', figsize=(8, 6))
plt.plot(residuals, '.', markersize=6)
plt.xlabel('样本索引', fontsize=12)
plt.ylabel('残差', fontsize=12)
plt.title('残差序列', fontsize=14)
plt.axhline(0, color='r', linestyle='--')
plt.grid(True)
plt.show()
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 7.4 残差 QQ-Plot
plt.figure('QQ-Plot of Residuals', figsize=(8, 6))
stats.probplot(residuals.flatten(), dist="norm", plot=plt)
plt.title('残差 QQ-Plot', fontsize=14)
plt.show()

# 残差的均值和标准差
mean_residual = np.mean(residuals)
std_residual = np.std(residuals)

print('=== 残差统计 ===')
print(f'残差均值 = {mean_residual:.4e}')
print(f'残差标准差 = {std_residual:.4e}')

# 残差 vs 预测值图（可以用于检测模型偏差）
plt.figure('Residuals vs Predicted', figsize=(8, 6))
plt.scatter(B_hat, residuals, s=10, c='blue', label='残差 vs 预测值')
plt.xlabel('预测值 ^B', fontsize=12)
plt.ylabel('残差', fontsize=12)
plt.title('残差与预测值的关系', fontsize=14)
plt.grid(True)
plt.show()

# 离群点检测：残差大于 3 标准差的点
outliers = np.abs(residuals) > 3 * std_residual
plt.figure('离群点检测', figsize=(8, 6))
plt.scatter(np.arange(1, n + 1), residuals, s=10, c='blue', label='残差')
plt.plot(np.arange(1, n + 1), 3 * std_residual * np.ones(n), 'r--', lw=1.5, label='3标准差')
plt.plot(np.arange(1, n + 1), -3 * std_residual * np.ones(n), 'r--', lw=1.5)
plt.xlabel('样本索引', fontsize=12)
plt.ylabel('残差', fontsize=12)
plt.title('残差与离群点检测', fontsize=14)
plt.grid(True)
plt.legend()
plt.show()
