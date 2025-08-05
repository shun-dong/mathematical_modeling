function [Off1,F_Off1,Off2,F_Off2] = CrossSub(Par1,F_Par1,Par2,F_Par2,fitness,Parmaters,maxmin,Lb,Ub)
% ���������Ӻ���
% ���������
% Par1 - ����Ⱥ��1
% F_Par1 - ����Ⱥ��1��Ӧ��
% Par2 - ����Ⱥ��2
% F_Par2 - ����Ⱥ��2��Ӧ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% ���������
% Off1 - �Ӵ�Ⱥ��1
% F_Off1 - �Ӵ�Ⱥ��1��Ӧ��
% Off2 - �Ӵ�Ⱥ��2
% F_Off2 - �Ӵ�Ⱥ��2��Ӧ��

Off1 = Par1;
F_Off1 = F_Par1;
Off2 = Par2;
F_Off2 = F_Par2;

I = find((F_Par1-F_Par2)~=0);                           % ���岻���ʱ����
J = find((F_Par1-F_Par2)==0);                           % �������ʱ����

c = length(I);
dim = size(Par1,2);
Index = rand(c,dim);

Off1(I,:) = (1-Index).*Par1(I,:)+Index.*Par2(I,:);              % ���Ƚ���
if isempty(Parmaters)
    F_Off1(I) = maxmin*feval(fitness,Off1(I,:));
else
    F_Off1(I) = maxmin*feval(fitness,Off1(I,:),Parmaters);
end
[Off1(J,:),F_Off1(J)] = MutateSub(Par1(J,:),fitness,Parmaters,maxmin,Lb,Ub);  % �������
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

if nargout>2
    Off2(I,:) = Index.*Par1(I,:)+(1-Index).*Par2(I,:);          % ���Ƚ���
    if isempty(Parmaters)
        F_Off2(I) = maxmin*feval(fitness,Off2(I,:));
    else
        F_Off2(I) = maxmin*feval(fitness,Off2(I,:),Parmaters);
    end
    [Off2(J,:),F_Off2(J)] = MutateSub(Par2(J,:),fitness,Parmaters,maxmin,Lb,Ub);  % �������
end

end
