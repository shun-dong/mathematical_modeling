function F = F3_Rastrigin(X,Parmaters)
% �Ż�������Rastrigin�����������㷨��
% ȫ����СX=0,0,...,��СֵΪF=0��Ϊ��庯�����ڶ�����Χ�ڴ�Լ����10D���ֲ���С��
% �Ż�����(�����㷨)
% �������:
% X - �����������popsize*dim�ľ���
% Parmaters - ��Options.Parmaters����ĺ����������޲���ʱ��ʹ�ã�
% �������:
% F - ���������popsize*1�ľ���

%--------------------------------------------------------------------------
% ȫ����СX=0,0,... ,��СֵΪF=0

% �������������ݷ�ʽ��
% Options.Parmaters.p1 = a;
% Options.Parmaters.p2 = b;
% 
% ���������ȡ��ʽ��
% a = Parmaters.p1;
% b = Parmaters.p2;

A = Parmaters;
F = sum(X.^2-A*cos(2*pi*X)+A,2);

end

