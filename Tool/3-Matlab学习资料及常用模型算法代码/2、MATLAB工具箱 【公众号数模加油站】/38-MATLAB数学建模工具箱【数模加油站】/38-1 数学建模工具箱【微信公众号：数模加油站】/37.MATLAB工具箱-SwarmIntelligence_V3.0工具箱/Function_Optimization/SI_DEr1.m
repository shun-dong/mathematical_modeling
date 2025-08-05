function [x,f,F] = SI_DEr1(Options)
% DEr1，标准差分算法(DE/rand/1/bin)
disp('--- 标准差分算法(DE/rand/1/bin)（Differential Evolution Algorithms,DE） ---');
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

%--------------------------------------
% 产生初始种群

popsize_sub = max(round(sqrt(popsize)),6);    % 子种群规模
popnum_sub = ceil(popsize/popsize_sub);       % 子种群个数
popsize = popsize_sub*popnum_sub;             % 种群规模
Options.popsize = popsize;

[Population1] = Initialize(fitness,Parmaters,maxmin,Lb,Ub,popsize,seed);
% 种群初始化
% 输入参数:
% fitness - 优化函数
% Parmaters - 函数参数   
% maxmin - 极值类型：1最大值，-1最小值
% Lb - 参数下界
% Ub - 参数上界
% popsize - 种群规模
% seed - 初始化随机种子
% 输出参数:
% Population - 种群
%     Population.X - 种群(行向量)
%     Population.F - 种群适应度
%     Population.x - 最优个体
%     Population.f - 最优个体适应度
% 针对PSO特别定义
%     Population.V - 粒子速度
%     Population.Xp - 历史最优(行向量)
%     Population.Fp - 历史最优适应度

%--------------------------------------

F = zeros(maxgen,1);                                            % 输出显示
for gen = 1:maxgen
    
    ispop = 1;
    if ispop==1
        
        [tmp,I] = sort(Population1.F,'descend');          % Population1排序更新
        J = reshape(I,popnum_sub,popsize_sub);
        J = J';
        for j = 1:popnum_sub
            
            Population2.X = Population1.X(J(:,j),:);      % 子种群
            Population2.F = Population1.F(J(:,j));
            Population2.x = Population2.X(1,:);           % 子种群
            Population2.f = Population2.F(1);        
            
            Population2 = UpdateDEr1(Population2,fitness,Parmaters,maxmin,Lb,Ub,K,CR);
            Population2 = Mutate(Population2,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu);
            Population2 = Disturb(Population2,fitness,Parmaters,maxmin,Lb,Ub,quick);
            
            Population1.X(J(:,j),:) = Population2.X;      % 子种群
            Population1.F(J(:,j)) = Population2.F;
        end        
        
    else
        
        Population1 = UpdateDEr1(Population1,fitness,Parmaters,maxmin,Lb,Ub,K,CR);
        % 种群更新
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
        % K - 缩放因子
        % CR - 交叉概率
        % 输出参数：
        % Population - 种群
        %     Population.X - 种群(行向量)
        %     Population.F - 种群适应度
        %     Population.x - 最优个体
        %     Population.f - 最优个体适应度
        
        Population1 = Mutate(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu);
        % 变异操作
        % 输入参数:
        % Population - 子种群
        %     Population.X - 种群(行向量)
        %     Population.F - 种群适应度
        %     Population.x - 最优个体
        %     Population.f - 最优个体适应度
        % 针对PSO特别定义
        %     Population.V - 粒子速度
        %     Population.Xp - 历史最优(行向量)
        %     Population.Fp - 历史最优适应度
        % fitness - 优化函数
        % Parmaters - 函数参数
        % maxmin - 极值类型：1最大值，-1最小值
        % Lb - 参数下界
        % Ub - 参数上界
        % Pm - 自适应变异概率范围
        % ismu - 是否变异操作（缺省为1）
        % 输出参数:
        % Population - 子种群
        %     Population.X - 种群(行向量)
        %     Population.F - 种群适应度(已降序排列)
        %     Population.x - 最优个体
        %     Population.f - 最优个体适应度
        % 针对PSO特别定义
        %     Population.V - 粒子速度
        %     Population.Xp - 历史最优(行向量)
        %     Population.Fp - 历史最优适应度
        
        Population1 = Disturb(Population1,fitness,Parmaters,maxmin,Lb,Ub,quick);
        % 扰动操作
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
        % quick - 最优解加速次数（缺省为0）
        % 输出参数:
        % Population - 种群
        %     Population.X - 种群(行向量)
        %     Population.F - 种群适应度
        %     Population.x - 最优个体
        %     Population.f - 最优个体适应度
        
    end
    
    %---------------------------------------
    
    [fmax,imax] = max(Population1.F);
    if fmax>Population1.f
        Population1.f = fmax;
        Population1.x = Population1.X(imax,:);
    end     
    
    %---------------------------------------
    
    x = Population1.x;
    f = maxmin*Population1.f;
    F(gen) = f;
    
    %---------------------------------------
    % 命令窗口显示
    
    if mod(gen,show)==0
        str = num2str(x(1),'%.4f');
        for j = 2:length(x)
            str = [str,', ',num2str(x(j),'%.4f')];
        end
        disp(['DEr1, gen=',num2str(gen),', fval=',num2str(f,16),', x=',str]);
%         disp(['DEr1, gen=',num2str(gen),', fval=',num2str(f,16)]);
    end
    
    %---------------------------------------
    % 提前退出
    
    if (maxmin==-1 && f<tolfun) || (maxmin==1 && f>tolfun)
        F = F(1:gen);
        x
        f
        disp('------ 输出到达tolfun，程序终止 ------')
        return;
    end
    if (gen>localmin) && (F(gen)==F(gen-localmin))
        F = F(1:gen);
        x
        f    
        disp('------ 输出连续localmin次不更新，程序终止 ------')
        return;
    end    
end
x
f
disp('------ 到达最大进化代数，程序终止 ------')

end

