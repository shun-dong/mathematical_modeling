import numpy as np
import matplotlib.pyplot as plt

# 模拟的交叉验证误差数据
cv_errors = [14.9784, 16.2138, 15.0738, 14.9341, 14.6892, 14.4678, 14.7309, 14.7574, 14.7782, 14.3744]
mse_svr = 14.5491
mean_error_svr = 3.0342
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 1. 绘制交叉验证误差折线图
plt.figure(figsize=(8, 6))
plt.plot(range(1, len(cv_errors) + 1), cv_errors, 'o-', linewidth=2, markersize=6, color='b')
plt.xlabel('交叉验证折叠编号', fontsize=12)
plt.ylabel('交叉验证误差', fontsize=12)
plt.title('SVR 交叉验证误差变化', fontsize=14)
plt.grid(True)
plt.show()

# 2. 绘制实际值与预测值的散点图
# 模拟的预测结果
Y_actual = np.random.rand(10000, 1) * 100  # 假设的实际值
Y_pred = Y_actual + np.random.randn(10000, 1) * 5  # 假设的预测值，带有一定误差

plt.figure(figsize=(8, 6))
plt.scatter(Y_actual, Y_pred, s=10, color='blue', label='Data Points')
min_val = min(np.min(Y_actual), np.min(Y_pred))
max_val = max(np.max(Y_actual), np.max(Y_pred))
plt.plot([min_val, max_val], [min_val, max_val], 'r--', label='Ideal Fit', linewidth=1.5)
plt.xlabel('实际值', fontsize=12)
plt.ylabel('预测值', fontsize=12)
plt.title('SVR 实际值 vs 预测值', fontsize=14)
plt.legend(loc='upper left')
plt.grid(True)
plt.show()

# 3. 绘制残差分布直方图
residuals = Y_actual - Y_pred  # 计算残差

plt.figure(figsize=(8, 6))
plt.hist(residuals, bins=50, density=True, color=[0.2, 0.6, 0.8], alpha=0.7)
plt.xlabel('残差', fontsize=12)
plt.ylabel('概率密度', fontsize=12)
plt.title('SVR 残差分布', fontsize=14)
plt.grid(True)
plt.show()

# 4. 绘制实际值与预测值的对比直线图
plt.figure(figsize=(8, 6))
plt.plot(Y_actual, 'b-', linewidth=2, label='实际值')
plt.plot(Y_pred, 'r--', linewidth=2, label='预测值')
plt.legend(loc='upper left')
plt.xlabel('样本编号', fontsize=12)
plt.ylabel('值', fontsize=12)
plt.title('SVR 实际值与预测值对比', fontsize=14)
plt.grid(True)
plt.show()

# 5. 显示 MSE 和 平均预测误差
print(f'SVR 模型的 MSE = {mse_svr:.4f}')
print(f'SVR 模型的 平均预测误差 = {mean_error_svr:.4f}')
