function [T,N,je,M2] = KMeans(X,M)
% K-Means 聚类
% 参考文献
% Richard O.Duda 著,李宏东 译. 模式分类[M]. 北京:机械工业出版社. 2003. p424
%
% 输入参数:
% X  - 样本点,每一列一个点
% M  - 聚类中心,每一列一个点
%
% 输出参数:
% T  - 类别标签,行矢量
% N  - 每一类个数
% je - 代价函数值
% M2 - 新聚类中心,每一列一个点


[d,n] = size(X);                        % 样本点数
[d,c] = size(M);
D = zeros(c,n);                         % 距离矩阵
for i = 1:c
    tmp1 = X - repmat(M(:,i),1,n);
    D(i,:) = sum(tmp1.^2);              % 样本对中心的距离的平方
end
D = full(compet(1./(D+1e-50)));         % 距离最近取1,其它为0

T = zeros(1,n);
for j = 1:n
    for i = 1:c
        if (D(i,j)==1)
            T(j) = i;                   % 类别标签
            break;
        end
    end
end

if nargout>1
    
    N = zeros(1,c);
    for i = 1:c
        J = find(T==i);
        nj = length(J);
        N(i) = nj;                          % 每一类个数
    end
    
    if nargout>2

        je = 0;
        for i = 1:c
            J = find(T==i);
            nj = length(J);
            tmp1 = X(:,J)-repmat(M(:,i),1,nj);
            je = je + sum(tmp1(:).^2);          % 代价函数
        end
        
        if nargout>3

            M2 = zeros(d,c);
            for i = 1:c
                J = find(T==i);
                tmp2 = mean(X(:,J),2);
                M2(:,i) = tmp2;                     % 中心矢量更新(批量更新)
            end
            
            
            J = find(sum(M2)==0);                   % 有可能某些类一个样本都没有，直接删除
            M2(:,J) = [];
            
        end
    end
end

