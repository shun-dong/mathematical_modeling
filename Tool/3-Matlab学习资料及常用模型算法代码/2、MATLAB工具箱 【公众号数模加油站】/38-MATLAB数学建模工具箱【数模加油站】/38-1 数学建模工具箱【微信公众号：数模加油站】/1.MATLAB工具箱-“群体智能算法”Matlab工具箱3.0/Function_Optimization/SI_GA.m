function [x,f] = SI_GA(Options)
% GA优化
disp('------------ GA优化 ------------');
% 输入参数:
% Options - 优化参数设置
%     Options.dim - 优化函数的维数
%     Options.fitness - 优化函数
%     Options.Parmaters - 优化函数Options.fitness参数
%     Options.maxmin - 极值类型：1最大值，-1最小值
%     Options.Lb - 参数下界
%     Options.Ub -  参数上界
%
%     Options.show - 显示间隔
%     Options.popsize - 种群规模
%     Options.maxgen - 终止条件3（到达最大进化代数，程序终止）
%     Options.localmin - 终止条件1（输出连续localmin次不更新，程序终止，隐去无效）
%     Options.tolfun - 终止条件2（输出到达tolfun，程序终止，隐去无效）
%
%     Options.seed - 初始化随机种子，缺省值sum(100*clock)（使用此项，各算法初始化群体相同）
%     Options.quick - 最优解加速次数，缺省值5（为0时,扰动算子无效）;
%     Options.ismu - 是否变异操作，缺省值0（函数测试时有效，为0时,变异算子无效，PPNGA，MSFLA算法已内置为1，不受此设置影响）
%     Options.ispop - 是否分群优化，缺省值0（函数测试时有效，为0时,不分子种群，PPNGA，MSFLA，SFLA算法已内置为1，不受此设置影响）
%     Options.Pc - 自适应交叉概率（交叉算子）,缺省值[0.6,0.99];
%     Options.Pm - 自适应变异概率（变异算子）,缺省值[0.01,0.1];
%     Options.c1 - 加速系数1（粒子群算法,PSO）,缺省值2;
%     Options.c2 - 加速系数2（粒子群算法,PSO）,缺省值2;
%     Options.w1 - 惯性权系数1（粒子群算法,PSO）,缺省值0.9;
%     Options.w2 - 惯性权系数2（粒子群算法,PSO）,缺省值0.4;
%     Options.limit - 侦察蜂控制参数（蜂群算法,ABC）,缺省值50;
%     Options.F - 缩放因子（差分进化算法,DEr1，DEb2）,缺省值[0,1];
%     Options.CR - 交叉概率（差分进化算法,DEr1，DEb2）,缺省值[0.8,1];
%
% 输出参数:
% x - 最优解
% f - 最优适应度
% F - 各代最优适应度

%---------------------------------------
% 输入参数读取

dim = Options.dim;
fitness = Options.fitness;
if isfield(Options,'Parmaters')
    Parmaters = Options.Parmaters;
else
    Parmaters = [];
end
maxmin = Options.maxmin;
Lb = Options.Lb;
Ub = Options.Ub;
show = Options.show;
popsize = Options.popsize;
maxgen = Options.maxgen;
if isfield(Options,'localmin')
    localmin = Options.localmin;
else
    localmin = inf;
end
if isfield(Options,'tolfun')
    tolfun = Options.tolfun;
else
    if maxmin==-1
        tolfun = -inf;
    elseif maxmin==1
        tolfun = inf;
    end
end
if isfield(Options,'quick')
    quick = Options.quick;
else
    quick = 5;
end
if isfield(Options,'Pc')
    Pc = Options.Pc;
else
    Pc = [0.6,0.99];
end
if isfield(Options,'Pm')
    Pm = Options.Pm;
else
    Pm = [0.01,0.1];
end
if isfield(Options,'c1')
    c1 = Options.c1;
else
    c1 = 2;
end
if isfield(Options,'c2')
    c2 = Options.c2;
else
    c2 = 2;
end
if isfield(Options,'w1')
    w1 = Options.w1;
else
    w1 = 0.9;
end
if isfield(Options,'w2')
    w2 = Options.w2;
else
    w2 = 0.4;
end
if isfield(Options,'limit')
    limit = Options.limit;
else
    limit = 50;
end
if isfield(Options,'seed')
    seed = Options.seed;
else
    seed = sum(100*clock);
end
if isfield(Options,'ismu')
    ismu = Options.ismu;
else
    ismu = 0;
end
if isfield(Options,'ispop')
    ispop = Options.ispop;
else
    ispop = 0;
end
if isfield(Options,'F')
    K = Options.F;
else
    K = [0,1];                        % 缩放因子（差分进化算法,DE）
end
if isfield(Options,'CR')
    CR = Options.CR;
else
    CR = [0.8,1];                       % 交叉概率（差分进化算法,DE）
end

%---------------------------------------
% 输入合法性检查

if (maxmin~=1 && maxmin~=-1)
    error('Options.maxmin为1或-1');
end
if length(Lb)~=1 && length(Lb)~=dim
    error('Options.Lb的长度为1或dim');
end
if length(Ub)~=1 && length(Ub)~=dim
    error('Options.Ub的长度为1或dim');
end
if length(Lb)==1
    Lb = repmat(Options.Lb,dim,1);
    Options.Lb = Lb;
end
if length(Ub)==1
    Ub = repmat(Options.Ub,dim,1);
    Options.Ub = Ub;
end
if size(Lb,2)>size(Lb,1)
    Lb = Lb';
end
if size(Ub,2)>size(Ub,1)
    Ub = Ub';
end
                                    
%---------------------------------------
% GA函数调用

nvars = dim;
A = [];
b = [];
Aeq = [];
beq = [];
LB = Lb;
UB = Ub;
nonlcon = [];
options = gaoptimset('PopulationSize',popsize,'Generations',maxgen,'MutationFcn',@mutationadaptfeasible,'Display','off','TolFun',1e-20,'TolCon',1e-20);
% options = gaoptimset('PopulationSize',popsize,'Generations',maxgen,'MutationFcn',@mutationadaptfeasible,'Display','iter','TolFun',1e-20,'TolCon',1e-20);

[x,f] = ga(@(X) MyFun(X,fitness,Parmaters,maxmin),nvars,A,b,Aeq,beq,LB,UB,nonlcon,options)

end

%--------------------------------------------------------------------------

function [F] = MyFun(X,fitness,Parmaters,maxmin)

try
    F = -maxmin*feval(fitness,X,Parmaters);
catch
    F = -maxmin*feval(fitness,X);
end

end
