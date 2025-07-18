import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LassoCV
from sklearn.svm import SVR
from sklearn.tree import DecisionTreeRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler
from scipy.stats import linregress

# 1. 数据读取
A = pd.read_excel('A.xlsx', header=None).values  # 大小 10000 × 100
B = pd.read_excel('B.xlsx', header=None).values  # 大小 10000 × 1
n, p = A.shape


# 2. 计算回归性能指标和残差统计量
def calculate_metrics(residuals, B, B_hat):
    MSE = np.mean(residuals ** 2)
    RMSE = np.sqrt(MSE)
    MAE = np.mean(np.abs(residuals))
    SSres = np.sum(residuals ** 2)
    SStot = np.sum((B - np.mean(B)) ** 2)
    R2 = 1 - SSres / SStot
    metrics = {'MSE': MSE, 'RMSE': RMSE, 'MAE': MAE, 'R^2': R2}
    residual_stats = {'Mean Residual': np.mean(residuals), 'Std Residual': np.std(residuals)}
    return metrics, residual_stats


# 3. 多项式回归（二次项）
X_poly = np.column_stack([np.ones(n), A, A[:, 1:] ** 2])  # 添加二次项
beta_poly = np.linalg.lstsq(X_poly, B, rcond=None)[0]
B_hat_poly = X_poly.dot(beta_poly)
residuals_poly = B - B_hat_poly
metrics_poly, residual_stats_poly = calculate_metrics(residuals_poly, B, B_hat_poly)

# 4. 幂函数回归 (log-log 变换) - 防止对数变换错误
A_loglog = np.log(A + 1e-6)  # 对数据加上一个小常数，避免零值
X_loglog = np.column_stack([np.ones(n), A_loglog])  # 取对数变换
beta_loglog = np.linalg.lstsq(X_loglog, np.log(B + 1e-6), rcond=None)[0]  # 对B也加小常数
B_hat_loglog = np.exp(X_loglog.dot(beta_loglog))
residuals_loglog = B - B_hat_loglog
metrics_loglog, residual_stats_loglog = calculate_metrics(residuals_loglog, B, B_hat_loglog)

# 5. 指数/对数回归 (log-linear 变换) - 防止对数变换错误
A_log = np.log(A + 1e-6)  # 对数据加上一个小常数，避免零值
X_log = np.column_stack([np.ones(n), A_log])  # 取对数变换
beta_log = np.linalg.lstsq(X_log, B, rcond=None)[0]
B_hat_log = np.exp(X_log.dot(beta_log))  # 指数函数拟合
residuals_log = B - B_hat_log
metrics_log, residual_stats_log = calculate_metrics(residuals_log, B, B_hat_log)

# 6. Lasso 回归 (使用交叉验证自动选λ)
lasso = LassoCV(cv=10).fit(A, B)
B_hat_lasso = lasso.predict(A)
residuals_lasso = B - B_hat_lasso
metrics_lasso, residual_stats_lasso = calculate_metrics(residuals_lasso, B, B_hat_lasso)

# 7. 支持向量回归 (SVR)
svr_model = SVR(kernel='linear')
svr_model.fit(A, B.ravel())
B_hat_svr = svr_model.predict(A)
residuals_svr = B - B_hat_svr
metrics_svr, residual_stats_svr = calculate_metrics(residuals_svr, B, B_hat_svr)

# 8. 决策树回归
tree_model = DecisionTreeRegressor()
tree_model.fit(A, B)
B_hat_tree = tree_model.predict(A)
residuals_tree = B - B_hat_tree
metrics_tree, residual_stats_tree = calculate_metrics(residuals_tree, B, B_hat_tree)

# 9. 输出回归性能指标和残差统计
print("\n=== Lasso 回归 ===")
print(metrics_lasso)
print(residual_stats_lasso)

print("\n=== 支持向量回归 (SVR) ===")
print(metrics_svr)
print(residual_stats_svr)

print("\n=== 决策树回归 ===")
print(metrics_tree)
print(residual_stats_tree)

print("\n=== 多项式回归性能指标 ===")
print(metrics_poly)
print(residual_stats_poly)

print("\n=== 幂函数回归性能指标 ===")
print(metrics_loglog)
print(residual_stats_loglog)

print("\n=== 指数/对数回归性能指标 ===")
print(metrics_log)
print(residual_stats_log)
