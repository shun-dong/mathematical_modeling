clc;
clear;

%% 线性回归
% Problem 1: 对 A 进行变换使得结果尽量接近 B —— 多元回归示例

% 1. 读入数据
A = xlsread('A.xlsx');    % 大小 10000 × 100
B = xlsread('B.xlsx');    % 大小 10000 × 1
[n, p] = size(A);

% 2. 选择相关性最好的 10 列（给定列和相关系数）
selected_cols = [4, 30, 39, 15, 47, 74, 93, 61, 69, 98];  % 根据相关系数选择的列
A_selected = A(:, selected_cols);  % 提取与 B 相关性最好的 10 列

% 3. 构造回归矩阵（含常数项）
X = [ones(n, 1), A_selected];       % n×(10+1)

%% --- 1. 多项式回归（二次项）
X_poly = [X, X(:,2:end).^2];  % 添加二次项
beta_poly = X_poly \ B;       % 最小二乘估计
B_hat_poly = X_poly * beta_poly;
residuals_poly = B - B_hat_poly;
[metrics_poly, residual_stats_poly] = calculate_metrics(residuals_poly, B, B_hat_poly);

%% --- 2. 幂函数回归 (log-log 变换)
X_loglog = [ones(n, 1), log(A_selected)];  % 取对数变换
beta_loglog = X_loglog \ log(B);
B_hat_loglog = exp(X_loglog * beta_loglog);
residuals_loglog = B - B_hat_loglog;
[metrics_loglog, residual_stats_loglog] = calculate_metrics(residuals_loglog, B, B_hat_loglog);

%% --- 3. 指数/对数回归 (log-linear 变换)
X_log = [ones(n, 1), log(A_selected + 1)];  % 取对数变换
beta_log = X_log \ B;
B_hat_log = exp(X_log * beta_log);  % 指数函数拟合
residuals_log = B - B_hat_log;
[metrics_log, residual_stats_log] = calculate_metrics(residuals_log, B, B_hat_log);


%% 输出回归性能指标和残差统计
fprintf('=== 多项式回归性能指标 ===\n');
disp(metrics_poly);
disp(residual_stats_poly);

fprintf('=== 幂函数回归性能指标 ===\n');
disp(metrics_loglog);
disp(residual_stats_loglog);

fprintf('=== 指数/对数回归性能指标 ===\n');
disp(metrics_log);
disp(residual_stats_log);


