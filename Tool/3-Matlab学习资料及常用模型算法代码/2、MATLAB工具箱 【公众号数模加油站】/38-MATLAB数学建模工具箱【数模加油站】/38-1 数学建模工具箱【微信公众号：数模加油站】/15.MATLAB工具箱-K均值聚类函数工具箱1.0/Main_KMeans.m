
% 标准 K-Means 聚类 - 主函数
% 参考文献
% Richard O.Duda 著,李宏东 译. 模式分类[M]. 北京:机械工业出版社. 2003. p424

clc
clear all
close all

%--------------------------------------------------------------------------
% 产生聚类样本

m = 200;                            % 每一类样本个数
X1 = randn(2,m);
X2 = randn(2,m)+repmat([0;4],1,m);
X3 = randn(2,m)+repmat([6;2],1,m);
X = [X1,X2,X3];                     % 每一列为一个样本

%--------------------------------------------------------------------------
% 函数调用

c = 7;                             % 聚类数
tmax = 20;                         % 最大迭代次数

%--------------------------------------------------------------------------
% 标准 K-Means 聚类

M = Initialize(X,c);                % 从c-1聚类的结果得到c聚类的代表点

% function [M] = Initialize(X,c)
% 从c-1聚类的结果得到c聚类的代表点
% 参考文献: Richard O.Duda 著,李宏东 译. 模式分类[M]. 北京:机械工业出版社. 2003. p424
% 输入参数:
% X - 样本点,每一列一个点
% c - 聚类中心数
%
% 输出参数:
% M - 聚类中心,每一列一个点

k = 0;
Je = zeros(1,tmax);
while k<tmax
    
    k = k+1;    
    [T,tmp,je,M] = KMeans(X,M);     % 输出聚类结果和代价函数收敛曲线
    Je(k) = je;                     % 代价函数赋值
    
    if k>2 & Je(k)==Je(k-1)
        break;                      % 连续2次迭代,je不变,提前结束
    end
    
end
Je = Je(1:k);

% function [T,N,je,M2] = KMeans(X,M)
% K-Means 聚类
% 参考文献: Richard O.Duda 著,李宏东 译. 模式分类[M]. 北京:机械工业出版社. 2003. p424
% 输入参数:
% X  - 样本点,每一列一个点
% M  - 聚类中心,每一列一个点
%
% 输出参数:
% T  - 类别标签,行矢量
% N  - 每一类个数
% je - 代价函数值
% M2 - 新聚类中心,每一列一个点

%--------------------------------------------------------------------------
% 结果显示

figure;
plot(Je,'b.-'); xlabel('t'); ylabel('Je'); title('代价函数')

S = {'b.','go','kx','c+','m*','ys','rd'};               % 类别标记
figure; hold on; axis equal;
for j = 1:c
    I = find(T==j); 
    N(j) = length(I);
    plot(X(1,I),X(2,I),S{j});                           % 类别输出
    plot(M(1,j),M(2,j),'r.','MarkerSize',30);           % 类别中心
end
title(['K-Mean Clustering, c = ',num2str(c)]); hold off;
N






