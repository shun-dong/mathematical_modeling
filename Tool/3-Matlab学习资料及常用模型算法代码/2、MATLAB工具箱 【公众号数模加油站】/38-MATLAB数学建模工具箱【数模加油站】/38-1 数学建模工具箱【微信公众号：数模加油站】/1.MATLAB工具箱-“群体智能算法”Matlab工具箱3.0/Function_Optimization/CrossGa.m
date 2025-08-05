function [Population2] = CrossGa(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pc)
% 遗传交叉操作
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
% Pc - 自适应交叉概率范围
% 输出参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度(已降序排列)
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

% Pc = [0.6,0.9];                    % 自适应交叉概率范围(如果是标量,则概率固定)
[XCross,FCross,I] = CrossIndex(Population1.X,Population1.F,Pc);
% 由自适应交叉概率概率Pc，求参与交叉群体PCross，及适应度FCross
% 输入参数：
% X1 - 群体（行向量）
% F1 - 群体适应度
% Pc - 自适应交叉概率范围
% 输出参数：
% XCross - 交叉群体（行向量）
% FCross - 交叉群体适应度（已降序排列）
% I - 交叉群体序号

X2 = Population1.X;
F2 = Population1.F;

c = length(I)/2;                                % 交叉次数
if c>0
    
    Par1 = XCross(1:c,:);
    Par2 = XCross(c+1:end,:);
    F_Par1 = FCross(1:c);
    F_Par2 = FCross(c+1:end);
    
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
    % D - 扰动半径（行向量，对应每一维）
    % 输出参数：
    % Off1 - 子代群体1
    % F_Off1 - 子代群体1适应度
    % Off2 - 子代群体2
    % F_Off2 - 子代群体2适应度
    
    F4 = [F_Par1,F_Par2,F_Off1,F_Off2];
    [tmp,I4] = sort(F4,2,'descend');            % 交叉操作2+2选择
    F_Off1 = tmp(:,1);
    F_Off2 = tmp(:,2);
    for i = 1:c
        tmp4 = [Par1(i,:);Par2(i,:);Off1(i,:);Off2(i,:)];
        Off1(i,:) = tmp4(I4(i,1),:);
        Off2(i,:) = tmp4(I4(i,2),:);
    end
    
    X2(I,:) = [Off1;Off2];
    F2(I) = [F_Off1;F_Off2];
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end
