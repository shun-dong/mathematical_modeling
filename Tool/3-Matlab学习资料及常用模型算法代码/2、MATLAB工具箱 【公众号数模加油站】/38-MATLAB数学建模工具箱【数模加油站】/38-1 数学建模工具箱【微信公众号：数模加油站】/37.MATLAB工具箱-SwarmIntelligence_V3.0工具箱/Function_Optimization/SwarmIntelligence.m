function [x,f,F] = SwarmIntelligence(Options,Algorithm)
% 群体智能算法接口
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
% Algorithm - 算法
%     'MSFLA' - 改进混合蛙跳算法（MSFLA）
%     'SFLA' - 标准混合蛙跳算法（SFLA）
%     'PPNGA' - 伪并行小生境遗传算法（PPNGA）
%     'AF_SFLA' - 鱼群（AF），SFLA混合算法
%     'ABC' - 蜂群算法（ABC）
%     'PSO' - 标准粒子群算法（PSO）
%     'DEr1' - 标准差分进化算法(DE/rand/1/bin)
%     'DEb2' - 标准差分进化算法(DE/best/2/bin) 
%     'FMINCON' - FMINCON优化
%     'GA' - GA优化
%
% 输出参数:
% x - 最优解
% f - 最优适应度
% F - 各代最优适应度

switch Algorithm
    case 'MSFLA'
        [x,f,F] = SI_MSFLA(Options);        % 改进混合蛙跳算法（MSFLA）
    case 'SFLA'
        [x,f,F] = SI_SFLA(Options);         % 标准混合蛙跳算法（SFLA）
    case 'PPNGA'
        [x,f,F] = SI_PPNGA(Options);        % 伪并行小生境遗传算法（PPNGA）
    case 'AF_SFLA'
        [x,f,F] = SI_AF_SFLA(Options);      % 鱼群（AF），SFLA混合算法
    case 'ABC'
        [x,f,F] = SI_ABC(Options);          % 蜂群算法（ABC）
    case 'PSO'
        [x,f,F] = SI_PSO(Options);          % 标准粒子群算法（PSO）
    case 'DEr1'
        [x,f,F] = SI_DEr1(Options);         % 标准差分进化算法(DE/rand/1/bin)
    case 'DEb2'
        [x,f,F] = SI_DEb2(Options);         % 标准差分进化算法(DE/best/2/bin)
    case 'FMINCON'
        [x,f] = SI_FMINCON(Options);        % FMINCON优化
        F = [];
    case 'GA'
        [x,f] = SI_GA(Options);             % GA优化
        F = [];        
end

end
