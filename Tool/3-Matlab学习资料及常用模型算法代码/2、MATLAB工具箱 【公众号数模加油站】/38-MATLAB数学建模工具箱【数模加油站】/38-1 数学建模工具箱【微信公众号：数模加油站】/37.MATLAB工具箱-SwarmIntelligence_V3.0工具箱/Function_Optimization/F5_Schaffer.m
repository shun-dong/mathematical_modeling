function F = F5_Schaffer(X,Parmaters)
% 优化函数：Schaffer函数（并行算法）
% 全局最小X=0,0,...,最小值为F=0
% 由J.D.Schaffer提出, 为典型的非线性多模态函数，有广泛的搜索空间、大量局部极小点和高大的障碍物，
% 在距离全局极小点约3.14的范围内存在无限多个次全局极大点,函数强烈的震荡的性态使其很难全局最优化
% 输入参数:
% X - 输入参数矩阵（popsize*dim的矩阵）
% Parmaters - 由Options.Parmaters传入的函数参数（无参数时不使用）
% 输出参数:
% F - 函数输出（popsize*1的矩阵）

%--------------------------------------------------------------------------
% 全局最小X=0,0 ,最小值为0

% 主函数参数传递方式：
% Options.Parmaters.p1 = a;
% Options.Parmaters.p2 = b;
% 
% 这里参数读取方式：
% a = Parmaters.p1;
% b = Parmaters.p2;

F = sum((X(:,1:end-1).^2+X(:,2:end).^2).^0.25.*(sin(50*(X(:,1:end-1).^2+X(:,2:end).^2).^0.1).^2+1),2);

end




