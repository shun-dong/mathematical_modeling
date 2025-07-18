clc;
clear;

%% 线性回归
% Problem 1: 对 A 进行变换使得结果尽量接近 B —— 多元回归示例

% 1. 读入数据
A = xlsread('A.xlsx');    % 大小 10000 × 100
B = xlsread('B.xlsx');    % 大小 10000 × 1
[n, p] = size(A);


% 2. 构造回归矩阵（含常数项）
X = [ones(n,1), A];       % n×(p+1)


%% --- 1. 多项式回归（二次项）
X_poly = [X, X(:,2:end).^2];  % 添加二次项
beta_poly = X_poly \ B;       % 最小二乘估计
B_hat_poly = X_poly * beta_poly;
residuals_poly = B - B_hat_poly;
[metrics_poly, residual_stats_poly] = calculate_metrics(residuals_poly, B, B_hat_poly);


%% --- 2. 幂函数回归 (log-log 变换)
X_loglog = [ones(n, 1), log(A)];  % 取对数变换
beta_loglog = X_loglog \ log(B);
B_hat_loglog = exp(X_loglog * beta_loglog);
residuals_loglog = B - B_hat_loglog;
[metrics_loglog, residual_stats_loglog] = calculate_metrics(residuals_loglog, B, B_hat_loglog);

%% --- 3. 指数/对数回归 (log-linear 变换)
X_log = [ones(n, 1), log(A + 1)];  % 取对数变换
beta_log = X_log \ B;
B_hat_log = exp(X_log * beta_log);  % 指数函数拟合
residuals_log = B - B_hat_log;
[metrics_log, residual_stats_log] = calculate_metrics(residuals_log, B, B_hat_log);

%% --- 4. Lasso 回归
% 这里对 A（不含常数项）和 B 做 Lasso 回归，使用 10 折交叉验证自动选 λ
[beta_lasso, FitInfo] = lasso(A, B, 'CV', 10);
% 取交叉验证误差最小对应的系数
idxLambdaMinMSE = FitInfo.IndexMinMSE;
coef = beta_lasso(:, idxLambdaMinMSE);
intercept = FitInfo.Intercept(idxLambdaMinMSE);
% 预测
B_hat_lasso = A * coef + intercept;
residuals_lasso = B - B_hat_lasso;
[metrics_lasso, residual_stats_lasso] = calculate_metrics(residuals_lasso, B, B_hat_lasso);

%% --- 5. 支持向量回归 (SVR)
% 直接对 A 和 B 建立线性核 SVR
svr_model = fitrsvm(A, B, 'KernelFunction', 'linear', 'Standardize', true);
B_hat_svr = predict(svr_model, A);
residuals_svr = B - B_hat_svr;
[metrics_svr, residual_stats_svr] = calculate_metrics(residuals_svr, B, B_hat_svr);

%% --- 6. 决策树回归
tree_model = fitrtree(A, B);
B_hat_tree = predict(tree_model, A);
residuals_tree = B - B_hat_tree;
[metrics_tree, residual_stats_tree] = calculate_metrics(residuals_tree, B, B_hat_tree);

%% --- 输出对比
fprintf('\n=== Lasso 回归 ===\n');
disp(metrics_lasso);
disp(residual_stats_lasso);

fprintf('\n=== 支持向量回归 (SVR) ===\n');
disp(metrics_svr);
disp(residual_stats_svr);

fprintf('\n=== 决策树回归 ===\n');
disp(metrics_tree);
disp(residual_stats_tree);

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

