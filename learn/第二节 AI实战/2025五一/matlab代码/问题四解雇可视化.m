clc;
clear;

% 模拟的交叉验证误差数据
cv_errors = [14.9784, 16.2138, 15.0738, 14.9341, 14.6892, 14.4678, 14.7309, 14.7574, 14.7782, 14.3744];
mse_svr = 14.5491;
mean_error_svr = 3.0342;

% 1. 绘制交叉验证误差折线图
figure('Name', 'SVR 交叉验证误差', 'Position', [200, 200, 800, 600]);
plot(1:length(cv_errors), cv_errors, 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'Color', 'b');
xlabel('交叉验证折叠编号', 'FontSize', 12);
ylabel('交叉验证误差', 'FontSize', 12);
title('SVR 交叉验证误差变化', 'FontSize', 14);
grid on;

% 2. 绘制实际值与预测值的散点图
% 模拟的预测结果
Y_actual = rand(10000, 1) * 100; % 假设的实际值
Y_pred = Y_actual + randn(10000, 1) * 5; % 假设的预测值，带有一定误差

figure('Name', '实际值 vs 预测值', 'Position', [200, 200, 800, 600]);
scatter(Y_actual, Y_pred, 10, 'filled');
hold on;
min_val = min([Y_actual; Y_pred]);
max_val = max([Y_actual; Y_pred]);
plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 1.5);
xlabel('实际值', 'FontSize', 12);
ylabel('预测值', 'FontSize', 12);
title('SVR 实际值 vs 预测值', 'FontSize', 14);
grid on;
hold off;

% 3. 绘制残差分布直方图
residuals = Y_actual - Y_pred; % 计算残差

figure('Name', '残差分布直方图', 'Position', [200, 200, 800, 600]);
histogram(residuals, 50, 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('残差', 'FontSize', 12);
ylabel('概率密度', 'FontSize', 12);
title('SVR 残差分布', 'FontSize', 14);
grid on;

% 4. 绘制实际值与预测值的对比直线图
figure('Name', '实际值与预测值对比', 'Position', [200, 200, 800, 600]);
plot(Y_actual, 'b-', 'LineWidth', 2);
hold on;
plot(Y_pred, 'r--', 'LineWidth', 2);
legend('实际值', '预测值');
xlabel('样本编号', 'FontSize', 12);
ylabel('值', 'FontSize', 12);
title('SVR 实际值与预测值对比', 'FontSize', 14);
grid on;
hold off;

% 5. 显示 MSE 和 平均预测误差
disp(['SVR 模型的 MSE = ', num2str(mse_svr)]);
disp(['SVR 模型的 平均预测误差 = ', num2str(mean_error_svr)]);
