function [Population2] = CrossGa(Population1,fitness,Parmaters,maxmin,Lb,Ub,Pc)
% �Ŵ��������
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
% Pc - ����Ӧ������ʷ�Χ
% �������:
% Population - ����Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��(�ѽ�������)
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

% Pc = [0.6,0.9];                    % ����Ӧ������ʷ�Χ(����Ǳ���,����ʹ̶�)
[XCross,FCross,I] = CrossIndex(Population1.X,Population1.F,Pc);
% ������Ӧ������ʸ���Pc������뽻��Ⱥ��PCross������Ӧ��FCross
% ���������
% X1 - Ⱥ�壨��������
% F1 - Ⱥ����Ӧ��
% Pc - ����Ӧ������ʷ�Χ
% ���������
% XCross - ����Ⱥ�壨��������
% FCross - ����Ⱥ����Ӧ�ȣ��ѽ������У�
% I - ����Ⱥ�����

X2 = Population1.X;
F2 = Population1.F;

c = length(I)/2;                                % �������
if c>0
    
    Par1 = XCross(1:c,:);
    Par2 = XCross(c+1:end,:);
    F_Par1 = FCross(1:c);
    F_Par2 = FCross(c+1:end);
    
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
    % D - �Ŷ��뾶������������Ӧÿһά��
    % ���������
    % Off1 - �Ӵ�Ⱥ��1
    % F_Off1 - �Ӵ�Ⱥ��1��Ӧ��
    % Off2 - �Ӵ�Ⱥ��2
    % F_Off2 - �Ӵ�Ⱥ��2��Ӧ��
    
    F4 = [F_Par1,F_Par2,F_Off1,F_Off2];
    [tmp,I4] = sort(F4,2,'descend');            % �������2+2ѡ��
    F_Off1 = tmp(:,1);
    F_Off2 = tmp(:,2);
    for i = 1:c
        tmp4 = [Par1(i,:);Par2(i,:);Off1(i,:);Off2(i,:)];
        Off1(i,:) = tmp4(I4(i,1),:);
        Off2(i,:) = tmp4(I4(i,2),:);
    end
    
    X2(I,:) = [Off1;Off2];
    F2(I) = [F_Off1;F_Off2];
end

Population2.X = X2;
Population2.F = F2;
[Population2.f,imax] = max(F2);
Population2.x = X2(imax,:);

if Population2.f<Population1.f
    Population2.f = Population1.f;
    Population2.x = Population1.x;
end

end
