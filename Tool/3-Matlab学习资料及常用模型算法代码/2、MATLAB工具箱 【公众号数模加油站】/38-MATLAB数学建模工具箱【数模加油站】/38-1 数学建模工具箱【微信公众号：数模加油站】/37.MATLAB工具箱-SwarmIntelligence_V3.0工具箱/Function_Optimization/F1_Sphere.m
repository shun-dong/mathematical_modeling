function F = F1_Sphere(X,Parmaters)
% �Ż�������Sphere�����������㷨��
% ȫ����СX=0,0,...,��СֵΪF=0
% ��K.A.De Jong�����,������Sphere����,��������Xi=0�ﵽ��Сֵ0,���庯��,һ�����ڿ����㷨����
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

F = sum(X.^2,2);

end
