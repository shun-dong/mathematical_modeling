function [XMutate,FMutate,I] = MutateIndex(X1,F1,Pm)
% ����Ӧ����������������Ӧ������ʸ���Pm����������Ⱥ��PMutate������Ӧ��FMutate
% ���������
% X1 - Ⱥ�壨ÿһ��һ�����壩
% F1 - Ⱥ����Ӧ�ȣ���������
% Pm - ����Ӧ������ʷ�Χ
% ���������
% XMutate - ����Ⱥ�壨ÿһ��һ�����壩
% FMutate - ����Ⱥ����Ӧ�ȣ���������
% I - ����Ⱥ�����

if nargin<3
    Pm = [0.1,0.4];
end

popsize = length(F1);

f_max = max(F1);
f_avg = mean(F1);
I = find(F1>f_avg);                     % ����ƽ�����±�
J = (1:popsize)';
J(I) = [];                             % С��ƽ�����±�

pm1 = max(Pm);
pm2 = min(Pm);

pm = zeros(popsize,1);
pm(I) = pm1-(pm1-pm2)*(F1(I)-f_avg)/(f_max-f_avg);
pm(J) = pm1*ones(length(J),1);

%--------------------------

P = rand(popsize,1);                    % ����[0,1]�����
I = find(P<pm);                         % ����ĸ������(����)

XMutate = X1(I,:);
FMutate = F1(I);

end

