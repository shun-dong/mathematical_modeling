import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 模拟的结果数据
methods = ['Original', 'SMA', 'WMA', 'Median', 'Gaussian', 'Wavelet']
models = ['Lasso', 'SVR', 'Decision Tree']

R2_values = np.array([
    [0.9968, 0.9986, 0.9096],  # Original
    [0.0087, 0.0053, 0.8447],  # SMA
    [0.0051, 0.0051, 0.8449],  # WMA
    [0.0060, 0.0035, 0.8071],  # Median
    [0.5582, 0.5597, 0.8961],  # Gaussian
    [0.9012, 0.9042, 0.9063]   # Wavelet
])

MSE_values = np.array([
    [0.9746, 0.4415, 27.7116],   # Original
    [303.8602, 304.9090, 47.6168],  # SMA
    [304.9636, 304.9589, 47.5484],  # WMA
    [304.6885, 305.4618, 59.1167],  # Median
    [135.4328, 134.9688, 31.8380],  # Gaussian
    [30.2879, 29.3737, 28.7086]    # Wavelet
])
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 绘制模型性能比较的条形图（R² 和 MSE）
fig, axs = plt.subplots(3, 2, figsize=(12, 10))
fig.suptitle('模型比较（R^2 与 MSE）', fontsize=16)

for i, method in enumerate(methods):
    ax = axs[i // 2, i % 2]
    ax.bar(np.arange(len(models)), R2_values[i], width=0.4, label='R²', color=[0.2, 0.6, 0.8])
    ax2 = ax.twinx()
    ax2.bar(np.arange(len(models)), MSE_values[i], width=0.4, label='MSE', color=[0.8, 0.2, 0.2], alpha=0.5)

    ax.set_ylabel('R²', fontsize=12)
    ax2.set_ylabel('MSE', fontsize=12)
    ax.set_xticks(np.arange(len(models)))
    ax.set_xticklabels(models)
    ax.set_title(f'{method} 方法', fontsize=14)
    ax.grid(True)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()

# 绘制实际值与预测值的散点图
fig, axs = plt.subplots(6, 3, figsize=(15, 18))
fig.suptitle('实际值 vs 预测值', fontsize=16)

for i, method in enumerate(methods):
    for j, model in enumerate(models):
        ax = axs[i, j]
        ax.scatter(np.random.rand(100) * 500, np.random.rand(100) * 500, s=10, color='blue', label=f'{method} - {model}')
        min_val = min(np.random.rand(100) * 500)
        max_val = max(np.random.rand(100) * 500)
        ax.plot([min_val, max_val], [min_val, max_val], 'r--', label='Ideal Fit', linewidth=1.5)
        ax.set_xlabel('实际值', fontsize=12)
        ax.set_ylabel('预测值', fontsize=12)
        ax.set_title(f'{method} - {model}', fontsize=14)
        ax.grid(True)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()

# 绘制残差 vs 预测值图
fig, axs = plt.subplots(6, 3, figsize=(15, 18))
fig.suptitle('残差 vs 预测值', fontsize=16)

for i, method in enumerate(methods):
    for j, model in enumerate(models):
        ax = axs[i, j]
        ax.scatter(np.random.rand(100) * 500, np.random.rand(100) * 100, s=10, color='blue', label=f'{method} - {model}')
        ax.set_xlabel('预测值', fontsize=12)
        ax.set_ylabel('残差', fontsize=12)
        ax.set_title(f'{method} - {model}', fontsize=14)
        ax.grid(True)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()

# 绘制残差分布直方图
fig, axs = plt.subplots(6, 3, figsize=(15, 18))
fig.suptitle('残差分布直方图', fontsize=16)

for i, method in enumerate(methods):
    for j, model in enumerate(models):
        ax = axs[i, j]
        ax.hist(np.random.rand(100) * 50, bins=20, density=True, color=[0.2, 0.6, 0.8], alpha=0.7)
        ax.set_xlabel('残差', fontsize=12)
        ax.set_ylabel('概率密度', fontsize=12)
        ax.set_title(f'{method} - {model}', fontsize=14)
        ax.grid(True)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()
