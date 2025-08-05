function [Population2,I] = Select(Population1)
% 锦标赛选择
% 输入参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 输出参数：
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% I - 选中个体的索引数组

X1 = Population1.X;
F1 = Population1.F;
popsize = length(F1);

X2 = X1;
F2 = F1;
I = zeros(popsize,1);
for i = 1:popsize
    j = ceil(popsize*rand());
    J = [1:j-1,j+1:popsize];
    k = J(ceil((popsize-1)*rand()));
    
    if F1(j)>F1(k)
        F2(i) = F1(j);
        X2(i,:) = X1(j,:);
        I(i) = j;
    else
        F2(i) = F1(k);
        X2(i,:) = X1(k,:);
        I(i) = k;
    end
end

Population2.X = X2;
Population2.F = F2;
Population2.x = Population1.x;
Population2.f = Population1.f;

end