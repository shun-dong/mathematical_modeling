
clc;
clear;

% 1. 读入数据
X = xlsread('5-X.xlsx');   % 大小 10000 × 100
Y = xlsread('5-Y.xlsx');   % 大小 10000 × 1

% 2. 数据标准化（可选）
X_normalized = (X - min(X)) ./ (max(X) - min(X));  % 数据归一化到 [0, 1]

% 3. 使用 NMF 进行降维
k = 50;  % 设置降维后的维度
[W, H] = nnmf(X_normalized, k);  % W 是 n×k，H 是 k×p

% 4. 使用降维后的数据与目标变量建立模型：线性回归、Lasso回归、SVR、决策树回归

% 添加常数项（截距项）
X_reg = [ones(size(W, 1), 1), W];  % 10000 × (k+1)

% 4.1 线性回归
[b_lin, ~, ~, ~, stats_lin] = regress(Y, X_reg);  % 线性回归
Y_hat_lin = X_reg * b_lin;  % 预测值
MSE_lin = mean((Y - Y_hat_lin).^2);
R2_lin = stats_lin(1);  % R^2

% 4.2 Lasso回归
[beta_lasso, FitInfo_lasso] = lasso(X_reg, Y, 'Lambda', 0.1);  % Lasso回归
Y_hat_lasso = X_reg * beta_lasso + FitInfo_lasso.Intercept;  % 预测值
MSE_lasso = mean((Y - Y_hat_lasso).^2);
SSres_lasso = sum((Y - Y_hat_lasso).^2);
SStot_lasso = sum((Y - mean(Y)).^2);
R2_lasso = 1 - SSres_lasso/SStot_lasso;  % R^2

% 4.3 支持向量回归 (SVR)
svr_model = fitrsvm(W, Y, 'KernelFunction', 'linear', 'Standardize', true);  % SVR模型
Y_hat_svr = predict(svr_model, W);  % 预测值
MSE_svr = mean((Y - Y_hat_svr).^2);
SSres_svr = sum((Y - Y_hat_svr).^2);
SStot_svr = sum((Y - mean(Y)).^2);
R2_svr = 1 - SSres_svr/SStot_svr;  % R^2

% 4.4 决策树回归
tree_model = fitrtree(W, Y);  % 决策树回归
Y_hat_tree = predict(tree_model, W);  % 预测值
MSE_tree = mean((Y - Y_hat_tree).^2);
SSres_tree = sum((Y - Y_hat_tree).^2);
SStot_tree = sum((Y - mean(Y)).^2);
R2_tree = 1 - SSres_tree/SStot_tree;  % R^2

% 5. 打印结果
fprintf('=== 线性回归 ===\n');
fprintf('MSE = %.4f, R^2 = %.4f\n', MSE_lin, R2_lin);
fprintf('=== Lasso 回归 ===\n');
fprintf('MSE = %.4f, R^2 = %.4f\n', MSE_lasso, R2_lasso);
fprintf('=== 支持向量回归 (SVR) ===\n');
fprintf('MSE = %.4f, R^2 = %.4f\n', MSE_svr, R2_svr);
fprintf('=== 决策树回归 ===\n');
fprintf('MSE = %.4f, R^2 = %.4f\n', MSE_tree, R2_tree);

% 6. 可视化：模型对比
figure;
subplot(1,2,1);
bar([R2_lin, R2_lasso, R2_svr, R2_tree], 'FaceColor', [0.2, 0.6, 0.8]);
set(gca, 'XTickLabel', {'Linear', 'Lasso', 'SVR', 'Decision Tree'}, 'FontSize', 12);
ylabel('R^2', 'FontSize', 12);
title('不同模型的拟合优度', 'FontSize', 14);
grid on;

subplot(1,2,2);
bar([MSE_lin, MSE_lasso, MSE_svr, MSE_tree], 'FaceColor', [0.8, 0.2, 0.2]);
set(gca, 'XTickLabel', {'Linear', 'Lasso', 'SVR', 'Decision Tree'}, 'FontSize', 12);
ylabel('MSE', 'FontSize', 12);
title('不同模型的 MSE', 'FontSize', 14);
grid on;

% 7. 模型稳定性和适用性评估：通过交叉验证计算模型的稳定性
cv_lasso = crossval(@(X_train, Y_train, X_test, Y_test) ...
    mean((Y_test - (X_test * beta_lasso + FitInfo_lasso.Intercept)).^2), X_reg, Y);
cv_svr = crossval(@(X_train, Y_train, X_test, Y_test) ...
    mean((Y_test - predict(fitrsvm(X_train, Y_train, 'KernelFunction', 'linear', 'Standardize', true), X_test)).^2), X_reg, Y);
cv_tree = crossval(@(X_train, Y_train, X_test, Y_test) ...
    mean((Y_test - predict(fitrtree(X_train, Y_train), X_test)).^2), X_reg, Y);


fprintf('Lasso回归的交叉验证误差： %.4f\n', cv_lasso);
fprintf('SVR的交叉验证误差： %.4f\n', cv_svr);
fprintf('决策树的交叉验证误差： %.4f\n', cv_tree);

