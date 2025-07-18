import numpy as np
import pandas as pd
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt

# 1. 读入数据
Data = pd.read_excel('Data.xlsx', header=None).values  # 读取数据，假设数据是10000×1000
n, p = Data.shape  # n: 样本数，p: 特征数

# 2. 标准化数据（归一化到 [0, 1]）
Data_normalized = (Data - np.min(Data)) / (np.max(Data) - np.min(Data))

# 3. 使用 t-SNE 进行降维
# 选择 2D 或 3D 进行可视化
k = 2  # 选择降到 2D
tsne = TSNE(n_components=k, random_state=42)
Data_reduced = tsne.fit_transform(Data_normalized)  # t-SNE 进行降维
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 4. 可视化 t-SNE 降维结果
plt.figure(figsize=(8, 6))

if k == 2:
    plt.scatter(Data_reduced[:, 0], Data_reduced[:, 1], c='blue', marker='o', s=10)
    plt.title(f't-SNE 降维结果 (k={k})', fontsize=16)
    plt.xlabel('t-SNE Component 1', fontsize=12)
    plt.ylabel('t-SNE Component 2', fontsize=12)
else:
    # 如果选择的是 3D 可视化
    from mpl_toolkits.mplot3d import Axes3D
    ax = plt.axes(projection='3d')
    ax.scatter(Data_reduced[:, 0], Data_reduced[:, 1], Data_reduced[:, 2], c='blue', marker='o', s=10)
    ax.set_title(f't-SNE 3D 降维结果 (k={k})', fontsize=16)
    ax.set_xlabel('t-SNE Component 1', fontsize=12)
    ax.set_ylabel('t-SNE Component 2', fontsize=12)
    ax.set_zlabel('t-SNE Component 3', fontsize=12)

plt.grid(True)
plt.show()
