function [M] = Initialize(X,c)
% 从c-1聚类的结果得到c聚类的代表点
% 参考文献
% 边肇祺 编著. 模式识别[M]. 北京:清华大学出版社. 1999. p236
%
% 输入参数:
% X - 样本点,每一列一个点
% c - 聚类中心数
%
% 输出参数:
% M - 聚类中心,每一列一个点

n = size(X,2);              % 样本总数
M = zeros(size(X,1),c);     % 从c-1聚类的结果得到c聚类的代表点
M(:,1) = mean(X,2);
Dis = zeros(1,n);
for i = 2:c
    for k = 1:n
        d0 = inf;
        for j = 1:i-1
            d1 = norm(X(:,k)-M(:,j));
            if d1<d0
                d0 = d1;
            end
        end
        Dis(k) = d0;
    end
    [tmp,m] = max(Dis);
    M(:,i) = X(:,m);
end

% figure;
% plot(X(1,:),X(2,:),'k.'); hold on; 
% plot(M(1,:),M(2,:),'r.','MarkerSize',30); hold off;
% title('从c-1聚类的结果得到c聚类的代表点')
