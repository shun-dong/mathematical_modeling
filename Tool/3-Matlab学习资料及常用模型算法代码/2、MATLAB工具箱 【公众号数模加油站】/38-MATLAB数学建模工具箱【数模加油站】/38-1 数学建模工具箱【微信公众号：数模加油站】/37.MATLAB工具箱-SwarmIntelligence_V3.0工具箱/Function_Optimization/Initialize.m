function [Population] = Initialize(fitness,Parmaters,maxmin,Lb,Ub,popsize,seed)
% 种群初始化
% 输入参数:
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% popsize - 种群规模
% seed - 初始化随机种子
% 输出参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 针对PSO特别定义
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Fp - 历史最优适应度

%---------------------------------------

if nargin<7
    seed = sum(100*clock);
end

rand('state',seed);     % 初始化随机数种子
% rng('shuffle');

num = length(Lb);                   % 参数个数
X = zeros(popsize,num);
for j = 1:num
    a = Lb(j);
    b = Ub(j);
    X(:,j) = a + (b-a).*rand(popsize,1);
    
%     X(:,j) = a-1+ceil((b-a+1).*rand(popsize,1));      % 整数解
end
if isempty(Parmaters)
    F = maxmin*feval(fitness,X);
else
    F = maxmin*feval(fitness,X,Parmaters);
end

%---------------------------------------

Population.X = X;
Population.F = F;
[Population.f,imax] = max(F);
Population.x = X(imax,:);

%---------------------------------------
% 针对PSO特别定义

Population.V = zeros(size(X));
Population.Xp = X;
Population.Fp = F;

end
