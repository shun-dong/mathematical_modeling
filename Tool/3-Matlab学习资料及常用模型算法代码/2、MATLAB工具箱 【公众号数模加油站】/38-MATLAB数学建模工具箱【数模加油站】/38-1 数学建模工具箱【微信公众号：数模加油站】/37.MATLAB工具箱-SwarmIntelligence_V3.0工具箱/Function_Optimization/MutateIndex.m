function [XMutate,FMutate,I] = MutateIndex(X1,F1,Pm)
% 自适应变异索引，由自适应变异概率概率Pm，求参与变异群体PMutate，及适应度FMutate
% 输入参数：
% X1 - 群体（每一行一个个体）
% F1 - 群体适应度（列向量）
% Pm - 自适应变异概率范围
% 输出参数：
% XMutate - 变异群体（每一行一个个体）
% FMutate - 变异群体适应度（列向量）
% I - 变异群体序号

if nargin<3
    Pm = [0.1,0.4];
end

popsize = length(F1);

f_max = max(F1);
f_avg = mean(F1);
I = find(F1>f_avg);                     % 大于平均的下标
J = (1:popsize)';
J(I) = [];                             % 小于平均的下标

pm1 = max(Pm);
pm2 = min(Pm);

pm = zeros(popsize,1);
pm(I) = pm1-(pm1-pm2)*(F1(I)-f_avg)/(f_max-f_avg);
pm(J) = pm1*ones(length(J),1);

%--------------------------

P = rand(popsize,1);                    % 产生[0,1]随机数
I = find(P<pm);                         % 变异的个体序号(行数)

XMutate = X1(I,:);
FMutate = F1(I);

end

