import numpy as np
import pandas as pd
from scipy.stats import chi2
from sklearn.decomposition import PCA

# 1. 读取数据
A = pd.read_excel('Data.xlsx', header=None).values  # 大小 10000 × 100
n, p = A.shape

# 2. 计算相关矩阵
correlation_matrix = np.corrcoef(A, rowvar=False)


# 3. KMO 检验
# KMO 检验需要计算局部和整体 KMO 值，这里通过计算局部 KMO 和总 KMO
def kmo_test(correlation_matrix):
    # 计算相关矩阵的逆矩阵（Fisher Z转换后求逆）
    inv_corr_matrix = np.linalg.inv(correlation_matrix)

    # 计算局部 KMO
    kmo_numerator = np.sum(np.square(inv_corr_matrix), axis=1)
    kmo_denominator = np.sum(np.square(correlation_matrix), axis=1)
    local_kmo = kmo_numerator / kmo_denominator

    # 总 KMO值
    total_kmo = np.sum(kmo_numerator) / np.sum(kmo_denominator)

    return total_kmo


# 获取KMO值
kmo_value = kmo_test(correlation_matrix)


# 4. Bartlett's Test (球形检验)
def bartlett_sphericity_test(correlation_matrix):
    # 使用PCA计算Bartlett的球形检验
    pca = PCA(n_components=p)
    pca.fit(A)
    chi_square_stat = (n - 1 - (2 * p + 5) / 6) * np.sum(np.square(pca.components_))  # 计算卡方统计量
    df = p * (p - 1)  # 自由度
    p_value = 1 - chi2.cdf(chi_square_stat, df)  # p值

    return p_value, chi_square_stat


# 获取 Bartlett 检验的 p 值和卡方统计量
p_val_bartlett, stat_bartlett = bartlett_sphericity_test(correlation_matrix)

# 5. 输出结果
print(f'=== KMO 检验 ===')
print(f'KMO 检验值 = {kmo_value:.4f}')

print(f'=== Bartlett 球形检验 ===')
print(f'卡方统计量 = {stat_bartlett:.4f}')
print(f'p 值 = {p_val_bartlett:.4f}')
