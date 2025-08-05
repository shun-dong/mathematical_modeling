function F = F3_Rastrigin(X,Parmaters)
% 优化函数：Rastrigin函数（并行算法）
% 全局最小X=0,0,...,最小值为F=0，为多峰函数，在定义域范围内大约存在10D个局部极小点
% 优化函数(并行算法)
% 输入参数:
% X - 输入参数矩阵（popsize*dim的矩阵）
% Parmaters - 由Options.Parmaters传入的函数参数（无参数时不使用）
% 输出参数:
% F - 函数输出（popsize*1的矩阵）

%--------------------------------------------------------------------------
% 全局最小X=0,0,... ,最小值为F=0

% 主函数参数传递方式：
% Options.Parmaters.p1 = a;
% Options.Parmaters.p2 = b;
% 
% 这里参数读取方式：
% a = Parmaters.p1;
% b = Parmaters.p2;

A = Parmaters;
F = sum(X.^2-A*cos(2*pi*X)+A,2);

end

