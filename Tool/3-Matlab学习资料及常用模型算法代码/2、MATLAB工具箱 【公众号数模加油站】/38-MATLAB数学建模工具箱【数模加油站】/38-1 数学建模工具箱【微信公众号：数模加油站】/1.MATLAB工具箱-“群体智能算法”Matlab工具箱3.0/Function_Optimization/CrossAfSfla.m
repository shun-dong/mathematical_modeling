function [Population2] = CrossAfSfla(Population1,Neighbor,fitness,Parmaters,maxmin,Lb,Ub)
% 鱼群交叉操作
% 输入参数：
% Population1 - 初始种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% Neighbor - 感知范围最大个体
%     Neighbor.X - 近邻适应度最大个体
%     Neighbor.F - 近邻适应度最大个体适应度
%     Neighbor.I - 近邻索引
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% 输出参数：
% Population2 - 更新种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

popsize = length(Population1.F);

Par1 = Population1.X;
F_Par1 = Population1.F;
Par2 = Neighbor.X;
F_Par2 = Neighbor.F;

[Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

%--------------------
% 条件最强

F4 = [F_Par1,F_Off1,F_Off2];
[F_Off,I4] = max(F4,[],2);                      % 交叉操作2+2选择
Off = zeros(size(Off1));
for i = 1:popsize
    tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

Population2.X = Off;
Population2.F = F_Off;

%--------------------

I5 = find(F_Par1==F_Off);                       % 第一次无改善的下标
if ~isempty(I5)
    
    c = length(I5);
    Par1 = Population1.X(I5,:);
    F_Par1 = Population1.F(I5);
    Par2 = repmat(Population1.x,c,1);
    F_Par2 = repmat(Population1.f,c,1);
    
    [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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
    
    F4 = [F_Par1,F_Off1,F_Off2];
    [F_Off,I4] = max(F4,[],2);                     % 交叉操作2+2选择
    Off = zeros(size(Off1));
    for i = 1:c
        tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
        Off(i,:) = tmp4(I4(i),:);
    end
    
    Population2.X(I5,:) = Off;                  % 子群第二次更新
    Population2.F(I5) = F_Off;
    
    I6 = find(F_Par1==F_Off);                   % 第二次无改善的下标
    if ~isempty(I6)
        
        c = length(I6);
        tmp5 = Initialize(fitness,Parmaters,maxmin,Lb,Ub,c);
        % 种群初始化
        % 输入参数:
        % fitness - 优化函数
        % Parmaters - 函数参数   
        % maxmin - 极值类型：1最大值，-1最小值
        % Lb - 参数下界
        % Ub - 参数上界
        % popsize - 种群规模
        % 输出参数:
        % Population - 种群
        %     Population.X - 种群(行向量)
        %     Population.F - 种群适应度(已降序排列)
        %     Population.x - 最优个体
        %     Population.f - 最优个体适应度          

        Population2.X(I5(I6),:) = tmp5.X;
        Population2.F(I5(I6)) = tmp5.F;
    end
end

%--------------------

[Population2.f,imax] = max(Population2.F);
Population2.x = Population2.X(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end

