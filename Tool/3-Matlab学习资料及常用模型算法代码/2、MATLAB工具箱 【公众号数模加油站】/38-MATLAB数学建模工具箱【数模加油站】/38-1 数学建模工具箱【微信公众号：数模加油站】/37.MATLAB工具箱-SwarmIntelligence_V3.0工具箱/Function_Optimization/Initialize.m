function [Population] = Initialize(fitness,Parmaters,maxmin,Lb,Ub,popsize,seed)
% ��Ⱥ��ʼ��
% �������:
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% popsize - ��Ⱥ��ģ
% seed - ��ʼ���������
% �������:
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% ���PSO�ر���
%     Population.V - �����ٶ�
%     Population.Xp - ��ʷ����(������)
%     Population.Fp - ��ʷ������Ӧ��

%---------------------------------------

if nargin<7
    seed = sum(100*clock);
end

rand('state',seed);     % ��ʼ�����������
% rng('shuffle');

num = length(Lb);                   % ��������
X = zeros(popsize,num);
for j = 1:num
    a = Lb(j);
    b = Ub(j);
    X(:,j) = a + (b-a).*rand(popsize,1);
    
%     X(:,j) = a-1+ceil((b-a+1).*rand(popsize,1));      % ������
end
if isempty(Parmaters)
    F = maxmin*feval(fitness,X);
else
    F = maxmin*feval(fitness,X,Parmaters);
end

%---------------------------------------

Population.X = X;
Population.F = F;
[Population.f,imax] = max(F);
Population.x = X(imax,:);

%---------------------------------------
% ���PSO�ر���

Population.V = zeros(size(X));
Population.Xp = X;
Population.Fp = F;

end
