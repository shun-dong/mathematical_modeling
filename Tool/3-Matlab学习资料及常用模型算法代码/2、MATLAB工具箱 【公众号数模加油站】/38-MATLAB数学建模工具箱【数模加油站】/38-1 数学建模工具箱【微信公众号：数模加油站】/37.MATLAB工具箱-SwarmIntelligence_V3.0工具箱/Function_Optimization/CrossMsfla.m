function [Population2] = CrossMsfla(Population1,fitness,Parmaters,maxmin,Lb,Ub,x,f)
% MSFLA交叉操作
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

%---------------------------------------

d = size(Population1.X,1);
c = d-1;

X2 = Population1.X;
F2 = Population1.F;

Par1 = X2(2:d,:);
Par2 = repmat(X2(1,:),c,1);
F_Par1 = F2(2:d);
F_Par2 = repmat(F2(1),c,1);

% [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

%---------------------------------------
% 条件最强

% F4 = [F_Par1,F_Off1,F_Off2];
% [F_Off,I4] = max(F4,[],2);            % 交叉操作2+2选择
% Off = zeros(size(Off1));
% for i = 1:c
%     tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
%     Off(i,:) = tmp4(I4(i),:);
% end

F4 = [F_Par1,F_Off1];
[F_Off,I4] = max(F4,[],2);            % 交叉操作2+2选择
Off = zeros(size(Off1));
for i = 1:c
    tmp4 = [Par1(i,:);Off1(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

X2(2:d,:) = Off;                      % 子群更新
F2(2:d) = F_Off;

%---------------------------------------

I5 = find(F_Par1==F_Off);              % 第一次无改善的下标
if ~isempty(I5)
    
    c = length(I5);
    Par1 = Par1(I5,:);
    Par2 = repmat(x,c,1);
    F_Par1 = F_Par1(I5);
    F_Par2 = repmat(f,c,1);
    
%     [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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
    
%     F4 = [F_Par1,F_Off1,F_Off2];
%     [F_Off,I4] = max(F4,[],2);             % 交叉操作2+2选择
%     Off = zeros(size(Off1));
%     for i = 1:c
%         tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
%         Off(i,:) = tmp4(I4(i),:);
%     end
    
    F4 = [F_Par1,F_Off1];
    [F_Off,I4] = max(F4,[],2);             % 交叉操作2+2选择
    Off = zeros(size(Off1));
    for i = 1:c
        tmp4 = [Par1(i,:);Off1(i,:)];
        Off(i,:) = tmp4(I4(i),:);
    end    
    
    X2(I5+1,:) = Off;                      % 子群第二次更新
    F2(I5+1) = F_Off;
    
    I6 = find(F_Par1==F_Off);              % 第二次无改善的下标
    if ~isempty(I6)
        c = length(I6);
        
        tmp = Initialize(fitness,Parmaters,maxmin,Lb,Ub,c);
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
        
        X2(I5(I6)+1,:) = tmp.X;
        F2(I5(I6)+1) = tmp.F;
    end
end

%---------------------------------------

Par1 = X2(1,:);                             % 子群最大值更新
Par2 = x;
F_Par1 = F2(1);
F_Par2 = f;

% [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

% F4 = [F_Par1,F_Off1,F_Off2];
% [F_Off,i4] = max(F4,[],2);            % 交叉操作2+2选择
% tmp4 = [Par1;Off1;Off2];
% Off = tmp4(i4,:);

F4 = [F_Par1,F_Off1];
[F_Off,i4] = max(F4,[],2);            % 交叉操作2+2选择
tmp4 = [Par1;Off1];
Off = tmp4(i4,:);

X2(1,:) = Off;
F2(1) = F_Off;
    
%---------------------------------------

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end

