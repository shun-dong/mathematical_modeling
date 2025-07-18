import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

# 1. 读入数据
X = pd.read_excel('3-X.xlsx', header=None).values  # 大小 10000 × 100
Y = pd.read_excel('3-Y.xlsx', header=None).values  # 大小 10000 × 1

# 2. 数据预处理
# 2.1 去噪：使用简单的移动平均去噪
window_size = 5  # 移动平均窗口大小
X_denoised = np.zeros_like(X)

for i in range(X.shape[1]):
    X_denoised[:, i] = np.convolve(X[:, i], np.ones(window_size) / window_size, mode='same')  # 对每一列数据进行去噪

# 2.2 数据标准化：将数据标准化为零均值单位方差
X_normalized = (X_denoised - np.mean(X_denoised, axis=0)) / np.std(X_denoised, axis=0)

# 3. 建立线性回归模型
# 添加常数项（截距项）
X_reg = np.hstack((np.ones((X_normalized.shape[0], 1)), X_normalized))  # 添加截距项

# 线性回归：使用 sklearn 进行线性回归
regressor = LinearRegression()
regressor.fit(X_reg, Y)

# 获取回归系数
b = regressor.coef_.flatten()
intercept = regressor.intercept_

# 4. 模型拟合优度计算
Y_hat = regressor.predict(X_reg)  # 预测值
r = Y - Y_hat  # 回归残差

# 拟合优度 R^2
R2 = regressor.score(X_reg, Y)

# 均方误差 MSE
MSE = mean_squared_error(Y, Y_hat)

print('=== 模型拟合优度 ===')
print(f'R^2 = {R2:.4f}')
print(f'MSE = {MSE:.4f}')

# 5. 统计检验（回归系数的显著性检验）
# sklearn 的 LinearRegression 直接提供了回归系数和拟合结果，但没有提供 p 值。为了计算 p 值，可以使用 statsmodels 库。
import statsmodels.api as sm

X_sm = sm.add_constant(X_normalized)  # 添加常数项
model = sm.OLS(Y, X_sm)
results = model.fit()

print('=== 统计检验结果 ===')
print('回归系数（b）')
print(results.params)

print('回归系数置信区间')
print(results.conf_int())

print('回归残差的置信区间')
print(results.resid)

print(f'p值（统计检验） = {results.pvalues[1]:.4f}')  # 查看 p 值（对于回归系数）
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 6. 可视化拟合效果
# 6.1 绘制实际值 vs 预测值
plt.figure(figsize=(10, 6))
plt.scatter(Y, Y_hat, s=10, color='blue', label='Data Points')
min_val = min(np.min(Y), np.min(Y_hat))
max_val = max(np.max(Y), np.max(Y_hat))
plt.plot([min_val, max_val], [min_val, max_val], 'r--', label='Ideal Fit', linewidth=1.5)
plt.xlabel('实际值', fontsize=12)
plt.ylabel('预测值', fontsize=12)
plt.title('实际值 vs 预测值', fontsize=14)
plt.legend(loc='upper left')
plt.grid(True)
plt.show()

# 6.2 残差图：预测值与残差之间的关系
plt.figure(figsize=(10, 6))
plt.scatter(Y_hat, r, s=10, color='blue', label='Residuals')
plt.xlabel('预测值', fontsize=12)
plt.ylabel('残差', fontsize=12)
plt.title('预测值 vs 残差', fontsize=14)
plt.grid(True)
plt.show()

# 6.3 残差直方图
plt.figure(figsize=(10, 6))
plt.hist(r, bins=50, density=True, color=[0.2, 0.6, 0.8], alpha=0.7)
plt.xlabel('残差', fontsize=12)
plt.ylabel('概率密度', fontsize=12)
plt.title('残差分布', fontsize=14)
plt.grid(True)
plt.show()
