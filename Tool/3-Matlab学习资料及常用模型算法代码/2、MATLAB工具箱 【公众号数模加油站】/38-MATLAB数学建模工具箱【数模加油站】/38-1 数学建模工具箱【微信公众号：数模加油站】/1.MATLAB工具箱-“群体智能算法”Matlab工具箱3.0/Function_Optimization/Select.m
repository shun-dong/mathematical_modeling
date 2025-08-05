function [Population2,I] = Select(Population1)
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

X1 = Population1.X;
F1 = Population1.F;
popsize = length(F1);

X2 = X1;
F2 = F1;
I = zeros(popsize,1);
for i = 1:popsize
    j = ceil(popsize*rand());
    J = [1:j-1,j+1:popsize];
    k = J(ceil((popsize-1)*rand()));
    
    if F1(j)>F1(k)
        F2(i) = F1(j);
        X2(i,:) = X1(j,:);
        I(i) = j;
    else
        F2(i) = F1(k);
        X2(i,:) = X1(k,:);
        I(i) = k;
    end
end

Population2.X = X2;
Population2.F = F2;
Population2.x = Population1.x;
Population2.f = Population1.f;

end