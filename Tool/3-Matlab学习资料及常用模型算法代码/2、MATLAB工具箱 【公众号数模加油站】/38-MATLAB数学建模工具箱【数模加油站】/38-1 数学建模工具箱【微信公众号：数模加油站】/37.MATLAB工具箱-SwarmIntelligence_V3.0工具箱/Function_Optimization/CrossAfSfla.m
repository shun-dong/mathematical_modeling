function [Population2] = CrossAfSfla(Population1,Neighbor,fitness,Parmaters,maxmin,Lb,Ub)
% ��Ⱥ�������
% ���������
% Population1 - ��ʼ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% Neighbor - ��֪��Χ������
%     Neighbor.X - ������Ӧ��������
%     Neighbor.F - ������Ӧ����������Ӧ��
%     Neighbor.I - ��������
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% ���������
% Population2 - ������Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

popsize = length(Population1.F);

Par1 = Population1.X;
F_Par1 = Population1.F;
Par2 = Neighbor.X;
F_Par2 = Neighbor.F;

[Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

%--------------------
% ������ǿ

F4 = [F_Par1,F_Off1,F_Off2];
[F_Off,I4] = max(F4,[],2);                      % �������2+2ѡ��
Off = zeros(size(Off1));
for i = 1:popsize
    tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

Population2.X = Off;
Population2.F = F_Off;

%--------------------

I5 = find(F_Par1==F_Off);                       % ��һ���޸��Ƶ��±�
if ~isempty(I5)
    
    c = length(I5);
    Par1 = Population1.X(I5,:);
    F_Par1 = Population1.F(I5);
    Par2 = repmat(Population1.x,c,1);
    F_Par2 = repmat(Population1.f,c,1);
    
    [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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
    
    F4 = [F_Par1,F_Off1,F_Off2];
    [F_Off,I4] = max(F4,[],2);                     % �������2+2ѡ��
    Off = zeros(size(Off1));
    for i = 1:c
        tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
        Off(i,:) = tmp4(I4(i),:);
    end
    
    Population2.X(I5,:) = Off;                  % ��Ⱥ�ڶ��θ���
    Population2.F(I5) = F_Off;
    
    I6 = find(F_Par1==F_Off);                   % �ڶ����޸��Ƶ��±�
    if ~isempty(I6)
        
        c = length(I6);
        tmp5 = Initialize(fitness,Parmaters,maxmin,Lb,Ub,c);
        % ��Ⱥ��ʼ��
        % �������:
        % fitness - �Ż�����
        % Parmaters - ��������   
        % maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
        % Lb - �����½�
        % Ub - �����Ͻ�
        % popsize - ��Ⱥ��ģ
        % �������:
        % Population - ��Ⱥ
        %     Population.X - ��Ⱥ(������)
        %     Population.F - ��Ⱥ��Ӧ��(�ѽ�������)
        %     Population.x - ���Ÿ���
        %     Population.f - ���Ÿ�����Ӧ��          

        Population2.X(I5(I6),:) = tmp5.X;
        Population2.F(I5(I6)) = tmp5.F;
    end
end

%--------------------

[Population2.f,imax] = max(Population2.F);
Population2.x = Population2.X(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end

