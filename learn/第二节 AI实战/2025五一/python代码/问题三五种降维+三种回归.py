import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import Lasso
from sklearn.svm import SVR
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_squared_error, r2_score
from scipy.signal import medfilt
from skimage.filters import gaussian
import pywt

# 1. 读入数据
X = pd.read_excel('3-X.xlsx', header=None).values  # 大小 10000 × 100
Y = pd.read_excel('3-Y.xlsx', header=None).values  # 大小 10000 × 1

# 2. 数据标准化（归一化到 [0, 1]）
X_normalized = (X - np.min(X, axis=0)) / (np.max(X, axis=0) - np.min(X, axis=0))

# 3. 去噪处理

# 3.1 简单移动平均（SMA）
window_size = 100  # 移动平均窗口大小
X_sma = np.zeros_like(X)
for i in range(X.shape[1]):
    X_sma[:, i] = np.convolve(X[:, i], np.ones(window_size) / window_size, mode='same')

# 3.2 加权移动平均（WMA）
weights = np.linspace(1, 2, window_size)  # 权重从1到2
X_wma = np.zeros_like(X)
for i in range(X.shape[1]):
    X_wma[:, i] = np.convolve(X[:, i], weights / np.sum(weights), mode='same')

# 3.3 中值滤波
# 3.3 中值滤波
window_size = 101  # 将窗口大小更改为奇数
X_median = np.zeros_like(X)
for i in range(X.shape[1]):
    X_median[:, i] = medfilt(X[:, i], window_size)  # 中值滤波


# 3.4 高斯滤波
sigma = 1  # 高斯滤波的标准差
X_gaussian = np.zeros_like(X)
for i in range(X.shape[1]):
    X_gaussian[:, i] = gaussian(X[:, i], sigma=sigma)

# 3.5 小波去噪（使用db4小波）
X_wavelet = np.zeros_like(X)
for i in range(X.shape[1]):
    coeffs = pywt.wavedec(X[:, i], 'db4', level=5)  # 5层小波分解
    coeffs[0] = np.zeros_like(coeffs[0])  # 去除低频信号
    X_wavelet[:, i] = pywt.waverec(coeffs, 'db4')  # 小波重构

# 4. 对不同去噪后的数据进行回归建模并计算精度

methods = ['Original', 'SMA', 'WMA', 'Median', 'Gaussian', 'Wavelet']
X_denoised = [X_normalized, X_sma, X_wma, X_median, X_gaussian, X_wavelet]


# 5. 回归模型定义
def lasso_regression(X, Y):
    model = Lasso(alpha=0.1)
    model.fit(X, Y)
    Y_hat = model.predict(X)
    R2 = r2_score(Y, Y_hat)
    MSE = mean_squared_error(Y, Y_hat)
    return R2, MSE, Y_hat


def svr_regression(X, Y):
    model = SVR(kernel='linear')
    model.fit(X, Y)
    Y_hat = model.predict(X)
    R2 = r2_score(Y, Y_hat)
    MSE = mean_squared_error(Y, Y_hat)
    return R2, MSE, Y_hat


def decision_tree_regression(X, Y):
    model = DecisionTreeRegressor(random_state=42)
    model.fit(X, Y)
    Y_hat = model.predict(X)
    R2 = r2_score(Y, Y_hat)
    MSE = mean_squared_error(Y, Y_hat)
    return R2, MSE, Y_hat


for i, method in enumerate(methods):
    print(f'=== {method} 方法 ===')

    # 对每种去噪后的数据应用回归模型
    R2_lasso, MSE_lasso, Y_hat_lasso = lasso_regression(
        np.hstack([np.ones((X_denoised[i].shape[0], 1)), X_denoised[i]]), Y)
    print('Lasso Regression:')
    print(f'R^2 = {R2_lasso:.4f}, MSE = {MSE_lasso:.4f}')

    R2_svr, MSE_svr, Y_hat_svr = svr_regression(np.hstack([np.ones((X_denoised[i].shape[0], 1)), X_denoised[i]]), Y)
    print('SVR:')
    print(f'R^2 = {R2_svr:.4f}, MSE = {MSE_svr:.4f}')

    R2_tree, MSE_tree, Y_hat_tree = decision_tree_regression(
        np.hstack([np.ones((X_denoised[i].shape[0], 1)), X_denoised[i]]), Y)
    print('Decision Tree:')
    print(f'R^2 = {R2_tree:.4f}, MSE = {MSE_tree:.4f}')
    plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
    plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
    # 绘制实际值 vs 预测值的散点图
    plt.figure(figsize=(12, 8))
    plt.subplot(2, 2, 1)
    plt.scatter(Y, Y_hat_lasso, 10, color='blue', label='Lasso')
    plt.plot([min(Y), max(Y)], [min(Y), max(Y)], 'r--', label='Ideal Fit')
    plt.xlabel('实际值')
    plt.ylabel('预测值（Lasso）')
    plt.title('实际值 vs 预测值（Lasso）')
    plt.legend()
    plt.grid(True)

    # 确保 Y 是一维数组
    Y = Y.ravel()

    # 绘制残差图
    plt.figure(figsize=(12, 8))
    plt.subplot(2, 2, 2)
    plt.scatter(Y_hat_lasso, Y - Y_hat_lasso, 10, color='blue', label='Lasso')
    plt.xlabel('预测值')
    plt.ylabel('残差')
    plt.title('残差 vs 预测值（Lasso）')
    plt.grid(True)

    # 绘制残差直方图
    plt.subplot(2, 2, 3)
    plt.hist(Y - Y_hat_lasso, bins=50, density=True, color=[0.2, 0.6, 0.8], alpha=0.7)
    plt.xlabel('残差')
    plt.ylabel('概率密度')
    plt.title('残差分布（Lasso）')
    plt.grid(True)

    # 绘制模型比较的条形图（R² 和 MSE）
    plt.subplot(2, 2, 4)
    model_names = ['Lasso', 'SVR', 'Decision Tree']
    R2_values = [R2_lasso, R2_svr, R2_tree]
    MSE_values = [MSE_lasso, MSE_svr, MSE_tree]

    plt.bar(model_names, R2_values, color=[0.2, 0.6, 0.8], label='R^2')
    plt.ylabel('R^2')
    plt.ylim([0, 1])
    plt.twinx()
    plt.bar(model_names, MSE_values, color=[0.8, 0.2, 0.2], alpha=0.5, label='MSE')
    plt.ylabel('MSE')
    plt.title('模型比较：R² 与 MSE')
    plt.grid(True)
    plt.tight_layout()
    plt.show()
