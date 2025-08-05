function F = F4_Griewank(X,Parmaters)
% 优化函数：Griewank函数（并行算法）
% 全局最小X=0,0,...,最小值为F=0，为多模态函数，有大量的局部极值点，
% 局部极小在Xi=k*pi*sqrt(i),i=1,2,... k=0,1,2,..., 算法难找到最优解
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

[popsize,D] = size(X);
F = sum(X.^2,2)/4000-prod(cos(X./repmat([1:D],popsize,1).^0.5),2)+1;

end


