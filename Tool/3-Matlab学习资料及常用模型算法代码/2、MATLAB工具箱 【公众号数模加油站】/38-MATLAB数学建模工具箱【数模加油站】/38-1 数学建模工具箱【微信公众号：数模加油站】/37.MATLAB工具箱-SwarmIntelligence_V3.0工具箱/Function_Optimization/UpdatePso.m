function [Population2] = UpdatePso(Population1,fitness,Parmaters,maxmin,Lb,Ub,gen,maxgen,c1,c2,w1,w2)
% PSO算法，种群更新
% 输入参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Xp - 历史最优适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% gen - 当前代数
% maxgen - 最大进化代数
% c1 - 加速系数1
% c2 - 加速系数2
% w1 - 惯性权1
% w2 - 惯性权2
% 输出参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Fp - 历史最优适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

X1 = Population1.X;
F1 = Population1.F;
V1 = Population1.V;
Xp1 = Population1.Xp;
Fp1 = Population1.Fp;
x1 = Population1.x;
f1 = Population1.f;

popsize = length(F1);

%--------------------------------------------------------------------------

W = linspace(w1,w2,round(maxgen*0.75));
if gen<=round(maxgen*0.75)                      % 系数加权
    w = W(gen);
else
    w = w2;
end

%--------------------------------------------------------------------------


MV = 0.2*(Ub-Lb);                               % 最大速度取变化范围的10%~20%
V2 = w.*V1+c1.*rand(size(X1)).*(Xp1-X1)+c2.*rand(size(X1)).*(repmat(x1,popsize,1)-X1);
V2 = min(V2,repmat(MV',popsize,1));             % 限速

X2 = X1+V2;
X2 = max(repmat(Lb',popsize,1),X2);           % 限幅
X2 = min(repmat(Ub',popsize,1),X2);
if isempty(Parmaters)
    F2 = maxmin*feval(fitness,X2);                  % 扰动种群的适应度
else
    F2 = maxmin*feval(fitness,X2,Parmaters);                  % 扰动种群的适应度
end

%--------------------------------------------------------------------------

tmp1 = [F2,Fp1];                                
[Fp2,I] = max(tmp1,[],2);                       % 更新历史最优
Xp2 = zeros(size(Xp1));
for i = 1:popsize
    tmp2 = [X2(i,:);Xp1(i,:)];
    Xp2(i,:) = tmp2(I(i),:);
end

[f2,imax] = max(Fp2);                           % 更新全局最优
x2 = Xp2(imax,:);

%--------------------------------------------------------------------------

Population2.X = X2;
Population2.F = F2;
Population2.V = V2;
Population2.Xp = Xp2;
Population2.Fp = Fp2;
Population2.x = x2;
Population2.f = f2;

end
