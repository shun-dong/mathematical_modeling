import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LinearRegression
from sklearn.impute import KNNImputer
from sklearn.experimental import enable_iterative_imputer  # noqa
from sklearn.impute import IterativeImputer

plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号


# 设置随机种子以确保结果可重复
np.random.seed(42)

# 生成时间序列数据
time = np.arange(1, 101)  # 时间点 1 到 100

# 生成一个正弦波加上一些噪声作为原始数据
original_data = 10 * np.sin(2 * np.pi * time / 25) + np.random.randn(100)

# 人为制造缺失值（20%的缺失）
num_missing = int(0.2 * len(original_data))  # 20个缺失值
missing_indices = np.random.choice(len(original_data), num_missing, replace=False)
data_with_missing = original_data.copy()
data_with_missing[missing_indices] = np.nan

# 创建 DataFrame
df = pd.DataFrame({
    'Time': time,
    'Value': data_with_missing
})

# 绘制原始数据和含缺失值的数据
plt.figure(figsize=(12, 6))
plt.plot(df['Time'], original_data, '-b', label='原始数据')
plt.plot(df['Time'], df['Value'], 'or', label='含缺失值', markersize=5)
plt.title('原始数据与含缺失值的数据')
plt.xlabel('时间')
plt.ylabel('值')
plt.legend()
plt.grid(True)
plt.show()

# 二、线性插值（Linear Interpolation）
df['Linear_Imputed'] = df['Value'].interpolate(method='linear')

# 三、多项式插值（Polynomial Interpolation）
# 选择多项式阶数为2（可以根据数据调整）
poly_order = 2
# 通过非缺失数据拟合多项式
valid = df['Value'].notnull()
p = np.polyfit(df.loc[valid, 'Time'], df.loc[valid, 'Value'], poly_order)
# 使用多项式预测缺失值
poly_values = np.polyval(p, df.loc[~valid, 'Time'])
df.loc[~valid, 'Polynomial_Imputed'] = poly_values

# 四、样条插值（Spline Interpolation）
df['Spline_Imputed'] = df['Value'].interpolate(method='spline', order=3)

# 五、前向填充/后向填充（Forward Fill / Backward Fill）
# 修改这里，使用 .ffill() 和 .bfill() 方法替代 fillna(method='ffill') 和 fillna(method='bfill')
df['Forward_Fill'] = df['Value'].ffill()
df['Backward_Fill'] = df['Value'].bfill()

# 六、多重插补（Multiple Imputation）
# 使用 Iterative Imputer 进行多重插补，基于线性回归
iter_imputer = IterativeImputer(random_state=0)
df['Multiple_Imputed'] = iter_imputer.fit_transform(df[['Value']])

# 七、K-邻近插补（K-Nearest Neighbors Imputation）
# 使用 K=5
knn_imputer = KNNImputer(n_neighbors=5)
df['KNN_Imputed'] = knn_imputer.fit_transform(df[['Value']])

# 八、模型预测插补（Model-Based Imputation）
df['Model_Imputed'] = df['Value'].copy()
missing = df['Model_Imputed'].isnull()

if missing.any():
    # 训练线性回归模型
    model = LinearRegression()
    model.fit(df.loc[~missing, ['Time']], df.loc[~missing, 'Value'])
    # 预测缺失值
    predicted = model.predict(df.loc[missing, ['Time']])
    df.loc[missing, 'Model_Imputed'] = predicted

# 九、结果可视化对比
plt.figure(figsize=(14, 10))
plt.plot(df['Time'], original_data, '-b', label='原始数据', linewidth=2)
plt.plot(df['Time'], df['Value'], 'or', label='含缺失值', markersize=5)

# 绘制各补充方法的数据
plt.plot(df['Time'], df['Linear_Imputed'], '-g', label='线性插值')
plt.plot(df['Time'], df['Polynomial_Imputed'], '--m', label='多项式插值')
plt.plot(df['Time'], df['Spline_Imputed'], '-.c', label='样条插值')
plt.plot(df['Time'], df['Forward_Fill'], ':k', label='前向填充')
plt.plot(df['Time'], df['Backward_Fill'], ':y', label='后向填充')
plt.plot(df['Time'], df['Multiple_Imputed'], '-^', color=[0.5, 0, 0.5], label='多重插补')
plt.plot(df['Time'], df['KNN_Imputed'], '-s', color=[0, 0.5, 0], label='KNN 插补')
plt.plot(df['Time'], df['Model_Imputed'], '-d', color=[0.5, 0.5, 0], label='模型预测插补')

plt.title('缺失值补充方法对比')
plt.xlabel('时间')
plt.ylabel('值')
plt.legend(loc='best')
plt.grid(True)
plt.show()
