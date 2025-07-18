
clc;
clear;
%% 1、初步数据分析

% MATLAB 脚本：分析 A.xlsx (10000×100) 与 B.xlsx (10000×1) 的分布特征

% 1. 读入数据（请将 A.xlsx, B.xlsx 放在当前工作目录）
A = xlsread('A.xlsx');    % 大小 10000 × 100
B = xlsread('B.xlsx');    % 大小 10000 × 1

% 2. 计算描述性统计量：均值、标准差、偏度、峰度
meansA = mean(A);         % 1 × 100
stdsA  = std(A);
skewA  = skewness(A);
kurtA  = kurtosis(A);

meanB  = mean(B);
stdB   = std(B);
skewB  = skewness(B);
kurtB  = kurtosis(B);

% 3. 打印统计量
fprintf('Col\tMean\tStd\tSkewness\tKurtosis\n');
for i = 1:size(A,2)
    fprintf('%3d\t%8.4f\t%8.4f\t%8.4f\t%8.4f\n', ...
        i, meansA(i), stdsA(i), skewA(i), kurtA(i));
end
fprintf(' B \t%8.4f\t%8.4f\t%8.4f\t%8.4f\n', meanB, stdB, skewB, kurtB);

% 4. 可视化：A 的直方图矩阵
figure('Name','Histogram of A columns');
tiledlayout(10,10,'TileSpacing','compact','Padding','compact');
for i = 1:size(A,2)
    nexttile;
    histogram(A(:,i));
    title(sprintf('A_{%d}',i),'FontSize',8);
    ax = gca; ax.XTick = [];
    ax.YTick = [];
end

% 5. 可视化：B 的直方图与箱线图
figure('Name','Distribution of B');
subplot(1,2,1);
histogram(B);
title('Histogram of B');

subplot(1,2,2);
boxplot(B);
title('Boxplot of B');

% 6. 可选：绘制 QQ-plot 检验正态性
figure('Name','QQ Plots');
subplot(1,2,1);
qqplot(A(:));
title('QQ-Plot of all A data');

subplot(1,2,2);
qqplot(B);
title('QQ-Plot of B data');


%% 2、分布方式检验
% 读入 A.xlsx（10000×100）
A = readmatrix('A.xlsx');
[~, p] = size(A);

% 显著性水平
alpha = 0.05;

% 3. 预分配输出
isNormal = false(p,1);
pVal     = zeros(p,1);

% 4. 对每一列做 Lilliefors 正态性检验
for i = 1:p
    x = A(:,i);
    % h = 0 表示未拒绝“服从正态”假设
    [h, pv] = lillietest(x, 'Alpha', alpha);
    isNormal(i) = (h == 0);
    pVal(i)     = pv;
end

% 汇总结果
T = table((1:p)', isNormal, pVal, ...
    'VariableNames', {'Column','IsNormal','pValue'});
disp(T);


columns = 1:length(isNormal);

% 1. p 值 Bar Plot
figure('Name','P-Values Bar Plot','Color','w');
bar(columns, pVal, 'FaceColor',[.2 .6 .8]);
hold on;
yline(alpha,'r--','LineWidth',2,'DisplayName','\alpha=0.05');
hold off;
xlabel('列编号','FontSize',12);
ylabel('p 值','FontSize',12);
title('Lilliefors 检验各列 p 值','FontSize',14);
legend('show','Location','northeast');
grid on;

% 2. 正态 vs 非正态 Pie Chart
counts = [sum(isNormal), sum(~isNormal)];
figure('Name','Normal vs Non-normal Pie','Color','w');
pie(counts, {'正态列','非正态列'});
title('各列正态性检验结果分布','FontSize',14);

%3 . p 值分布直方图
figure('Name','P-Value Histogram','Color','w');
edges = 0:0.05:1;
histogram(pVal, edges, 'FaceColor',[.8 .4 .2]);
xlabel('p 值','FontSize',12);
ylabel('频数','FontSize',12);
title('p 值分布直方图','FontSize',14);
grid on;

% 4. 示例 QQ-Plot（正态列与非正态列各选 4 个）
normCols = find(isNormal);
nonCols  = find(~isNormal);
selN     = normCols(1:min(4,end));
selNN    = nonCols(1:min(4,end));

figure('Name','QQ-Plots 示例','Color','w');
for k = 1:length(selN)
    subplot(2,4,k);
    qqplot(A(:,selN(k)));
    title(['正态列 QQ: ' num2str(selN(k))],'FontSize',10);
end
for k = 1:length(selNN)
    subplot(2,4,4+k);
    qqplot(A(:,selNN(k)));
    title(['非正态列 QQ: ' num2str(selNN(k))],'FontSize',10);
end
sgtitle('QQ-Plot 示例：正态 vs 非正态','FontSize',14);

%%
% 3 相关性分析
% 3.1. 读入数据
A = xlsread('A.xlsx');    % 大小 10000 × 100
B = xlsread('B.xlsx');    % 大小 10000 × 1
[~, p] = size(A);

%3.2. 计算 Pearson 相关系数及 p 值
corrCoeff = zeros(p,1);
pVal      = zeros(p,1);
for i = 1:p
    [R, P] = corrcoef(A(:,i), B);
    corrCoeff(i) = R(1,2);
    pVal(i)      = P(1,2);
end

%3.3. 绘制精美可视化

cols = 1:p;

% 3.1 Bar Plot：各列相关系数
figure('Name','Pearson Correlation Bar Plot','Color','w','Position',[100 100 1000 400]);
bar(cols, corrCoeff, 'FaceColor',[.2 .6 .8],'EdgeColor',[.1 .3 .4]);
hold on;
yline(0,'k--','LineWidth',1.5);
xlabel('A 列编号','FontSize',12,'FontWeight','bold');
ylabel('Pearson \rho','FontSize',12,'FontWeight','bold');
title('A(:,i) 与 B 的 Pearson 相关系数','FontSize',14,'FontWeight','bold');
grid on;
set(gca,'FontSize',11);

% 3.2 Histogram：相关系数分布
figure('Name','Histogram of Correlation Coefficients','Color','w','Position',[200 200 600 400]);
histogram(corrCoeff, 20, 'FaceColor',[.8 .4 .2],'EdgeColor','none','Normalization','probability');
xlabel('\rho 值','FontSize',12,'FontWeight','bold');
ylabel('频率','FontSize',12,'FontWeight','bold');
title('相关系数分布直方图','FontSize',14,'FontWeight','bold');
grid on;
set(gca,'FontSize',11);

% 3.3 Pie Chart：正相关 vs 负相关 列数
posCount = sum(corrCoeff > 0);
negCount = sum(corrCoeff < 0);
figure('Name','Positive vs Negative Correlations','Color','w','Position',[300 300 500 400]);
pie([posCount, negCount], {'正相关','负相关'});
colormap([0.2 0.6 0.8; 0.8 0.3 0.3]);
title('正相关列与负相关列占比','FontSize',14,'FontWeight','bold');


% 3.5 Scatter Plots：Top4 正负相关示例
[~, idxPos] = maxk(corrCoeff,4);
[~, idxNeg] = mink(corrCoeff,4);

figure('Name','Scatter Examples: Top+ and Top-','Color','w','Position',[100 100 1000 600]);
for k = 1:4
    subplot(2,4,k);
    scatter(A(:,idxPos(k)), B, 10, 'filled');
    lsline; % 添加拟合直线
    xlabel(sprintf('A(:,%d)',idxPos(k)),'FontSize',10);
    ylabel('B','FontSize',10);
    title(sprintf('正相关 #%d: \\rho=%.2f', idxPos(k), corrCoeff(idxPos(k))),'FontSize',12);
    grid on;
    
    subplot(2,4,4+k);
    scatter(A(:,idxNeg(k)), B, 10, 'filled');
    lsline;
    xlabel(sprintf('A(:,%d)',idxNeg(k)),'FontSize',10);
    ylabel('B','FontSize',10);
    title(sprintf('负相关 #%d: \\rho=%.2f', idxNeg(k), corrCoeff(idxNeg(k))),'FontSize',12);
    grid on;
end

% 计算每列与 B 的 Pearson 相关系数
rho = zeros(p,1);
for i = 1:p
    R = corrcoef(A(:,i), B);
    rho(i) = R(1,2);
end
% 按绝对相关度降序排序，取前 10 列
[~, sortIdx] = sort(abs(rho), 'descend');
top10 = sortIdx(1:10);

% 显示结果
fprintf('相关性最好的10列及其相关系数：\n');
for k = 1:10
    col = top10(k);
    fprintf('第 %d 列，ρ = %.4f\n', col, rho(col));
end

