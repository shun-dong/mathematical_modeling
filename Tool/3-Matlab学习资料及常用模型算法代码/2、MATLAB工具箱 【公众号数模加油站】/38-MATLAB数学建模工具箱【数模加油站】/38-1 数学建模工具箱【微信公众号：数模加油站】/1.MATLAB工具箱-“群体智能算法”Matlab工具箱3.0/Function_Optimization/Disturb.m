function [Population2] = Disturb(Population1,fitness,Parmaters,maxmin,Lb,Ub,quick)
% 扰动操作
% 输入参数:
% Population - 种群
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
% quick - 最优解加速次数（缺省为20）
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

if nargin<7
    quick = 20;
end

if quick==0
    Population2 = Population1;
    return;
end

X1 = Population1.X;
F1 = Population1.F;

for j = 1:1
    
    [popsize,num] = size(X1);                       % 种群规模,参数个数
    D = (max(X1)-min(X1))/2;                        % 扰动半径
    
    [X2,F2] = DisturbSub(X1,fitness,Parmaters,maxmin,Lb,Ub,D);
    % 输入参数：
    % Par - 父代群体
    % fitness - 优化函数
    % Parmaters - 函数参数
    % maxmin - 极值类型：1最大值，-1最小值
    % Lb - 参数下界
    % Ub - 参数上界
    % D - 扰动半径（行向量，对应每一维）
    % T - 变异位置（长度必须与size(Par,1)相同），缺省位置随机
    % 输出参数：
    % Off - 子代群体
    % F_Off - 子代群体适应度
    
    [F2,K] = max([F1,F2],[],2);
    for i = 1:popsize
        tmp = [X1(i,:);X2(i,:)];
        X2(i,:) = tmp(K(i),:);
    end
    
    X1 = X2;
    F1 = F2;
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,IMAX] = max(F2);
Population2.x = X2(IMAX,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

%--------------------------------------
% 最优基因对应的表现型的每个参数再加一个方向的扰动, 再对最优个体替换

if quick>1
    
    x = Population2.x;
    f = Population2.f;
    n = num; % ceil(num*rand());          % n个取优
    m = quick-1;                                % m次迭代
    
    for i = 1:m
        
        x_array = repmat(x,n,1);
        T = 1:n;                          % 变异位置  1~digit(列数)
        
        [x_array2,f_array2] = DisturbSub(x_array,fitness,Parmaters,maxmin,Lb,Ub,D,T);
        % 输入参数：
        % Par - 父代群体
        % fitness - 优化函数
        % Parmaters - 函数参数
        % maxmin - 极值类型：1最大值，-1最小值
        % Lb - 参数下界
        % Ub - 参数上界
        % D - 扰动半径（行向量，对应每一维）
        % T - 变异位置（长度必须与size(Par,1)相同），缺省位置随机
        % 输出参数：
        % Off - 子代群体
        % F_Off - 子代群体适应度
        
        [f_max,imax] = max(f_array2);
        x_max = x_array2(imax,:);
        
        if (f_max>f)
            x = x_max;
            f = f_max;
        end
    end
    
    if (f>Population2.f)
        Population2.x = x;
        Population2.f = f;
        Population2.X(IMAX,:) = x;
        Population2.F(IMAX) = f;
    end
    
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
