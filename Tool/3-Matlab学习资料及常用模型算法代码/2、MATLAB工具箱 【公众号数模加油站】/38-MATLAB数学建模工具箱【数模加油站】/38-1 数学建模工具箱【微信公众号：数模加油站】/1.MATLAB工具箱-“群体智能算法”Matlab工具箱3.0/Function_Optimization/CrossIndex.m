function [XCross,FCross,I] = CrossIndex(X1,F1,Pc)
% 自适应交叉索引，由自适应交叉概率概率Pc，求参与交叉群体PCross，及适应度FCross
% 输入参数：
% X1 - 群体（行向量）
% F1 - 群体适应度
% Pc - 自适应交叉概率范围
% 输出参数：
% XCross - 交叉群体（行向量）
% FCross - 交叉群体适应度（已降序排列）
% I - 交叉群体序号

if nargin<3
    Pc = [0.6,0.9];
end

popsize = length(F1);

f_max = max(F1);
f_avg = mean(F1);
I = find(F1>f_avg);                     % 大于平均的下标
J = (1:popsize)';
J(I) = [];                              % 小于平均的下标

pc1 = max(Pc);
pc2 = min(Pc);

pc = zeros(popsize,1);
pc(I) = pc1-(pc1-pc2)*(F1(I)-f_avg)/(f_max-f_avg);      % 大于平均交叉概率小
pc(J) = pc1*ones(length(J),1);                          % 小于平均交叉概率大

%--------------------

P = rand(popsize,1);                        % 产生[0,1]随机数
I = find(P<pc);

if ~isempty(I)
    [FCross,J] = sort(F1(I),'descend');         % 降序排列
    I = I(J);
    XCross = X1(I,:);

    if mod(length(I),2)                         % 奇数裁剪成偶数
        XCross = XCross(1:end-1,:);
        FCross = FCross(1:end-1);
        I = I(1:end-1);
    end
else
    XCross = [];
    FCross = [];
end

end

