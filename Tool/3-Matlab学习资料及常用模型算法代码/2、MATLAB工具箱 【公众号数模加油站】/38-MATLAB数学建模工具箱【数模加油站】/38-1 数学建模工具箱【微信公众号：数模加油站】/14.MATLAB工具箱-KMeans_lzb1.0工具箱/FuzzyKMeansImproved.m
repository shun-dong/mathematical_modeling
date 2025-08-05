function [T,N,jf,M2] = FuzzyKMeansImproved(X,M,b)
% 改进的模糊 K-Means 聚类
% 参考文献
% 边肇祺 编著. 模式识别[M]. 北京:清华大学出版社. 1999. p281
%
% 输入参数:
% X  - 样本点,每一列一个点
% M - 聚类中心,每一列一个点(老的)
% b  - 参数b
%
% 输出参数:
% T  - 类别标签,行矢量
% N  - 每一类个数
% jf - 代价函数值
% M2 - 聚类中心,每一列一个点(新的)

[d,n] = size(X);                        % 样本点数
[d,c] = size(M);
U = zeros(c,n);                         % 隶属度矩阵
for i = 1:c
    tmp1 = X - repmat(M(:,i),1,n);
    U(i,:) = sum(tmp1.^2);              % 样本对中心的距离的平方
end
U = 1./(U+1e-50);
U = U.^(1/(b-1));
U = U/sum(U(:))*n;                      % 隶属度矩阵

T = zeros(1,n);
D = full(compet(U));
for j = 1:n
    for i = 1:c
        if (D(i,j)==1)
            T(j) = i;
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

        jf = 0;
        for i = 1:c
            jf = jf + sum(U(i,:).^b.*sum((X - repmat(M(:,i),1,n)).^2));
        end

        if nargout>3

            M2 = zeros(d,c);
            for i = 1:c
                tmp2 = U(i,:).^b;
                tmp3 = sum(X.*repmat(tmp2,d,1),2)/sum(tmp2);
                M2(:,i) = tmp3;                     % 中心矢量更新(批量更新)
            end

        end
    end
end


