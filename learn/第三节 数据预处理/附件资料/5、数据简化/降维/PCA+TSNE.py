import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号

# 一、生成合成数据

# 设置随机种子以确保结果可重复
np.random.seed(42)

# 定义参数
num_samples = 300  # 总样本数
num_features = 10  # 特征维度
num_classes = 3  # 类别数
samples_per_class = num_samples // num_classes

# 初始化数据和标签
X = np.zeros((num_samples, num_features))
y = np.zeros(num_samples, dtype=int)

# 为每个类别生成数据
for class_label in range(1, num_classes + 1):
    idx_start = (class_label - 1) * samples_per_class
    idx_end = class_label * samples_per_class

    # 每个类别的均值向量不同
    mu = np.zeros(num_features)
    mu[:3] = class_label * 5  # 前3个特征的均值随类别变化

    # 协方差矩阵为单位矩阵
    Sigma = np.eye(num_features)

    # 生成多元正态分布数据
    X[idx_start:idx_end, :] = np.random.multivariate_normal(mu, Sigma, samples_per_class)
    y[idx_start:idx_end] = class_label

# 创建DataFrame
feature_names = [f'Feature{i}' for i in range(1, num_features + 1)]
df = pd.DataFrame(X, columns=feature_names)
df['Class'] = y

# 可视化部分原始特征（前两个特征）
plt.figure(figsize=(8, 6))
sns.scatterplot(data=df, x='Feature1', y='Feature2', hue='Class', palette='bright', style='Class',
                markers=['o', '^', 's'])
plt.title('合成数据的前两个特征')
plt.xlabel('Feature1')
plt.ylabel('Feature2')
plt.legend(title='Class')
plt.grid(True)
plt.show()

# 二、主成分分析（PCA）

# 标准化数据（均值为0，方差为1）
scaler_pca = StandardScaler()
X_pca_scaled = scaler_pca.fit_transform(X)

# 执行PCA，保留2个主成分
pca = PCA(n_components=2)
pca_2D = pca.fit_transform(X_pca_scaled)
explained_variance = pca.explained_variance_ratio_

# 创建DataFrame用于绘图
df_pca = pd.DataFrame(pca_2D, columns=['PC1', 'PC2'])
df_pca['Class'] = y

# 可视化PCA结果
plt.figure(figsize=(8, 6))
sns.scatterplot(data=df_pca, x='PC1', y='PC2', hue='Class', palette='bright', style='Class', markers=['o', '^', 's'])
plt.title(f'PCA降维结果 (解释方差前2个主成分: {explained_variance.sum() * 100:.2f}%)')
plt.xlabel('主成分 1')
plt.ylabel('主成分 2')
plt.legend(title='Class')
plt.grid(True)
plt.show()

# 三、线性判别分析（LDA）

# LDA 需要类标签
lda = LDA(n_components=2)
lda_2D = lda.fit_transform(X, y)

# 创建DataFrame用于绘图
df_lda = pd.DataFrame(lda_2D, columns=['LD1', 'LD2'])
df_lda['Class'] = y

# 可视化LDA结果
plt.figure(figsize=(8, 6))
sns.scatterplot(data=df_lda, x='LD1', y='LD2', hue='Class', palette='bright', style='Class', markers=['o', '^', 's'])
plt.title('LDA降维结果')
plt.xlabel('判别成分 1')
plt.ylabel('判别成分 2')
plt.legend(title='Class')
plt.grid(True)
plt.show()

# 四、t-SNE（t-分布随机邻域嵌入）

# 标准化数据
scaler_tsne = StandardScaler()
X_tsne_scaled = scaler_tsne.fit_transform(X)

# 执行t-SNE，降到2维
tsne = TSNE(n_components=2, perplexity=30, learning_rate=200, random_state=42, verbose=1)
tsne_2D = tsne.fit_transform(X_tsne_scaled)

# 创建DataFrame用于绘图
df_tsne = pd.DataFrame(tsne_2D, columns=['Dim1', 'Dim2'])
df_tsne['Class'] = y

# 可视化t-SNE结果
plt.figure(figsize=(8, 6))
sns.scatterplot(data=df_tsne, x='Dim1', y='Dim2', hue='Class', palette='bright', style='Class', markers=['o', '^', 's'])
plt.title('t-SNE降维结果')
plt.xlabel('维度 1')
plt.ylabel('维度 2')
plt.legend(title='Class')
plt.grid(True)
plt.show()

