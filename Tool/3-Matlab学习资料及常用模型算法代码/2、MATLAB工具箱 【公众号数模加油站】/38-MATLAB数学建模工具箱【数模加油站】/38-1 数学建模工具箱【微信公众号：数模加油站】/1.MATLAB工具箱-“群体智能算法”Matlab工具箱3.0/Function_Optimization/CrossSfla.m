function [Population2] = CrossSfla(Population1,fitness,Parmaters,maxmin,Lb,Ub,x,f)
% SFLA�������
% �������:
% Population - ����Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% x - ����Ⱥ���Ÿ���
% f - ����Ⱥ���Ÿ�����Ӧ��
% �������:
% Population - ����Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��(�ѽ�������)
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

%--------------------------------------

d = size(Population1.X,1);
c = d-1;

X2 = Population1.X;
F2 = Population1.F;
for i = 1:c
    Par1 = X2(end,:);
    Par2 = X2(1,:);
    F_Par1 = F2(end);
    F_Par2 = F2(1);
    
    %--------------------------------------
    
    [Off1,F_Off1] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
    % ���������Ӻ���
    % ���������
    % Par1 - ����Ⱥ��1
    % F_Par1 - ����Ⱥ��1��Ӧ��
    % Par2 - ����Ⱥ��2
    % F_Par2 - ����Ⱥ��2��Ӧ��
    % fitness - �Ż�����
    % Parmaters - ��������   
    % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
    % Lb - �����½�
    % Ub - �����Ͻ�
    % ���������
    % Off1 - �Ӵ�Ⱥ��1
    % F_Off1 - �Ӵ�Ⱥ��1��Ӧ��
    % Off2 - �Ӵ�Ⱥ��2
    % F_Off2 - �Ӵ�Ⱥ��2��Ӧ��
    
    if F_Off1>F_Par1
        X2(end,:) = Off1;
        F2(end) = F_Off1;
    else
        Par2 = x;
        F_Par2 = f;
        
        [Off1,F_Off1] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
        % ���������Ӻ���
        % ���������
        % Par1 - ����Ⱥ��1
        % F_Par1 - ����Ⱥ��1��Ӧ��
        % Par2 - ����Ⱥ��2
        % F_Par2 - ����Ⱥ��2��Ӧ��
        % fitness - �Ż�����
        % Parmaters - ��������   
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % ���������
        % Off1 - �Ӵ�Ⱥ��1
        % F_Off1 - �Ӵ�Ⱥ��1��Ӧ��
        % Off2 - �Ӵ�Ⱥ��2
        % F_Off2 - �Ӵ�Ⱥ��2��Ӧ��
        
        if F_Off1>F_Par1
            X2(end,:) = Off1;
            F2(end) = F_Off1;
        else
            tmp = Initialize(fitness,Parmaters,maxmin,Lb,Ub,1);
            X2(end,:) = tmp.X;
            F2(end) = tmp.F;            
        end
    end
    [F2,I2] = sort(F2,'descend');
    X2 = X2(I2,:);
end

Population2.X = X2;
Population2.F = F2;
Population2.x = X2(1,:);
Population2.f = F2(1);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end


