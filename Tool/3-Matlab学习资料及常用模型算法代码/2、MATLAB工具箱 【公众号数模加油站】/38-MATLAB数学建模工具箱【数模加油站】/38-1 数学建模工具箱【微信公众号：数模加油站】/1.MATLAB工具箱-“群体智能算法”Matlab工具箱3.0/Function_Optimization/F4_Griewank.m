function F = F4_Griewank(X,Parmaters)
% �Ż�������Griewank�����������㷨��
% ȫ����СX=0,0,...,��СֵΪF=0��Ϊ��ģ̬�������д����ľֲ���ֵ�㣬
% �ֲ���С��Xi=k*pi*sqrt(i),i=1,2,... k=0,1,2,..., �㷨���ҵ����Ž�
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

[popsize,D] = size(X);
F = sum(X.^2,2)/4000-prod(cos(X./repmat([1:D],popsize,1).^0.5),2)+1;

end


