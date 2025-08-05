function [Off,F_Off] = MutateSub(Par,fitness,Parmaters,maxmin,Lb,Ub,T)
% ��������Ӻ���
% ���������
% Par - ����Ⱥ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% T - ����λ�ã����ȱ�����size(Par,1)��ͬ����ȱʡλ�����
% ���������
% Off - �Ӵ�Ⱥ��
% F_Off - �Ӵ�Ⱥ����Ӧ��

if nargin<7
    [popsize,dim] = size(Par);
    T = ceil(dim*rand(popsize,1));          % ����λ��  1~dim(����)
end

Off = Par;
for i = 1:size(Par,1)
    j = T(i);
    a = Lb(j);
    b = Ub(j);
    Off(i,j) = a + (b-a)*rand();
end
if isempty(Parmaters)
    F_Off = maxmin*feval(fitness,Off);
else
    F_Off = maxmin*feval(fitness,Off,Parmaters);
end

end

