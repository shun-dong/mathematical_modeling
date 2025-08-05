function [Population2] = CrossMsfla(Population1,fitness,Parmaters,maxmin,Lb,Ub,x,f)
% MSFLA�������
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

%---------------------------------------

d = size(Population1.X,1);
c = d-1;

X2 = Population1.X;
F2 = Population1.F;

Par1 = X2(2:d,:);
Par2 = repmat(X2(1,:),c,1);
F_Par1 = F2(2:d);
F_Par2 = repmat(F2(1),c,1);

% [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

%---------------------------------------
% ������ǿ

% F4 = [F_Par1,F_Off1,F_Off2];
% [F_Off,I4] = max(F4,[],2);            % �������2+2ѡ��
% Off = zeros(size(Off1));
% for i = 1:c
%     tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
%     Off(i,:) = tmp4(I4(i),:);
% end

F4 = [F_Par1,F_Off1];
[F_Off,I4] = max(F4,[],2);            % �������2+2ѡ��
Off = zeros(size(Off1));
for i = 1:c
    tmp4 = [Par1(i,:);Off1(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

X2(2:d,:) = Off;                      % ��Ⱥ����
F2(2:d) = F_Off;

%---------------------------------------

I5 = find(F_Par1==F_Off);              % ��һ���޸��Ƶ��±�
if ~isempty(I5)
    
    c = length(I5);
    Par1 = Par1(I5,:);
    Par2 = repmat(x,c,1);
    F_Par1 = F_Par1(I5);
    F_Par2 = repmat(f,c,1);
    
%     [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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
    
%     F4 = [F_Par1,F_Off1,F_Off2];
%     [F_Off,I4] = max(F4,[],2);             % �������2+2ѡ��
%     Off = zeros(size(Off1));
%     for i = 1:c
%         tmp4 = [Par1(i,:);Off1(i,:);Off2(i,:)];
%         Off(i,:) = tmp4(I4(i),:);
%     end
    
    F4 = [F_Par1,F_Off1];
    [F_Off,I4] = max(F4,[],2);             % �������2+2ѡ��
    Off = zeros(size(Off1));
    for i = 1:c
        tmp4 = [Par1(i,:);Off1(i,:)];
        Off(i,:) = tmp4(I4(i),:);
    end    
    
    X2(I5+1,:) = Off;                      % ��Ⱥ�ڶ��θ���
    F2(I5+1) = F_Off;
    
    I6 = find(F_Par1==F_Off);              % �ڶ����޸��Ƶ��±�
    if ~isempty(I6)
        c = length(I6);
        
        tmp = Initialize(fitness,Parmaters,maxmin,Lb,Ub,c);
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
        
        X2(I5(I6)+1,:) = tmp.X;
        F2(I5(I6)+1) = tmp.F;
    end
end

%---------------------------------------

Par1 = X2(1,:);                             % ��Ⱥ���ֵ����
Par2 = x;
F_Par1 = F2(1);
F_Par2 = f;

% [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub);
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

% F4 = [F_Par1,F_Off1,F_Off2];
% [F_Off,i4] = max(F4,[],2);            % �������2+2ѡ��
% tmp4 = [Par1;Off1;Off2];
% Off = tmp4(i4,:);

F4 = [F_Par1,F_Off1];
[F_Off,i4] = max(F4,[],2);            % �������2+2ѡ��
tmp4 = [Par1;Off1];
Off = tmp4(i4,:);

X2(1,:) = Off;
F2(1) = F_Off;
    
%---------------------------------------

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end

