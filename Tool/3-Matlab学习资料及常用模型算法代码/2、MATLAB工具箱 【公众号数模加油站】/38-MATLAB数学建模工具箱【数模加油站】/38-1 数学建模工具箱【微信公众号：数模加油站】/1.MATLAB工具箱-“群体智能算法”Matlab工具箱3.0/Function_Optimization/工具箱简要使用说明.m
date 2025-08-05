
% “群体智能算法”Matlab工具箱 Version3.0 正式版
% "Swarm Intelligence Alogrihtm" Matlab Toolbox - trial version 2.0
%
% 工具箱简要使用说明：
% 1、集成了八种种群体智能算法：'PPNGA','SFLA','MSFLA','AF-SFLA','PSO','ABC','DEr1','DEb2'
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