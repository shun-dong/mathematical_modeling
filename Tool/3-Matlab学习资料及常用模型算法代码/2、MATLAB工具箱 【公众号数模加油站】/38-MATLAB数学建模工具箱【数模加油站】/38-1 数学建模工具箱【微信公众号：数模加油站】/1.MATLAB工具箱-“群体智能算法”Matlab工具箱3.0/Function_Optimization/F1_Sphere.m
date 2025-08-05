function F = F1_Sphere(X,Parmaters)
% 优化函数：Sphere函数（并行算法）
% 全局最小X=0,0,...,最小值为F=0
% 由K.A.De Jong提出的,著名的Sphere函数,各分量在Xi=0达到极小值0,单峰函数,一般用于考察算法精度
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

F = sum(X.^2,2);

end
