function [Population2] = UpdateAbc(Population1,fitness,Parmaters,maxmin,Lb,Ub)
% ABC算法，种群更新
% 输入参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% 输出参数：
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

[Population1] = NeighborSearch(Population1,fitness,Parmaters,maxmin,Lb,Ub);
% 邻域搜索
% 输入参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% Index - 更新个体的索引数组
% 输出参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

%----------------------------------------------------------------------
[tmp,I] = Select(Population1);
% 锦标赛选择
% 输入参数:
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 输出参数：
% Population - 子种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% I - 选中个体的索引数组

%----------------------------------------------------------------------
[Population2] = NeighborSearch(Population1,fitness,Parmaters,maxmin,Lb,Ub,I);
% 邻域搜索
% 输入参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% fitness - 优化函数
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% Index - 更新个体的索引数组
% 输出参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度

end
