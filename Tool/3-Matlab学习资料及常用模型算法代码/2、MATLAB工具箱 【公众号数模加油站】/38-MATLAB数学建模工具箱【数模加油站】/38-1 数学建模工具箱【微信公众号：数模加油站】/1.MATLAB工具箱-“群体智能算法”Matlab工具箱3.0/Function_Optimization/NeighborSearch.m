function [Population2] = NeighborSearch(Population1,fitness,Parmaters,maxmin,Lb,Ub,Index)
% ABC�㷨����������
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

X1 = Population1.X;
F1 = Population1.F;
[popsize,d] = size(X1);

if nargin<7
    Index = 1:popsize;
end

X2 = X1;
for ii = 1:length(Index)
    i = Index(ii);
    
    I = [1:i-1,i+1:popsize];
    k = I(ceil((popsize-1)*rand()));
    j = ceil(d*rand());
    X2(i,j) = X1(i,j)+(2*rand()-1)*(X1(i,j)-X1(k,j));
    
    X2(i,j) = max(Lb(j),X2(i,j));
    X2(i,j) = min(Ub(j),X2(i,j));    
end
if isempty(Parmaters)
    F2 = maxmin*feval(fitness,X2);                  % �Ŷ���Ⱥ����Ӧ��
else
    F2 = maxmin*feval(fitness,X2,Parmaters);                  % �Ŷ���Ⱥ����Ӧ��
end

[F2,K] = max([F1,F2],[],2);
for i = 1:popsize
    tmp = [X1(i,:);X2(i,:)];
    X2(i,:) = tmp(K(i),:);
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

