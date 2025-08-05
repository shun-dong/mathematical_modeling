function [Off,F_Off] = DisturbSub(Par,fitness,Parmaters,maxmin,Lb,Ub,D,T)
% �Ŷ������Ӻ���
% ���������
% Par - ����Ⱥ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% D - �Ŷ��뾶������������Ӧÿһά��
% T - ����λ�ã����ȱ�����size(Par,1)��ͬ����ȱʡλ�����
% ���������
% Off - �Ӵ�Ⱥ��
% F_Off - �Ӵ�Ⱥ����Ӧ��

if nargin<8
    [popsize,dim] = size(Par);
    T = ceil(dim*rand(popsize,1));          % ����λ��  1~dim(����)
end

Off = Par;
for i = 1:size(Par,1)
    j = T(i);                               % ȷ���Ե�ÿһά����
    d = D(j);                               % �Ŷ��뾶
    Off(i,j) = Off(i,j)+2*d*rand()-d;
    
    Off(i,j) = max(Lb(j),Off(i,j));
    Off(i,j) = min(Ub(j),Off(i,j));
end
if isempty(Parmaters)
    F_Off = maxmin*feval(fitness,Off);
else
    F_Off = maxmin*feval(fitness,Off,Parmaters);
end

end

