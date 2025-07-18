clc;
clear;

%% 线性回归
% Problem 1: 对 A 进行变换使得结果尽量接近 B —— 多元线性回归示例

% 1. 读入数据
A = xlsread('A.xlsx');    % 大小 10000 × 100
B = xlsread('B.xlsx');    % 大小 10000 × 1
[n, p] = size(A);

% 2. 构造回归矩阵（含常数项）
X = [ones(n,1), A];       % n×(p+1)

% 3. 最小二乘估计 β = [β0; β1…βp]
beta = X \ B;             % (p+1)×1

% 4. 预测与残差
B_hat     = X * beta;     
residuals = B - B_hat;    

% 5. 误差指标计算
MSE   = mean(residuals.^2);
RMSE  = sqrt(MSE);
MAE   = mean(abs(residuals));
SSres = sum(residuals.^2);
SStot = sum((B - mean(B)).^2);
R2    = 1 - SSres/SStot;

fprintf('=== 回归性能指标 ===\n');
fprintf('MSE   = %.4e\n', MSE);
fprintf('RMSE  = %.4e\n', RMSE);
fprintf('MAE   = %.4e\n', MAE);
fprintf('R^2   = %.4f\n\n', R2);

% 6. 残差标准误差、t 检验（可选）
sigma2 = SSres / (n - (p+1));
CovB   = sigma2 * inv(X'*X);
seBeta = sqrt(diag(CovB));
tStat  = beta ./ seBeta;
pVals  = 2*(1 - tcdf(abs(tStat), n-(p+1)));


%% 7. 可视化

% 7.1 实际 vs 预测
figure('Name','Actual vs Predicted','Color','w');
scatter(B, B_hat, 10, 'filled');
hold on;
minv = min([B;B_hat]); maxv = max([B;B_hat]);
plot([minv,maxv],[minv,maxv],'r--','LineWidth',1.5);
xlabel('实际 B','FontSize',12);
ylabel('预测 \^B','FontSize',12);
title('实际值 vs 预测值','FontSize',14);
grid on; box on;

% 7.2 残差直方图
figure('Name','Residuals Histogram','Color','w');
histogram(residuals, 50, 'Normalization','pdf','FaceColor',[.2 .6 .8]);
xlabel('残差','FontSize',12);
ylabel('概率密度','FontSize',12);
title('残差分布','FontSize',14);
grid on;

% 7.3 残差序列图
figure('Name','Residuals vs Index','Color','w');
plot(residuals, '.', 'MarkerSize',6);
xlabel('样本索引','FontSize',12);
ylabel('残差','FontSize',12);
title('残差序列','FontSize',14);
yline(0,'r--');
grid on;

% 7.4 残差 QQ-Plot
figure('Name','QQ-Plot of Residuals','Color','w');
qqplot(residuals);
title('残差 QQ-Plot','FontSize',14);


% 残差的均值和标准差
mean_residual = mean(residuals);
std_residual = std(residuals);

fprintf('=== 残差统计 ===\n');
fprintf('残差均值 = %.4e\n', mean_residual);
fprintf('残差标准差 = %.4e\n', std_residual);

% 残差 vs 预测值图（可以用于检测模型偏差）
figure('Name','Residuals vs Predicted','Color','w');
scatter(B_hat, residuals, 10, 'filled');
xlabel('预测值 \hat{B}', 'FontSize', 12);
ylabel('残差', 'FontSize', 12);
title('残差与预测值的关系', 'FontSize', 14);
grid on;
% 残差大于 3 标准差的点可能是离群点 如果 VIF > 10，则说明该变量可能存在共线性问题。
outliers = abs(residuals) > 3 * std_residual;
figure('Name','离群点检测','Color','w');
scatter(1:n, residuals, 10, 'filled');
hold on;
plot(1:n, 3 * std_residual * ones(n, 1), 'r--', 'LineWidth', 1.5);
plot(1:n, -3 * std_residual * ones(n, 1), 'r--', 'LineWidth', 1.5);
xlabel('样本索引', 'FontSize', 12);
ylabel('残差', 'FontSize', 12);
title('残差与离群点检测', 'FontSize', 14);
grid on;
