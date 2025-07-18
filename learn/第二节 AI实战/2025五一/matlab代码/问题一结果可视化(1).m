% visualize_fixed_results.m
% 直接使用给定的回归性能指标和残差统计，生成可视化对比图

% 模型名称
model_names = {'Poly', 'Power', 'Exp', 'Lasso', 'SVR', 'Tree'};

% 1. 性能指标（MSE, RMSE, MAE, R2）
MSEs  = [3.0093, NaN,    Inf,   3.0395, 3.0469, 24.9034];
RMSEs = [1.7347, NaN,    Inf,   1.7434, 1.7455, 4.9903];
MAEs  = [1.5001, NaN,    6.4594e+198, 1.5087, 1.5117, 3.5973];
R2s   = [0.9892, NaN,    -Inf,  0.9891, 0.9891, 0.9109];

% 2. 残差统计（mean, std）
mean_res = [-1.9782e-13, NaN, -6.4594e+198, -2.4194e-13, 0.0075, 2.9763e-14];
std_res  = [1.7348,       NaN,   Inf,        1.7435,      1.7456, 4.9906];

%% 绘图部分

% A. MSE / RMSE / MAE 分组柱状图
figure('Name','Error Metrics Comparison','Position',[100 100 1000 600]);
metrics_matrix = [MSEs; RMSEs; MAEs]';
hb = bar(metrics_matrix, 'grouped','LineWidth',1.2);
colormap(parula);
grid on; box on;
set(gca, 'XTickLabel', model_names, 'FontSize',12);
legend({'MSE','RMSE','MAE'}, 'Location','northoutside','Orientation','horizontal','FontSize',12);
ylabel('Error Value','FontSize',14);
title('各模型 MSE / RMSE / MAE 对比','FontSize',16);

% 标注数值
for i = 1:size(metrics_matrix,1)
    for j = 1:size(metrics_matrix,2)
        x = hb(j).XEndPoints(i);
        y = hb(j).YEndPoints(i);
        if ~isnan(metrics_matrix(i,j)) && ~isinf(metrics_matrix(i,j))
            text(x, y, sprintf('%.2e', metrics_matrix(i,j)), ...
                'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',9);
        end
    end
end

% B. R^2 单独柱状图
figure('Name','R^2 Comparison','Position',[200 200 800 400]);
bar(R2s,'FaceColor',[0.2 0.6 0.8],'LineWidth',1.2);
grid on; box on;
set(gca, 'XTickLabel', model_names, 'FontSize',12);
ylabel('R^2','FontSize',14);
title('各模型 R^2 对比','FontSize',16);
ylim([0 1]);
for i = 1:length(R2s)
    if ~isnan(R2s(i)) && ~isinf(R2s(i))
        text(i, R2s(i)+0.03, sprintf('%.3f',R2s(i)), ...
            'HorizontalAlignment','center','FontSize',10);
    end
end

% C. 残差均值 vs 标准差 散点图
figure('Name','Residual Mean vs Std','Position',[300 300 800 500]);
scatter(mean_res, std_res, 80, 'filled');
text(mean_res+0.01, std_res, model_names, 'FontSize',10);
grid on; box on;
xlabel('Residual Mean','FontSize',14);
ylabel('Residual Std','FontSize',14);
title('各模型残差均值与标准差','FontSize',16);

% D. 美化字体
set(findall(gcf,'-property','FontName'),'FontName','Microsoft YaHei');
set(findall(gcf,'-property','FontSize'),'FontSize',12);
