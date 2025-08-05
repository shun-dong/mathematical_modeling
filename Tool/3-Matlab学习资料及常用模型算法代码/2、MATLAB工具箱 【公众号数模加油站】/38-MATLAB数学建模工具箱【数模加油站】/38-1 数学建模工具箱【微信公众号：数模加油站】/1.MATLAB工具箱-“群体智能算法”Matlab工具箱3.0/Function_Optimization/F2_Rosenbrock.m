function F = F2_Rosenbrock(X,Parmaters)
% 优化函数：Rosenbrock函数（并行算法）
% 全局最小X=1,1,...,最小值为F=0
% 由K.A.De Jong提出的,著名的Rosenbrock函数,是非凸,病态函数,全局最优点位于一个平滑、狭长的抛物线形山谷内；
% 一般算法很难辨别搜索方向，极难找到全局最小点，通常用来评价优化算法的执行效率
% 输入参数:
% X - 输入参数矩阵（popsize*dim的矩阵）
% Parmaters - 由Options.Parmaters传入的函数参数（无参数时不使用）
% 输出参数:
% F - 函数输出（popsize*1的矩阵）

%--------------------------------------------------------------------------
% 全局最小X=1,1,... ,最小值为F=0

% 主函数参数传递方式：
% Options.Parmaters.p1 = a;
% Options.Parmaters.p2 = b;
% 
% 这里参数读取方式：
% a = Parmaters.p1;
% b = Parmaters.p2;

F = sum(100*(X(:,2:end)-X(:,1:end-1).^2).^2+(1-X(:,1:end-1)).^2,2);

end
