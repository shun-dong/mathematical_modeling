import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from sklearn.cluster import DBSCAN
from sklearn.svm import OneClassSVM

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号

# 一、生成示例数据

# 设置随机种子以确保结果可重复
np.random.seed(42)

# 生成1000个二维正态分布的正常数据点
mu = [50, 50]        # 均值
sigma = [5, 5]       # 标准差
num_normal = 1000
normal_data = np.random.multivariate_normal(mu, np.diag(np.square(sigma)), num_normal)

# 添加异常值（50个）
num_outliers = 50
outliers = np.random.randn(num_outliers, 2) * 20 + 100
data = np.vstack((normal_data, outliers))

# 绘制原始数据
plt.figure(figsize=(8, 6))
plt.scatter(normal_data[:, 0], normal_data[:, 1], s=10, color='blue', label='正常值')
plt.scatter(outliers[:, 0], outliers[:, 1], s=50, color='red', edgecolors='k', label='异常值')
plt.title('原始数据集')
plt.xlabel('X1')
plt.ylabel('X2')
plt.legend()
plt.show()

# 二、Z-Score（标准分数）法

# 计算每个维度的Z-Score
z_scores = np.abs(stats.zscore(data))

# 定义阈值
threshold_z = 3

# 标记异常值：任意一个维度的Z-Score超过阈值
outliers_z = np.any(z_scores > threshold_z, axis=1)

# 显示检测到的异常值数量
num_detected_z = np.sum(outliers_z)
print(f'Z-Score 方法检测到的异常值数量: {num_detected_z}')

# 三、IQR（四分位距）法

# 计算每个维度的四分位数
Q1 = np.percentile(data, 25, axis=0)
Q3 = np.percentile(data, 75, axis=0)
IQR_val = Q3 - Q1

# 定义上下界限
lower_bound = Q1 - 1.5 * IQR_val
upper_bound = Q3 + 1.5 * IQR_val

# 标记异常值：任意一个维度的数据点超出上下界限
outliers_iqr = np.any((data < lower_bound) | (data > upper_bound), axis=1)

# 显示检测到的异常值数量
num_detected_iqr = np.sum(outliers_iqr)
print(f'IQR 方法检测到的异常值数量: {num_detected_iqr}')

# 四、DBSCAN 聚类分析

# 设置 DBSCAN 参数
epsilon = 5   # 邻域半径
MinPts = 5    # 最小邻域内点数

# 使用 DBSCAN 进行聚类
dbscan = DBSCAN(eps=epsilon, min_samples=MinPts)
labels_dbscan = dbscan.fit_predict(data)

# DBSCAN 将噪声点标记为 -1
outliers_dbscan = labels_dbscan == -1

# 显示检测到的异常值数量
num_detected_dbscan = np.sum(outliers_dbscan)
print(f'DBSCAN 方法检测到的异常值数量: {num_detected_dbscan}')

# 五、隔离森林（Isolation Forest）替代方法：One-Class SVM

# 使用 sklearn 的 One-Class SVM 进行异常值检测
# 将标签设为 +1 表示正常，-1 表示异常
# 'nu' 参数类似于 OutlierFraction，控制异常值比例
svm = OneClassSVM(kernel='rbf', gamma='auto', nu=0.05)
svm.fit(data)
labels_svm = svm.predict(data)

# One-Class SVM 将异常值标记为 -1
outliers_svm = labels_svm == -1

# 显示检测到的异常值数量
num_detected_svm = np.sum(outliers_svm)
print(f'One-Class SVM 方法检测到的异常值数量: {num_detected_svm}')

# 六、结果可视化

# 定义颜色和标记
cmap = plt.colormaps['tab10']
colors = [cmap(i) for i in range(4)]  # 获取前4种颜色

plt.figure(figsize=(10, 8))

# 绘制正常值（未被 Z-Score 方法标记为异常的点）
plt.scatter(data[~outliers_z, 0], data[~outliers_z, 1], s=10, color=colors[0], label='正常值')

# 绘制 Z-Score 检测到的异常值
plt.scatter(data[outliers_z, 0], data[outliers_z, 1],
            s=50, marker='x', color=colors[0],
            label='Z-Score 异常值')

# 绘制 IQR 检测到的异常值
plt.scatter(data[outliers_iqr, 0], data[outliers_iqr, 1],
            s=50, marker='o', facecolors='none',
            edgecolors=colors[1], label='IQR 异常值')

# 绘制 DBSCAN 检测到的异常值
plt.scatter(data[outliers_dbscan, 0], data[outliers_dbscan, 1],
            s=50, marker='D', facecolors='none',
            edgecolors=colors[2], label='DBSCAN 异常值')

# 绘制 One-Class SVM 检测到的异常值
plt.scatter(data[outliers_svm, 0], data[outliers_svm, 1],
            s=50, marker='s', facecolors='none',
            edgecolors=colors[3], label='One-Class SVM 异常值')

plt.title('异常值检测结果比较')
plt.xlabel('X1')
plt.ylabel('X2')
plt.legend(loc='best')
plt.grid(True)
plt.show()
