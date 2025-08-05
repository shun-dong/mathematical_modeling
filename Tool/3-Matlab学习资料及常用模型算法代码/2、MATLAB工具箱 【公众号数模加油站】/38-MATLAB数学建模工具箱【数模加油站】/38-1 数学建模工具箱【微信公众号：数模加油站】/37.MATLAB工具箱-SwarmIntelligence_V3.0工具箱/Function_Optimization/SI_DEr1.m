function [x,f,F] = SI_DEr1(Options)
% DEr1����׼����㷨(DE/rand/1/bin)
disp('--- ��׼����㷨(DE/rand/1/bin)��Differential Evolution Algorithms,DE�� ---');
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

%--------------------------------------
% ������ʼ��Ⱥ

popsize_sub = max(round(sqrt(popsize)),6);    % ����Ⱥ��ģ
popnum_sub = ceil(popsize/popsize_sub);       % ����Ⱥ����
popsize = popsize_sub*popnum_sub;             % ��Ⱥ��ģ
Options.popsize = popsize;

[Population1] = Initialize(fitness,Parmaters,maxmin,Lb,Ub,popsize,seed);
% ��Ⱥ��ʼ��
% �������:
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% popsize - ��Ⱥ��ģ
% seed - ��ʼ���������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% ���PSO�ر���
%     Population.V - �����ٶ�
%     Population.Xp - ��ʷ����(������)
%     Population.Fp - ��ʷ������Ӧ��

%--------------------------------------

F = zeros(maxgen,1);                                            % �����ʾ
for gen = 1:maxgen
    
    ispop = 1;
    if ispop==1
        
        [tmp,I] = sort(Population1.F,'descend');          % Population1�������
        J = reshape(I,popnum_sub,popsize_sub);
        J = J';
        for j = 1:popnum_sub
            
            Population2.X = Population1.X(J(:,j),:);      % ����Ⱥ
            Population2.F = Population1.F(J(:,j));
            Population2.x = Population2.X(1,:);           % ����Ⱥ
            Population2.f = Population2.F(1);        
            
            Population2 = UpdateDEr1(Population2,fitness,Parmaters,maxmin,Lb,Ub,K,CR);
            Population2 = Mutate(Population2,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu);
            Population2 = Disturb(Population2,fitness,Parmaters,maxmin,Lb,Ub,quick);
            
            Population1.X(J(:,j),:) = Population2.X;      % ����Ⱥ
            Population1.F(J(:,j)) = Population2.F;
        end        
        
    else
        
        Population1 = UpdateDEr1(Population1,fitness,Parmaters,maxmin,Lb,Ub,K,CR);
        % ��Ⱥ����
        % ���������
        % Population - ��Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        % fitness - �Ż�����
        % Parmaters - ��������
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % K - ��������
        % CR - �������
        % ���������
        % Population - ��Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        
        Population1 = Mutate(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu);
        % �������
        % �������:
        % Population - ����Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        % ���PSO�ر���
        %     Population.V - �����ٶ�
        %     Population.Xp - ��ʷ����(������)
        %     Population.Fp - ��ʷ������Ӧ��
        % fitness - �Ż�����
        % Parmaters - ��������
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % Pm - ����Ӧ������ʷ�Χ
        % ismu - �Ƿ���������ȱʡΪ1��
        % �������:
        % Population - ����Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��(�ѽ�������)
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        % ���PSO�ر���
        %     Population.V - �����ٶ�
        %     Population.Xp - ��ʷ����(������)
        %     Population.Fp - ��ʷ������Ӧ��
        
        Population1 = Disturb(Population1,fitness,Parmaters,maxmin,Lb,Ub,quick);
        % �Ŷ�����
        % �������:
        % Population - ��Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        % fitness - �Ż�����
        % Parmaters - ��������
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % quick - ���Ž���ٴ�����ȱʡΪ0��
        % �������:
        % Population - ��Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��
        
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
    % �������ʾ
    
    if mod(gen,show)==0
        str = num2str(x(1),'%.4f');
        for j = 2:length(x)
            str = [str,', ',num2str(x(j),'%.4f')];
        end
        disp(['DEr1, gen=',num2str(gen),', fval=',num2str(f,16),', x=',str]);
%         disp(['DEr1, gen=',num2str(gen),', fval=',num2str(f,16)]);
    end
    
    %---------------------------------------
    % ��ǰ�˳�
    
    if (maxmin==-1 && f<tolfun) || (maxmin==1 && f>tolfun)
        F = F(1:gen);
        x
        f
        disp('------ �������tolfun��������ֹ ------')
        return;
    end
    if (gen>localmin) && (F(gen)==F(gen-localmin))
        F = F(1:gen);
        x
        f    
        disp('------ �������localmin�β����£�������ֹ ------')
        return;
    end    
end
x
f
disp('------ ����������������������ֹ ------')

end

