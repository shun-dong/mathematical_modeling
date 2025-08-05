function [Population2] = Mutate(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pm,ismu)
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

if nargin<8
    ismu = 1;
end

if ismu==0
    Population2 = Population1;
    return;
end

%--------------------------------------

% Pm = [0.01,0.1];                   % ����Ӧ������ʷ�Χ(����Ǳ���,����ʹ̶�)
[XMutate,FMutate,I] = MutateIndex(Population1.X,Population1.F,Pm);
% ������Ӧ������ʸ���Pm����������Ⱥ��PMutate������Ӧ��FMutate
% ���������
% X1 - Ⱥ�壨ÿһ��һ�����壩
% F1 - Ⱥ����Ӧ�ȣ���������
% Pm - ����Ӧ������ʷ�Χ
% ���������
% XMutate - ����Ⱥ�壨ÿһ��һ�����壩
% FMutate - ����Ⱥ����Ӧ�ȣ���������
% I - ����Ⱥ�����

m = length(I);                          % ����ĸ�����

X2 = Population1.X;
F2 = Population1.F;

[tmp,imax] = max(F2);
if m>0
    Par = XMutate;
    F_Par = FMutate;
    
    [Off,F_Off] = MutateSub(Par,fitness,Parmaters,maxmin,Lb,Ub);
    % ���������
    % Par - ����Ⱥ��
    % fitness - �Ż�����
    % Parmaters - ��������   
    % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
    % Lb - �����½�
    % Ub - �����Ͻ�
    % ���������
    % Off - �Ӵ�Ⱥ��
    % F_Off - �Ӵ�Ⱥ����Ӧ��
    
    for i = 1:m
        if I(i)==imax && F_Par(i)>F_Off(i)    % ��Ѹ���1+1����
            Off(i,:) = Par(i,:);
            F_Off(i) = F_Par(i);
        end
    end

    F2(I) = F_Off;
    X2(I,:) = Off;
    
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
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
