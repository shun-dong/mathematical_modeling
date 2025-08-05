function [Population2] = Disturb(Population1,fitness,Parmaters,maxmin,Lb,Ub,quick)
% �Ŷ�����
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
% fitness - �Ż�����
% Parmaters - ��������
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% quick - ���Ž���ٴ�����ȱʡΪ20��
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

if nargin<7
    quick = 20;
end

if quick==0
    Population2 = Population1;
    return;
end

X1 = Population1.X;
F1 = Population1.F;

for j = 1:1
    
    [popsize,num] = size(X1);                       % ��Ⱥ��ģ,��������
    D = (max(X1)-min(X1))/2;                        % �Ŷ��뾶
    
    [X2,F2] = DisturbSub(X1,fitness,Parmaters,maxmin,Lb,Ub,D);
    % ���������
    % Par - ����Ⱥ��
    % fitness - �Ż�����
    % Parmaters - ��������
    % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
    % Lb - �����½�
    % Ub - �����Ͻ�
    % D - �Ŷ��뾶������������Ӧÿһά��
    % T - ����λ�ã����ȱ�����size(Par,1)��ͬ����ȱʡλ�����
    % ���������
    % Off - �Ӵ�Ⱥ��
    % F_Off - �Ӵ�Ⱥ����Ӧ��
    
    [F2,K] = max([F1,F2],[],2);
    for i = 1:popsize
        tmp = [X1(i,:);X2(i,:)];
        X2(i,:) = tmp(K(i),:);
    end
    
    X1 = X2;
    F1 = F2;
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,IMAX] = max(F2);
Population2.x = X2(IMAX,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

%--------------------------------------
% ���Ż����Ӧ�ı����͵�ÿ�������ټ�һ��������Ŷ�, �ٶ����Ÿ����滻

if quick>1
    
    x = Population2.x;
    f = Population2.f;
    n = num; % ceil(num*rand());          % n��ȡ��
    m = quick-1;                                % m�ε���
    
    for i = 1:m
        
        x_array = repmat(x,n,1);
        T = 1:n;                          % ����λ��  1~digit(����)
        
        [x_array2,f_array2] = DisturbSub(x_array,fitness,Parmaters,maxmin,Lb,Ub,D,T);
        % ���������
        % Par - ����Ⱥ��
        % fitness - �Ż�����
        % Parmaters - ��������
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % D - �Ŷ��뾶������������Ӧÿһά��
        % T - ����λ�ã����ȱ�����size(Par,1)��ͬ����ȱʡλ�����
        % ���������
        % Off - �Ӵ�Ⱥ��
        % F_Off - �Ӵ�Ⱥ����Ӧ��
        
        [f_max,imax] = max(f_array2);
        x_max = x_array2(imax,:);
        
        if (f_max>f)
            x = x_max;
            f = f_max;
        end
    end
    
    if (f>Population2.f)
        Population2.x = x;
        Population2.f = f;
        Population2.X(IMAX,:) = x;
        Population2.F(IMAX) = f;
    end
    
end

%--------------------------------------
% ���PSO���ر���

try
    Population2.V = Population2.X-Population1.X;
    
    Xp2 = Population1.Xp;
    Fp2 = Population1.Fp;
    X2 = Population2.X;
    F2 = Population2.F;
    
    for i = 1:length(F2)
        if F2(i)>Fp2(i)
            Xp2(i,:) = X2(i,:);
            Fp2(i) = F2(i);
        end
    end
    Population2.Xp = Xp2;
    Population2.Fp = Fp2;
    
    [Population2.f,imax] = max(Fp2);
    Population2.x = Xp2(imax,:);
catch
end

end
