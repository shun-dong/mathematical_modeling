function [x,f] = SI_GA(Options)
% GA�Ż�
disp('------------ GA�Ż� ------------');
% �������:
% Options - �Ż���������
%     Options.dim - �Ż�������ά��
%     Options.fitness - �Ż�����
%     Options.Parmaters - �Ż�����Options.fitness����
%     Options.maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
%     Options.Lb - �����½�
%     Options.Ub -  �����Ͻ�
%
%     Options.show - ��ʾ���
%     Options.popsize - ��Ⱥ��ģ
%     Options.maxgen - ��ֹ����3������������������������ֹ��
%     Options.localmin - ��ֹ����1���������localmin�β����£�������ֹ����ȥ��Ч��
%     Options.tolfun - ��ֹ����2���������tolfun��������ֹ����ȥ��Ч��
%
%     Options.seed - ��ʼ��������ӣ�ȱʡֵsum(100*clock)��ʹ�ô�����㷨��ʼ��Ⱥ����ͬ��
%     Options.quick - ���Ž���ٴ�����ȱʡֵ5��Ϊ0ʱ,�Ŷ�������Ч��;
%     Options.ismu - �Ƿ���������ȱʡֵ0����������ʱ��Ч��Ϊ0ʱ,����������Ч��PPNGA��MSFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
%     Options.ispop - �Ƿ��Ⱥ�Ż���ȱʡֵ0����������ʱ��Ч��Ϊ0ʱ,��������Ⱥ��PPNGA��MSFLA��SFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
%     Options.Pc - ����Ӧ������ʣ��������ӣ�,ȱʡֵ[0.6,0.99];
%     Options.Pm - ����Ӧ������ʣ��������ӣ�,ȱʡֵ[0.01,0.1];
%     Options.c1 - ����ϵ��1������Ⱥ�㷨,PSO��,ȱʡֵ2;
%     Options.c2 - ����ϵ��2������Ⱥ�㷨,PSO��,ȱʡֵ2;
%     Options.w1 - ����Ȩϵ��1������Ⱥ�㷨,PSO��,ȱʡֵ0.9;
%     Options.w2 - ����Ȩϵ��2������Ⱥ�㷨,PSO��,ȱʡֵ0.4;
%     Options.limit - ������Ʋ�������Ⱥ�㷨,ABC��,ȱʡֵ50;
%     Options.F - �������ӣ���ֽ����㷨,DEr1��DEb2��,ȱʡֵ[0,1];
%     Options.CR - ������ʣ���ֽ����㷨,DEr1��DEb2��,ȱʡֵ[0.8,1];
%
% �������:
% x - ���Ž�
% f - ������Ӧ��
% F - ����������Ӧ��

%---------------------------------------
% ���������ȡ

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
    K = [0,1];                        % �������ӣ���ֽ����㷨,DE��
end
if isfield(Options,'CR')
    CR = Options.CR;
else
    CR = [0.8,1];                       % ������ʣ���ֽ����㷨,DE��
end

%---------------------------------------
% ����Ϸ��Լ��

if (maxmin~=1 && maxmin~=-1)
    error('Options.maxminΪ1��-1');
end
if length(Lb)~=1 && length(Lb)~=dim
    error('Options.Lb�ĳ���Ϊ1��dim');
end
if length(Ub)~=1 && length(Ub)~=dim
    error('Options.Ub�ĳ���Ϊ1��dim');
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
% GA��������

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
