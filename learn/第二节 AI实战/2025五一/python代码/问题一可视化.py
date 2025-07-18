import numpy as np
import matplotlib.pyplot as plt

# 1. 性能指标（MSE, RMSE, MAE, R2）
MSEs  = [3.0093, np.nan, np.inf, 3.0395, 3.0469, 24.9034]
RMSEs = [1.7347, np.nan, np.inf, 1.7434, 1.7455, 4.9903]
MAEs  = [1.5001, np.nan, 6.4594e+198, 1.5087, 1.5117, 3.5973]
R2s   = [0.9892, np.nan, -np.inf, 0.9891, 0.9891, 0.9109]

# 2. 残差统计（mean, std）
mean_res = [-1.9782e-13, np.nan, -6.4594e+198, -2.4194e-13, 0.0075, 2.9763e-14]
std_res  = [1.7348, np.nan, np.inf, 1.7435, 1.7456, 4.9906]

# 模型名称
model_names = ['Poly', 'Power', 'Exp', 'Lasso', 'SVR', 'Tree']
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号
# 绘图部分
# A. MSE / RMSE / MAE 分组柱状图
plt.figure(figsize=(10, 6))
metrics_matrix = np.array([MSEs, RMSEs, MAEs]).T
width = 0.2  # 柱状图宽度
x = np.arange(len(model_names))

# 为每个模型的三个指标绘制柱状图
hb1 = plt.bar(x - width, metrics_matrix[:, 0], width=width, label='MSE', linewidth=1.2)
hb2 = plt.bar(x, metrics_matrix[:, 1], width=width, label='RMSE', linewidth=1.2)
hb3 = plt.bar(x + width, metrics_matrix[:, 2], width=width, label='MAE', linewidth=1.2)

plt.xticks(x, model_names, fontsize=12)
plt.ylabel('Error Value', fontsize=14)
plt.title('各模型 MSE / RMSE / MAE 对比', fontsize=16)
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.05), fontsize=12)
plt.grid(True, axis='y', linestyle='--')

# 标注数值
for i in range(len(model_names)):
    for j in range(3):
        height = metrics_matrix[i, j]
        if not np.isnan(height) and not np.isinf(height):
            plt.text(x[i] + (j - 1) * width, height, f'{height:.2e}', ha='center', va='bottom', fontsize=9)

# B. R^2 单独柱状图
plt.figure(figsize=(8, 4))
plt.bar(np.arange(len(model_names)), R2s, color='skyblue', linewidth=1.2)
plt.xticks(np.arange(len(model_names)), model_names, fontsize=12)
plt.ylabel('R^2', fontsize=14)
plt.title('各模型 R^2 对比', fontsize=16)
plt.ylim(0, 1)
for i, r2 in enumerate(R2s):
    if not np.isnan(r2) and not np.isinf(r2):
        plt.text(i, r2 + 0.03, f'{r2:.3f}', ha='center', fontsize=10)
plt.grid(True, axis='y', linestyle='--')

# C. 残差均值 vs 标准差 散点图
plt.figure(figsize=(8, 5))
plt.scatter(mean_res, std_res, s=80, c='r', marker='o')
for i, name in enumerate(model_names):
    plt.text(mean_res[i] + 0.01, std_res[i], name, fontsize=10)
plt.xlabel('Residual Mean', fontsize=14)
plt.ylabel('Residual Std', fontsize=14)
plt.title('各模型残差均值与标准差', fontsize=16)
plt.grid(True)

# D. 美化字体
plt.rcParams['font.family'] = 'Microsoft YaHei'
plt.rcParams['font.size'] = 12

plt.tight_layout()
plt.show()
