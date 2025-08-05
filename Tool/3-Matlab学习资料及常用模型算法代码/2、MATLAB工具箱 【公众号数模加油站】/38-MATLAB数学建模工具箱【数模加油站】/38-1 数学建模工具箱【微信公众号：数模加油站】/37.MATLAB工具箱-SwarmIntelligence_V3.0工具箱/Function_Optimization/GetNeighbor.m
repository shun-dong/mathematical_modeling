function [Neighbor] = GetNeighbor(Population,neighbor_number)
% ��Ⱥ�㷨�������������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% neighbor_number - ���ڸ�����ȱʡΪpopsize/2��
% �������:
% Neighbor - ��֪��Χ������
%     Neighbor.X - ������Ӧ��������
%     Neighbor.F - ������Ӧ����������Ӧ��
%     Neighbor.I - ��������

[popsize,num] = size(Population.X);
if nargin<2
    neighbor_number = round(popsize/2);
end

D = zeros(popsize,popsize);                 % �����������Լ��ľ���Ϊinf
for i = 1:popsize
    for j = i:popsize
        if (i==j)
            D(i,j) = inf;
        else
            D(i,j) = norm(Population.X(i,:)-Population.X(j,:));
        end
    end
end
D = D+D';

%--------------------

[tmp1,I] = sort(D,2,'ascend');
J = I(:,1:neighbor_number);               % ÿ��������neighbor_number������
tmp2 = Population.F(J);
[FM,IM] = max(tmp2,[],2);                    % �ҳ���Ӧ�����Ľ���

%--------------------

Neighbor.MaxX = zeros(popsize,num);
for i = 1:popsize
    k = J(i,IM(i));                       % ��ȡ��Ӧ�����Ľ���
    Neighbor.X(i,:) = Population.X(k,:);
end
Neighbor.F = FM;
Neighbor.I = IM;

end
