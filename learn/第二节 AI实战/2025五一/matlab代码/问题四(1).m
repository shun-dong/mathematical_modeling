clc;
clear;

% 1. 读入数据
X = xlsread('4-X.xlsx');   % 大小 10000 × 100
Y = xlsread('4-Y.xlsx');   % 大小 10000 × 1

% 2. 数据标准化（可选）
% 数据标准化：对数据进行归一化
X_normalized = (X - min(X)) ./ (max(X) - min(X));  % 数据归一化到 [0, 1]

% 3. 添加常数项（截距项）
X_reg = [ones(size(X_normalized, 1), 1), X_normalized];

% --- 支持向量回归（SVR）
best_C_svr = 1;  % 初始 C 参数
best_eps_svr = 0.1;  % 初始 epsilon 参数
best_R2_svr = -Inf;

% 使用网格搜索进行自适应参数调整
C_values = logspace(-5, 5, 5);  % C 参数范围
eps_values = logspace(-5, 1, 5);  % epsilon 参数范围

% 创建一个 waitbar
h_svr = waitbar(0, '正在调整SVR的参数...', 'Name', 'SVR调参', 'WindowStyle', 'modal');

for i = 1:length(C_values)
    for j = 1:length(eps_values)
        C = C_values(i);
        eps = eps_values(j);
        
        % 更新进度条
        waitbar((i-1)*length(eps_values) + j / (length(C_values) * length(eps_values)), h_svr, ...
            sprintf('正在调整SVR参数: %.2f%%', ((i-1)*length(eps_values) + j) / (length(C_values) * length(eps_values)) * 100));
        
        svr_model = fitrsvm(X_reg, Y, 'KernelFunction', 'linear', 'Standardize', true, 'BoxConstraint', C, 'Epsilon', eps);
        Y_hat_svr = predict(svr_model, X_reg);  % 预测值
        % 计算 R^2（决定系数）
        SSres = sum((Y - Y_hat_svr).^2);
        SStot = sum((Y - mean(Y)).^2);
        R2_svr = 1 - SSres/SStot;
        
        % 寻找最优的C和epsilon
        if R2_svr > best_R2_svr
            best_R2_svr = R2_svr;
            best_C_svr = C;
            best_eps_svr = eps;
        end
    end
end

% 关闭进度条
close(h_svr);

fprintf('最优SVR C = %.5f, epsilon = %.5f, 最优 R^2 = %.4f\n', best_C_svr, best_eps_svr, best_R2_svr);

% SVR模型的评估
svr_model = fitrsvm(X_reg, Y, 'KernelFunction', 'linear', 'Standardize', true, 'BoxConstraint', best_C_svr, 'Epsilon', best_eps_svr);
Y_hat_svr = predict(svr_model, X_reg);
MSE_svr = mean((Y - Y_hat_svr).^2);
mean_error_svr = mean(abs(Y - Y_hat_svr));  % 平均预测误差
fprintf('SVR模型的 MSE = %.4f, 平均预测误差 = %.4f\n', MSE_svr, mean_error_svr);


cv_svr = crossval(@(X_train, Y_train, X_test, Y_test) ...
    mean((Y_test - predict(fitrsvm(X_train, Y_train, 'KernelFunction', 'linear', 'Standardize', true, ...
    'BoxConstraint', best_C_svr, 'Epsilon', best_eps_svr), X_test)).^2), X_reg, Y);

fprintf('SVR的交叉验证误差： %.4f\n', cv_svr);
