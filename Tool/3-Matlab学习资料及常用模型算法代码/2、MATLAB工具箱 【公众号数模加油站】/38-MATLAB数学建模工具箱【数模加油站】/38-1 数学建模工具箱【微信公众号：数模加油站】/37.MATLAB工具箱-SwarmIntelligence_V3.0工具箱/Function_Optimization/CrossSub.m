function [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub)
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

Off1 = Par1;
F_Off1 = F_Par1;
Off2 = Par2;
F_Off2 = F_Par2;

I = find((F_Par1-F_Par2)~=0);                           % 个体不相等时交叉
J = find((F_Par1-F_Par2)==0);                           % 个体相等时变异

c = length(I);
dim = size(Par1,2);
Index = rand(c,dim);

Off1(I,:) = (1-Index).*Par1(I,:)+Index.*Par2(I,:);              % 均匀交叉
if isempty(Parmaters)
    F_Off1(I) = maxmin*feval(fitness,Off1(I,:));
else
    F_Off1(I) = maxmin*feval(fitness,Off1(I,:),Parmaters);
end
[Off1(J,:),F_Off1(J)] = MutateSub(Par1(J,:),fitness,Parmaters,maxmin,Lb,Ub);  % 随机变异
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

if nargout>2
    Off2(I,:) = Index.*Par1(I,:)+(1-Index).*Par2(I,:);          % 均匀交叉
    if isempty(Parmaters)
        F_Off2(I) = maxmin*feval(fitness,Off2(I,:));
    else
        F_Off2(I) = maxmin*feval(fitness,Off2(I,:),Parmaters);
    end
    [Off2(J,:),F_Off2(J)] = MutateSub(Par2(J,:),fitness,Parmaters,maxmin,Lb,Ub);  % 随机变异
end

end
