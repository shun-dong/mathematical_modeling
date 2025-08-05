function [Off,F_Off] = DisturbSub(Par,fitness,Parmaters,maxmin,Lb,Ub,D,T)
% 扰动操作子函数
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

if nargin<8
    [popsize,dim] = size(Par);
    T = ceil(dim*rand(popsize,1));          % 变异位置  1~dim(列数)
end

Off = Par;
for i = 1:size(Par,1)
    j = T(i);                               % 确定性的每一维变异
    d = D(j);                               % 扰动半径
    Off(i,j) = Off(i,j)+2*d*rand()-d;
    
    Off(i,j) = max(Lb(j),Off(i,j));
    Off(i,j) = min(Ub(j),Off(i,j));
end
if isempty(Parmaters)
    F_Off = maxmin*feval(fitness,Off);
else
    F_Off = maxmin*feval(fitness,Off,Parmaters);
end

end

