function [Ones,I2] = Shuffle(Alls,d)
% 洗牌函数
% 输入参数:
% All - 所有的牌
% d - 一个人拿到的牌的张数
% 输出参数:
% Ones - 一个人拿到的牌
% I2 - 牌的序号

m = length(Alls);
I1 = 1:m;
I2 = zeros(1,d);
for i = 1:d
    j = ceil(length(I1)*rand());        % 随机产生序号
    I2(i) = I1(j);                      % 本次选择
    I1(j) = [];                         % 在原序列中删除本次选择
end
Ones = Alls(I2);