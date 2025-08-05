function [Population2] = CrossSfla(Population1,fitness,Parmaters,maxmin,Lb,Ub,x,f)
% SFLA交叉操作
% 输入参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% x - 总种群最优个体
% f - 总种群最优个体适应度
% 输出参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度(已降序排列)
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

%--------------------------------------

d = size(Population1.X,1);
c = d-1;

X2 = Population1.X;
F2 = Population1.F;
for i = 1:c
    Par1 = X2(end,:);
    Par2 = X2(1,:);
    F_Par1 = F2(end);
    F_Par2 = F2(1);
    
    %--------------------------------------
    
    [Off1,F_Off1] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
    % 交叉运算子函数
    % 输入参数：
    % Par1 - 父代群体1
    % F_Par1 - 父代群体1适应度
    % Par2 - 父代群体2
    % F_Par2 - 父代群体2适应度
    % fitness - 优化函数
    % Parmaters - 函数参数   
    % maxmin - 极值类型：1最大值，-1最小值
    % Lb - 参数下界
    % Ub - 参数上界
    % 输出参数：
    % Off1 - 子代群体1
    % F_Off1 - 子代群体1适应度
    % Off2 - 子代群体2
    % F_Off2 - 子代群体2适应度
    
    if F_Off1>F_Par1
        X2(end,:) = Off1;
        F2(end) = F_Off1;
    else
        Par2 = x;
        F_Par2 = f;
        
        [Off1,F_Off1] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
        % 交叉运算子函数
        % 输入参数：
        % Par1 - 父代群体1
        % F_Par1 - 父代群体1适应度
        % Par2 - 父代群体2
        % F_Par2 - 父代群体2适应度
        % fitness - 优化函数
        % Parmaters - 函数参数   
        % maxmin - 极值类型：1最大值，-1最小值
        % Lb - 参数下界
        % Ub - 参数上界
        % 输出参数：
        % Off1 - 子代群体1
        % F_Off1 - 子代群体1适应度
        % Off2 - 子代群体2
        % F_Off2 - 子代群体2适应度
        
        if F_Off1>F_Par1
            X2(end,:) = Off1;
            F2(end) = F_Off1;
        else
            tmp = Initialize(fitness,Parmaters,maxmin,Lb,Ub,1);
            X2(end,:) = tmp.X;
            F2(end) = tmp.F;            
        end
    end
    [F2,I2] = sort(F2,'descend');
    X2 = X2(I2,:);
end

Population2.X = X2;
Population2.F = F2;
Population2.x = X2(1,:);
Population2.f = F2(1);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end


