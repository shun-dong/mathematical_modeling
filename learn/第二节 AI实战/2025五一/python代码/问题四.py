import numpy as np
import pandas as pd
from sklearn.svm import SVR
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import cross_val_score
from tqdm import tqdm

# 1. 读入数据
X = pd.read_excel('4-X.xlsx', header=None).values  # 大小 10000 × 100
Y = pd.read_excel('4-Y.xlsx', header=None).values  # 大小 10000 × 1

# 2. 数据标准化（归一化到 [0, 1]）
scaler = MinMaxScaler()
X_normalized = scaler.fit_transform(X)

# 3. 添加常数项（截距项）
X_reg = np.hstack([np.ones((X_normalized.shape[0], 1)), X_normalized])

# --- 支持向量回归（SVR）---
best_C_svr = 1  # 初始 C 参数
best_eps_svr = 0.1  # 初始 epsilon 参数
best_R2_svr = -np.inf

# 使用网格搜索进行自适应参数调整
C_values = np.logspace(-5, 5, 5)  # C 参数范围
eps_values = np.logspace(-5, 1, 5)  # epsilon 参数范围

# 进度条
total_combinations = len(C_values) * len(eps_values)
progress_bar = tqdm(total=total_combinations, desc="SVR Parameter Tuning", unit="combination")

# 网格搜索调整 C 和 epsilon
for C in C_values:
    for eps in eps_values:
        # 使用 SVR 进行训练
        svr_model = SVR(kernel='linear', C=C, epsilon=eps)
        svr_model.fit(X_reg, Y.ravel())  # 使用 ravel() 将 Y 转换为一维数组

        Y_hat_svr = svr_model.predict(X_reg)  # 预测值

        # 计算 R²
        SSres = np.sum((Y - Y_hat_svr) ** 2)
        SStot = np.sum((Y - np.mean(Y)) ** 2)
        R2_svr = 1 - SSres / SStot

        # 寻找最优的C和epsilon
        if R2_svr > best_R2_svr:
            best_R2_svr = R2_svr
            best_C_svr = C
            best_eps_svr = eps

        progress_bar.update(1)

progress_bar.close()

print(f"最优SVR C = {best_C_svr:.5f}, epsilon = {best_eps_svr:.5f}, 最优 R^2 = {best_R2_svr:.4f}")

# SVR模型的评估
svr_model = SVR(kernel='linear', C=best_C_svr, epsilon=best_eps_svr)
svr_model.fit(X_reg, Y.ravel())  # 训练模型
Y_hat_svr = svr_model.predict(X_reg)

MSE_svr = mean_squared_error(Y, Y_hat_svr)
mean_error_svr = np.mean(np.abs(Y - Y_hat_svr))  # 平均预测误差
print(f"SVR模型的 MSE = {MSE_svr:.4f}, 平均预测误差 = {mean_error_svr:.4f}")

# 交叉验证
cv_svr = cross_val_score(svr_model, X_reg, Y.ravel(), cv=5, scoring='neg_mean_squared_error')

# 输出交叉验证的均方误差
print(f"SVR的交叉验证误差： {-cv_svr.mean():.4f}")
