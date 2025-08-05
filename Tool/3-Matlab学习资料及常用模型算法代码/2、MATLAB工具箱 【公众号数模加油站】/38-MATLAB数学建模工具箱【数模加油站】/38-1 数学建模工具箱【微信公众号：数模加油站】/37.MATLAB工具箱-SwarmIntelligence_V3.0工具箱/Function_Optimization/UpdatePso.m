function [Population2] = UpdatePso(Population1,fitness,Parmaters,maxmin,Lb,Ub,gen,maxgen,c1,c2,w1,w2)
% PSO�㷨����Ⱥ����
% ���������
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.V - �����ٶ�
%     Population.Xp - ��ʷ����(������)
%     Population.Xp - ��ʷ������Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% gen - ��ǰ����
% maxgen - ����������
% c1 - ����ϵ��1
% c2 - ����ϵ��2
% w1 - ����Ȩ1
% w2 - ����Ȩ2
% ���������
% Population - ��Ⱥ
%     Population.X - ��Ⱥ(������)
%     Population.F - ��Ⱥ��Ӧ��
%     Population.V - �����ٶ�
%     Population.Xp - ��ʷ����(������)
%     Population.Fp - ��ʷ������Ӧ��
%     Population.x - ���Ÿ���
%     Population.f - ���Ÿ�����Ӧ��

X1 = Population1.X;
F1 = Population1.F;
V1 = Population1.V;
Xp1 = Population1.Xp;
Fp1 = Population1.Fp;
x1 = Population1.x;
f1 = Population1.f;

popsize = length(F1);

%--------------------------------------------------------------------------

W = linspace(w1,w2,round(maxgen*0.75));
if gen<=round(maxgen*0.75)                      % ϵ����Ȩ
    w = W(gen);
else
    w = w2;
end

%--------------------------------------------------------------------------


MV = 0.2*(Ub-Lb);                               % ����ٶ�ȡ�仯��Χ��10%~20%
V2 = w.*V1+c1.*rand(size(X1)).*(Xp1-X1)+c2.*rand(size(X1)).*(repmat(x1,popsize,1)-X1);
V2 = min(V2,repmat(MV',popsize,1));             % ����

X2 = X1+V2;
X2 = max(repmat(Lb',popsize,1),X2);           % �޷�
X2 = min(repmat(Ub',popsize,1),X2);
if isempty(Parmaters)
    F2 = maxmin*feval(fitness,X2);                  % �Ŷ���Ⱥ����Ӧ��
else
    F2 = maxmin*feval(fitness,X2,Parmaters);                  % �Ŷ���Ⱥ����Ӧ��
end

%--------------------------------------------------------------------------

tmp1 = [F2,Fp1];                                
[Fp2,I] = max(tmp1,[],2);                       % ������ʷ����
Xp2 = zeros(size(Xp1));
for i = 1:popsize
    tmp2 = [X2(i,:);Xp1(i,:)];
    Xp2(i,:) = tmp2(I(i),:);
end

[f2,imax] = max(Fp2);                           % ����ȫ������
x2 = Xp2(imax,:);

%--------------------------------------------------------------------------

Population2.X = X2;
Population2.F = F2;
Population2.V = V2;
Population2.Xp = Xp2;
Population2.Fp = Fp2;
Population2.x = x2;
Population2.f = f2;

end
