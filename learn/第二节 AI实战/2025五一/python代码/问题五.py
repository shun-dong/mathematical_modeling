import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.decomposition import NMF
from sklearn.linear_model import Lasso, LinearRegression
from sklearn.svm import SVR
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_squared_error, r2_score

# 1. 读入数据
X = pd.read_excel('5-X.xlsx', header=None).values  # 大小 10000 × 100
Y = pd.read_excel('5-Y.xlsx', header=None).values  # 大小 10000 × 1

# 2. 数据标准化（归一化到 [0, 1]）
X_normalized = (X - np.min(X, axis=0)) / (np.max(X, axis=0) - np.min(X, axis=0))

# 3. 使用 NMF 进行降维
k = 50  # 设置降维后的维度
nmf_model = NMF(n_components=k, init='random', random_state=42)
W = nmf_model.fit_transform(X_normalized)  # W 是 n×k
H = nmf_model.components_  # H 是 k×p

# 4. 建立四种回归模型并评估

# 4.1 线性回归
lin_reg = LinearRegression()
lin_reg.fit(W, Y)
Y_hat_lin = lin_reg.predict(W)  # 预测值
MSE_lin = mean_squared_error(Y, Y_hat_lin)
R2_lin = r2_score(Y, Y_hat_lin)

# 4.2 Lasso 回归
lasso_model = Lasso(alpha=0.1)
lasso_model.fit(W, Y)
Y_hat_lasso = lasso_model.predict(W)  # 预测值
MSE_lasso = mean_squared_error(Y, Y_hat_lasso)
R2_lasso = r2_score(Y, Y_hat_lasso)

# 4.3 支持向量回归 (SVR)
svr_model = SVR(kernel='linear')
svr_model.fit(W, Y.ravel())  # 训练模型
Y_hat_svr = svr_model.predict(W)  # 预测值
MSE_svr = mean_squared_error(Y, Y_hat_svr)
R2_svr = r2_score(Y, Y_hat_svr)

# 4.4 决策树回归
tree_model = DecisionTreeRegressor(random_state=42)
tree_model.fit(W, Y)
Y_hat_tree = tree_model.predict(W)  # 预测值
MSE_tree = mean_squared_error(Y, Y_hat_tree)
R2_tree = r2_score(Y, Y_hat_tree)
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 5. 打印结果
print('=== 线性回归 ===')
print(f'MSE = {MSE_lin:.4f}, R^2 = {R2_lin:.4f}')
print('=== Lasso 回归 ===')
print(f'MSE = {MSE_lasso:.4f}, R^2 = {R2_lasso:.4f}')
print('=== 支持向量回归 (SVR) ===')
print(f'MSE = {MSE_svr:.4f}, R^2 = {R2_svr:.4f}')
print('=== 决策树回归 ===')
print(f'MSE = {MSE_tree:.4f}, R^2 = {R2_tree:.4f}')

# 6. 可视化：模型对比
fig, axs = plt.subplots(1, 2, figsize=(14, 6))

# 绘制 R² 比较条形图
axs[0].bar(['Linear', 'Lasso', 'SVR', 'Decision Tree'], [R2_lin, R2_lasso, R2_svr, R2_tree], color=[0.2, 0.6, 0.8])
axs[0].set_ylabel('R²', fontsize=12)
axs[0].set_title('不同模型的拟合优度', fontsize=14)
axs[0].grid(True)

# 绘制 MSE 比较条形图
axs[1].bar(['Linear', 'Lasso', 'SVR', 'Decision Tree'], [MSE_lin, MSE_lasso, MSE_svr, MSE_tree], color=[0.8, 0.2, 0.2])
axs[1].set_ylabel('MSE', fontsize=12)
axs[1].set_title('不同模型的 MSE', fontsize=14)
axs[1].grid(True)

plt.tight_layout()
plt.show()
