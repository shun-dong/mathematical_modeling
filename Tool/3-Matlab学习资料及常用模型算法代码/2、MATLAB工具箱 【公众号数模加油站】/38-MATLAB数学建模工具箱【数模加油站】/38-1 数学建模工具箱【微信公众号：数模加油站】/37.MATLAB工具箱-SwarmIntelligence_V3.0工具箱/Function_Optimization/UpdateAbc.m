function [Population2] = UpdateAbc(Population1,fitness,Parmaters,maxmin,Lb,Ub)
% ABC�㷨����Ⱥ����
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
% ���������
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

[Population1] = NeighborSearch(Population1,fitness,Parmaters,maxmin,Lb,Ub);
% ��������
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
% Index - ���¸������������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

%----------------------------------------------------------------------
[tmp,I] = Select(Population1);
% ������ѡ��
% �������:
% Population - ����Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% ���������
% Population - ����Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% I - ѡ�и������������

%----------------------------------------------------------------------
[Population2] = NeighborSearch(Population1,fitness,Parmaters,maxmin,Lb,Ub,I);
% ��������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% fitness - �Ż�����
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% Index - ���¸������������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

end
