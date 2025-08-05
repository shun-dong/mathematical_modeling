function [Neighbor] = GetNeighbor(Population,neighbor_number)
% 鱼群算法，计算个体邻域
% 输入参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% neighbor_number - 近邻个数（缺省为popsize/2）
% 输出参数:
% Neighbor - 感知范围最大个体
%     Neighbor.X - 近邻适应度最大个体
%     Neighbor.F - 近邻适应度最大个体适应度
%     Neighbor.I - 近邻索引

[popsize,num] = size(Population.X);
if nargin<2
    neighbor_number = round(popsize/2);
end

D = zeros(popsize,popsize);                 % 计算距离矩阵，自己的距离为inf
for i = 1:popsize
    for j = i:popsize
        if (i==j)
            D(i,j) = inf;
        else
            D(i,j) = norm(Population.X(i,:)-Population.X(j,:));
        end
    end
end
D = D+D';

%--------------------

[tmp1,I] = sort(D,2,'ascend');
J = I(:,1:neighbor_number);               % 每个个体有neighbor_number个近邻
tmp2 = Population.F(J);
[FM,IM] = max(tmp2,[],2);                    % 找出适应度最大的近邻

%--------------------

Neighbor.MaxX = zeros(popsize,num);
for i = 1:popsize
    k = J(i,IM(i));                       % 提取适应度最大的近邻
    Neighbor.X(i,:) = Population.X(k,:);
end
Neighbor.F = FM;
Neighbor.I = IM;

end
