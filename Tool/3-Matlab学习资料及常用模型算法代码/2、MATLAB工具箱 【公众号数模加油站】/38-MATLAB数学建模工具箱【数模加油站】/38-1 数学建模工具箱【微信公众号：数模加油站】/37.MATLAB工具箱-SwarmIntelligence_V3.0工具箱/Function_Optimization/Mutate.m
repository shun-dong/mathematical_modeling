function [Population2] = Mutate(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu)
% 变异操作
% 输入参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 针对PSO特别定义
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Fp - 历史最优适应度
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% Pm - 自适应变异概率范围
% ismu - 是否变异操作（缺省为1）
% 输出参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度(已降序排列)
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 针对PSO特别定义
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Fp - 历史最优适应度

if nargin<8
    ismu = 1;
end

if ismu==0
    Population2 = Population1;
    return;
end

%--------------------------------------

% Pm = [0.01,0.1];                   % 自适应变异概率范围(如果是标量,则概率固定)
[XMutate,FMutate,I] = MutateIndex(Population1.X,Population1.F,Pm);
% 由自适应变异概率概率Pm，求参与变异群体PMutate，及适应度FMutate
% 输入参数：
% X1 - 群体（每一行一个个体）
% F1 - 群体适应度（列向量）
% Pm - 自适应变异概率范围
% 输出参数：
% XMutate - 变异群体（每一行一个个体）
% FMutate - 变异群体适应度（列向量）
% I - 变异群体序号

m = length(I);                          % 变异的个体数

X2 = Population1.X;
F2 = Population1.F;

[tmp,imax] = max(F2);
if m>0
    Par = XMutate;
    F_Par = FMutate;
    
    [Off,F_Off] = MutateSub(Par,fitness,Parmaters,maxmin,Lb,Ub);
    % 输入参数：
    % Par - 父代群体
    % fitness - 优化函数
    % Parmaters - 函数参数   
    % maxmin - 极值类型：1最大值，-1最小值
    % Lb - 参数下界
    % Ub - 参数上界
    % 输出参数：
    % Off - 子代群体
    % F_Off - 子代群体适应度
    
    for i = 1:m
        if I(i)==imax && F_Par(i)>F_Off(i)    % 最佳个体1+1变异
            Off(i,:) = Par(i,:);
            F_Off(i) = F_Par(i);
        end
    end

    F2(I) = F_Off;
    X2(I,:) = Off;
    
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

%--------------------------------------
% 针对PSO的特别处理

try
    Population2.V = Population2.X-Population1.X;
    
    Xp2 = Population1.Xp;
    Fp2 = Population1.Fp;
    X2 = Population2.X;
    F2 = Population2.F;
    
    for i = 1:length(F2)
        if F2(i)>Fp2(i)
            Xp2(i,:) = X2(i,:);
            Fp2(i) = F2(i);
        end
    end
    Population2.Xp = Xp2;
    Population2.Fp = Fp2;
    
    [Population2.f,imax] = max(Fp2);
    Population2.x = Xp2(imax,:);
catch
end

end
