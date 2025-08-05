
% “群体智能算法”Matlab工具箱 Version3.0
% "Swarm Intelligence Alogrihtm" Matlab Toolbox - trial version 2.0
%
% 工具箱简要使用说明：
% 1、集成了八种群体智能算法：'PPNGA','SFLA','MSFLA','AF-SFLA','PSO','ABC','DEr1','DEb2'
% 2、适应度函数开放了一个参数Parmaters，接收本文件Options.Parmaters传递的参数，实例参见m文件F3_Rastrigin.m
% 3、本程序设置了三个终止条件，终止条件3是必需的；终止条件1,2是可选的，不需要时隐去代码即可
% 4、在优化参数设置中，小种群设置与大种群设置各有优势，实际工程问题不一定哪一种设置更好，要根据实验结果来确定
% 5、在算法参数设置中，缺省设置一般不需要改动，除非在原理上对改动所引起的结果变动有着更深入的理解
%
% 接口文件
% Main_SwarmIntelligence_Interface.m
%
% 适应度函数文件
% F0_Yours.m
% F1_Sphere.m
% F2_Rosenbrock.m
% F3_Rastrigin.m
% F4_Griewank.m
% F5_Schaffer.m
% 
% 特别提示: 采用以下三种方法来可有效克服随机初始化带来的局部极小问题
% 1、若干次运行取最优
% 2、增加进化代数maxgen
% 3、加大种群规模popsize
%
% 使用平台 - WinXP SP2及以上版本（Win7上没有调试），Matlab7.0 -> Matlab2011b
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

%--------------------------------------
% 优化函数定义（函数详细说明参见m文件：Options.fitness）

Options.dim = 3;                            % 优化函数的维数
Options.fitness = 'F0_Yours';               % 优化函数
Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
Options.Lb = -5.12;                         % 参数下界（各维可分别设置）
Options.Ub = 5.12;                          % 参数上界（各维可分别设置）

% Options.dim = 30;                           % 优化函数的维数
% Options.fitness = 'F1_Sphere';              % 优化函数
% Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
% Options.Lb = -100;                          % 参数下界（各维可分别设置）
% Options.Ub = 100 ;                          % 参数上界（各维可分别设置）

% Options.dim = 30;                           % 优化函数的维数
% Options.fitness = 'F2_Rosenbrock';          % 优化函数
% Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
% Options.Lb = -30;                           % 参数下界（各维可分别设置）
% Options.Ub = 30;                            % 参数上界（各维可分别设置）

% Options.dim = 30;                           % 优化函数的维数
% Options.fitness = 'F3_Rastrigin';           % 优化函数
% Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
% Options.Lb = -100;                          % 参数下界（各维可分别设置）
% Options.Ub = 100;                           % 参数上界（各维可分别设置）
% Options.Parmaters = 10;                     % 优化函数Options.fitness参数    

% Options.dim = 30;                           % 优化函数的维数
% Options.fitness = 'F4_Griewank';            % 优化函数
% Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
% Options.Lb = -600;                          % 参数下界（各维可分别设置）
% Options.Ub = 600;                           % 参数上界（各维可分别设置）

% Options.dim = 30;                           % 优化函数的维数
% Options.fitness = 'F5_Schaffer';            % 优化函数
% Options.maxmin = -1;                        % 极值类型（1最大值，-1最小值）
% Options.Lb = -100;                          % 参数下界（各维可分别设置）
% Options.Ub = 100;                           % 参数上界（各维可分别设置）

%--------------------------------------------------------------------------
% 优化参数设置

% 大种群设置
Options.show = 50;                          % 显示间隔
Options.popsize = 200;                      % 种群规模
Options.maxgen = 500;                       % 终止条件3（到达最大进化代数，程序终止）
Options.localmin = 50;                      % 终止条件1（输出连续localmin次不更新，程序终止，隐去无效）
Options.tolfun = 1e-16;                     % 终止条件2（输出到达tolfun，程序终止，隐去无效）

% 小种群设置（与大种群设置各有优势）
% Options.show = 500;                         % 显示间隔
% Options.popsize = 20;                       % 种群规模
% Options.maxgen = 5000;                      % 终止条件3（到达最大进化代数，程序终止）
% Options.localmin = 500;                     % 终止条件1（输出连续localmin次不更新，程序终止，隐去无效）
% Options.tolfun = 1e-16;                     % 终止条件2（输出到达tolfun，程序终止，隐去无效）

%--------------------------------------------------------------------------
% 算法参数设置（以下为缺省设置，一般不需要改动，除非在原理上对改动所引起的结果变动有着更深入的理解）

Options.seed = sum(100*clock);              % 初始化随机种子（使用此项，各算法初始化群体相同）
% Options.quick = 5;                          % 最优解加速次数（为0时,扰动算子无效）
% Options.ismu = 0;                           % 是否变异操作（函数测试时有效，为0时,变异算子无效，PPNGA，MSFLA算法已内置为1，不受此设置影响）
% Options.ispop = 0;                          % 是否分群优化（函数测试时有效，为0时,不分子种群，PPNGA，MSFLA，SFLA算法已内置为1，不受此设置影响）
% Options.Pc = [0.6,0.99];                    % 自适应交叉概率（交叉算子）
% Options.Pm = [0.01,0.1];                    % 自适应变异概率（变异算子）
% Options.c1 = 2;                             % 加速系数1（粒子群算法，PSO）
% Options.c2 = 2;                             % 加速系数2（粒子群算法，PSO）
% Options.w1 = 0.9;                           % 惯性权系数1（粒子群算法，PSO）
% Options.w2 = 0.4;                           % 惯性权系数2（粒子群算法，PSO）
% Options.limit = 50;                         % 侦察蜂控制参数（蜂群算法，ABC）
% Options.F = [0,1];                          % 缩放因子（差分进化算法,DEr1，DEb2）
% Options.CR = [0.8,1];                       % 交叉概率（差分进化算法,DEr1，DEb2）

%--------------------------------------------------------------------------
% 函数调用


[x1,f1,F1] = SwarmIntelligence(Options,'PPNGA');    % 伪并行小生境遗传算法（PPNGA）
[x2,f2,F2] = SwarmIntelligence(Options,'SFLA');     % 标准混合蛙跳算法（SFLA）
[x3,f3,F3] = SwarmIntelligence(Options,'MSFLA');    % 改进混合蛙跳算法（MSFLA）
[x4,f4,F4] = SwarmIntelligence(Options,'AF_SFLA');  % 鱼群（AF），SFLA混合算法
[x5,f5,F5] = SwarmIntelligence(Options,'PSO');      % 标准粒子群算法（PSO）
[x6,f6,F6] = SwarmIntelligence(Options,'ABC');      % 蜂群算法（ABC）
[x7,f7,F7] = SwarmIntelligence(Options,'DEr1');     % 标准差分算法(DE/rand/1/bin)
[x8,f8,F8] = SwarmIntelligence(Options,'DEb2');     % 标准差分算法(DE/best/2/bin)

% [x9,f9] = SwarmIntelligence(Options,'FMINCON');     % FMINCON优化
% [x10,f10] = SwarmIntelligence(Options,'GA');        % GA优化

%--------------------------------------------------------------------------
% 函数测试

% Algorithm = 'PPNGA';
% Algorithm = 'SFLA';
% Algorithm = 'MSFLA';
% Algorithm = 'AF_SFLA';
% Algorithm = 'PSO';
% Algorithm = 'ABC';
% Algorithm = 'DEr1';
% Algorithm = 'DEb2';
% [x1,f1,F1] = SwarmIntelligence(Options,Algorithm);    
% 
% Options2 = Options;
% Options2.ismu = 1;
% [x2,f2,F2] = SwarmIntelligence(Options2,Algorithm);   
% 
% Options3 = Options;
% Options3.ispop = 1;
% [x3,f3,F3] = SwarmIntelligence(Options3,Algorithm);  
% 
% Options4 = Options;
% Options4.ismu = 1;
% Options4.ispop = 1;
% [x4,f4,F4] = SwarmIntelligence(Options4,Algorithm);  

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

%--------------------------------------------------------------------------
% 结果作图

figure; xlabel('gen'); ylabel('log10(F)'); title(Options.fitness(4:end)); hold on
plot(log10(F1),'b.-');
plot(log10(F2),'m.-');
plot(log10(F3),'k.-');
plot(log10(F4),'c.-');
plot(log10(F5),'g.-');
plot(log10(F6),'.-','color',[0.4 0.4 0.4]);
plot(log10(F7),'y.-');
plot(log10(F8),'r.-');
legend('PPNGA','SFLA','MSFLA','AF-SFLA','PSO','ABC','DEr1','DEb2'); 
hold off;

% figure; xlabel('gen'); ylabel('log10(F)'); title(Options.fitness(4:end)); hold on
% plot(log10(F1),'b.-');
% plot(log10(F2),'k.-');
% plot(log10(F3),'g.-');
% plot(log10(F4),'r.-');
% legend('none','ismu=1','ispop=1','ismu=1 & ispop=1'); 
% hold off;

