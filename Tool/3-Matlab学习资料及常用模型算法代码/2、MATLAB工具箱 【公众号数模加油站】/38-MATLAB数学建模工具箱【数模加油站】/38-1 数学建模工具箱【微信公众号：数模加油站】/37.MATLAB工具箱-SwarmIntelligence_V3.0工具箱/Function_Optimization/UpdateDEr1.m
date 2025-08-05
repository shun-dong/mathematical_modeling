function [Population2] = UpdateDEr1(Population1,fitness,Parmaters,maxmin,Lb,Ub,K,CR)
% DEr1算法，种群更新
% 输入参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% Parmaters - 函数参数
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% K - 缩放因子
% CR - 交叉概率
% 输出参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

X1 = Population1.X;
F1 = Population1.F;
x1 = Population1.x;
f1 = Population1.f;

[X2,F2] = UpdateDEr1Sub(X1,F1,fitness,Parmaters,maxmin,Lb,Ub,K,CR);
% 种群更新
% 输入参数：
% Par - 父代群体
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% K - 缩放因子
% CR - 交叉概率
% 输出参数：
% Off - 子代群体
% F_Off - 子代群体适应度

%--------------------------------------------------------------------------

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end
