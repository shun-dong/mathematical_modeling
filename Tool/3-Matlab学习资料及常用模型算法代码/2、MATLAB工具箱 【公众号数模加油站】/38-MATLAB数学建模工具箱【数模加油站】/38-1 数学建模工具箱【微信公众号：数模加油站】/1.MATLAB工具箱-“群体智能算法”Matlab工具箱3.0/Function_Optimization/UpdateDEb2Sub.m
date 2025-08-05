function [Off,F_Off] = UpdateDEb2Sub(Par,F_Par,fitness,Parmaters,maxmin,Lb,Ub,K,CR)
% UpdateDEb2子函数
% 输入参数：
% Par - 父代群体
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% K - 缩放因子
% CR - 交叉概率
% T - 父代群体更新的索引值
% 输出参数：
% Off - 子代群体
% F_Off - 子代群体适应度

[popsize,dim] = size(Par);
K_Array = min(K)+(max(K)-min(K))*rand(popsize,1);             % 随机缩放
CR_Array = min(CR)+(max(CR)-min(CR))*rand(popsize,1);         % 随机交叉

[f,imax] = max(F_Par);
x = Par(imax,:);

I = zeros(popsize,4);
for i = 1:popsize
    J = 1:popsize;
    J([imax,i]) = [];
    
    try
        I(i,:) = J(randperm(popsize-2,4));
    catch
        I(i,:) = Shuffle(J,4);
    end
    
    % 洗牌函数
    % 输入参数:
    % All - 所有的牌
    % d - 一个人拿到的牌的张数
    % 输出参数:
    % Ones - 一个人拿到的牌
    % I2 - 牌的序号
    
end
V = repmat(x,popsize,1)+repmat(K_Array,1,dim).*(Par(I(:,1),:)+Par(I(:,2),:)-Par(I(:,3),:)-Par(I(:,4),:));

p1 = rand(size(Par))<=repmat(CR_Array,1,dim);  % 随机交叉位置
p2 = zeros(size(Par));
J = ceil(dim*rand(popsize,1));
for i = 1:popsize
    p2(i,J(i)) = 1;                             % 必定交叉位置
end
p = p1 | p2;                                    % 交叉的位置
U = V.*p+Par.*(1-p);                            % 交叉操作

U = max(U,repmat(Lb',popsize,1));               % 边界处理
U = min(U,repmat(Ub',popsize,1));
if isempty(Parmaters)
    F = maxmin*feval(fitness,U);
else
    F = maxmin*feval(fitness,U,Parmaters);
end

F4 = [F_Par,F];
[F_Off,I4] = max(F4,[],2);                       % 交叉操作2+2选择
Off = zeros(size(Par));
for i = 1:popsize
    tmp4 = [Par(i,:);U(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

end
