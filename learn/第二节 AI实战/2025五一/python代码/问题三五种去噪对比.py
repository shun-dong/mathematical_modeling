import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import medfilt
from skimage.filters import gaussian
import pywt

# 1. 读入数据
X = pd.read_excel('3-X.xlsx', header=None).values  # 大小 10000 × 100

# 2. 数据去噪方法对比

# 2.1 原始数据（无去噪）
X_original = X

# 2.2 简单移动平均去噪
window_size = 5  # 移动平均窗口大小
X_denoised_moving = np.zeros_like(X)
for i in range(X.shape[1]):
    X_denoised_moving[:, i] = np.convolve(X[:, i], np.ones(window_size) / window_size, mode='same')  # 对每一列数据进行去噪

# 2.3 中值滤波去噪
X_denoised_median = np.zeros_like(X)
for i in range(X.shape[1]):
    X_denoised_median[:, i] = medfilt(X[:, i], window_size)  # 对每一列数据进行中值滤波

# 2.4 高斯滤波去噪
sigma = 2  # 高斯滤波器的标准差
X_denoised_gaussian = np.zeros_like(X)
for i in range(X.shape[1]):
    X_denoised_gaussian[:, i] = gaussian(X[:, i], sigma=sigma)  # 高斯滤波

# 2.5 小波去噪
X_denoised_wavelet = np.zeros_like(X)
for i in range(X.shape[1]):
    c, l = pywt.dwt(X[:, i], 'db4')  # 小波变换
    c = pywt.threshold(c, 0.05, mode='soft')  # 小波去噪（软阈值处理）
    X_denoised_wavelet[:, i] = pywt.idwt(c, l, 'db4')  # 小波重构

# 3. 对比不同去噪方法
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 3.1 可视化比较
plt.figure(figsize=(12, 8))

# 原始数据
plt.subplot(3, 2, 1)
plt.plot(X[0:100, 0])  # 原始数据
plt.title('原始数据')

# 移动平均去噪
plt.subplot(3, 2, 2)
plt.plot(X_denoised_moving[0:100, 0])  # 移动平均去噪数据
plt.title('移动平均去噪')

# 中值滤波去噪
plt.subplot(3, 2, 3)
plt.plot(X_denoised_median[0:100, 0])  # 中值滤波去噪数据
plt.title('中值滤波去噪')

# 高斯滤波去噪
plt.subplot(3, 2, 4)
plt.plot(X_denoised_gaussian[0:100, 0])  # 高斯滤波去噪数据
plt.title('高斯滤波去噪')

# 小波去噪
plt.subplot(3, 2, 5)
plt.plot(X_denoised_wavelet[0:100, 0])  # 小波去噪数据
plt.title('小波去噪')

# 去噪效果差异
plt.subplot(3, 2, 6)
plt.plot(X[0:100, 0] - X_denoised_wavelet[0:100, 0])  # 还可以显示去噪效果差异
plt.title('去噪效果差异')

plt.suptitle('不同去噪方法对比（前100行）', fontsize=16)
plt.tight_layout()
plt.show()

# 3.2 计算去噪前后的误差

# 计算均方误差（MSE）以评估每种去噪方法
MSE_original = np.mean(X**2)  # 原始数据的 MSE

MSE_moving = np.mean((X - X_denoised_moving)**2)  # 移动平均去噪的 MSE
MSE_median = np.mean((X - X_denoised_median)**2)  # 中值滤波去噪的 MSE
MSE_gaussian = np.mean((X - X_denoised_gaussian)**2)  # 高斯滤波去噪的 MSE
MSE_wavelet = np.mean((X - X_denoised_wavelet)**2)  # 小波去噪的 MSE

print('=== 去噪方法比较 ===')
print(f'原始数据 MSE = {MSE_original:.4f}')
print(f'移动平均去噪 MSE = {MSE_moving:.4f}')
print(f'中值滤波去噪 MSE = {MSE_median:.4f}')
print(f'高斯滤波去噪 MSE = {MSE_gaussian:.4f}')
print(f'小波去噪 MSE = {MSE_wavelet:.4f}')
