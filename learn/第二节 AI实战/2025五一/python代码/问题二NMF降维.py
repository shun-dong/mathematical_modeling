import numpy as np
import pandas as pd
from sklearn.decomposition import NMF
import matplotlib.pyplot as plt

# 1. 读入数据
Data = pd.read_excel('Data.xlsx', header=None).values  # 读取数据，假设数据是10000×1000
n, p = Data.shape  # n: 样本数，p: 特征数

# 2. 标准化数据（归一化到 [0, 1]）
Data_normalized = (Data - np.min(Data)) / (np.max(Data) - np.min(Data))

# 3. 变量初始化
min_MSE = np.inf  # 最小 MSE 初始为无穷大
best_k = 0  # 最优维度初始化

# 4. 遍历 10 到 100 维进行降维并计算 MSE
for k in range(10, 101):
    # 进行 NMF 降维
    model = NMF(n_components=k, init='random', random_state=42)
    W = model.fit_transform(Data_normalized)  # W 是 n×k
    H = model.components_  # H 是 k×p

    # 使用 NMF 逆变换进行数据还原
    Data_reconstructed = np.dot(W, H)

    # 计算还原数据的 MSE（均方误差）
    MSE = np.mean((Data_normalized - Data_reconstructed) ** 2)

    # 更新最小 MSE 和对应的最佳维度
    if MSE < min_MSE:
        min_MSE = MSE
        best_k = k

# 输出最优的降维维度和对应的 MSE
print(f'=== 最优降维维度 ===')
print(f'最优维度 = {best_k}')
print(f'对应的 MSE = {min_MSE:.6f}')

# 5. 使用 NMF 进行降维
# 假设我们选择降到 k 个维度，这里选择 k=15 作为示例
k = 15
model = NMF(n_components=k, init='random', random_state=42)
W = model.fit_transform(Data_normalized)  # W 是 n×k
H = model.components_  # H 是 k×p

# W: 表示原始数据在低维空间中的表示（每个样本的低维表示）
# H: 表示低维空间的基矩阵

# 6. 计算压缩效率
# 原始数据存储大小
original_size = Data.size

# 降维后数据存储大小（W 和 H）
compressed_size = W.size + H.size  # 存储 W 和 H
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 绘图部分
# 压缩比
compression_ratio = original_size / compressed_size

# 存储空间节省率
storage_savings = 1 - compressed_size / original_size

print(f'=== 数据压缩效率 ===')
print(f'压缩比 = {compression_ratio:.4f}')
print(f'存储空间节省率 = {storage_savings:.4f}')

# 7. 数据还原（使用 NMF 逆变换）
Data_reconstructed = np.dot(W, H)  # 使用 W 和 H 重构数据

# 8. 计算还原数据的 MSE（均方误差）
MSE = np.mean((Data_normalized - Data_reconstructed) ** 2)
print(f'=== 数据还原准确度 ===')
print(f'MSE = {MSE:.6f}')

if MSE <= 0.005:
    print(f'还原数据的准确度满足要求，MSE ≤ 0.005')
else:
    print(f'还原数据的准确度未满足要求，MSE > 0.005')
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 绘图部分
# 9. 可视化还原效果
# 可视化还原前后数据的差异
plt.figure(figsize=(12, 6))

# 原始数据（前 50 行 50 列）
plt.subplot(1, 2, 1)
plt.imshow(Data[:50, :50], cmap='viridis', aspect='auto')
plt.colorbar()
plt.title('原始数据（前 50 行 50 列）')

# 还原数据（前 50 行 50 列）
plt.subplot(1, 2, 2)
plt.imshow(Data_reconstructed[:50, :50], cmap='viridis', aspect='auto')
plt.colorbar()
plt.title('还原数据（前 50 行 50 列）')

plt.tight_layout()
plt.show()
