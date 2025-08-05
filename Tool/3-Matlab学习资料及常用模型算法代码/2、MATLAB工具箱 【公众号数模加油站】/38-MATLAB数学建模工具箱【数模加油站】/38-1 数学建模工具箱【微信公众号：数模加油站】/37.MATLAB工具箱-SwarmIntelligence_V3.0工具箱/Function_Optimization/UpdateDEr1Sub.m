function [Off,F_Off] = UpdateDEr1Sub(Par,F_Par,fitness,Parmaters,maxmin,Lb,Ub,K,CR)
% UpdateDEr1�㷨�Ӻ���
% ���������
% Par - ����Ⱥ��
% fitness - �Ż�����
% Parmaters - ��������   
% maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
% Lb - �����½�
% Ub - �����Ͻ�
% K - ��������
% CR - �������
% ���������
% Off - �Ӵ�Ⱥ��
% F_Off - �Ӵ�Ⱥ����Ӧ��

[popsize,dim] = size(Par);
K_Array = min(K)+(max(K)-min(K))*rand(popsize,1);             % �������
CR_Array = min(CR)+(max(CR)-min(CR))*rand(popsize,1);         % �������

I = zeros(popsize,3);
for i = 1:popsize
    J = 1:popsize;
    J(i) = [];
    
    try
        I(i,:) = J(randperm(popsize-1,3));
    catch
        I(i,:) = Shuffle(J,3);
    end    
    % ϴ�ƺ���
    % �������:
    % All - ���е���
    % d - һ�����õ����Ƶ�����
    % �������:
    % Ones - һ�����õ�����
    % I2 - �Ƶ����
end
V = Par(I(:,1),:)+repmat(K_Array,1,dim).*(Par(I(:,2),:)-Par(I(:,3),:));

p1 = rand(size(Par))<=repmat(CR_Array,1,dim);                 % �������λ��
p2 = zeros(size(Par));
J = ceil(dim*rand(popsize,1));
for i = 1:popsize
    p2(i,J(i)) = 1;                             % �ض�����λ��
end
p = p1 | p2;                                            % �����λ��
U = V.*p+Par.*(1-p);                                     % �������

U = max(U,repmat(Lb',popsize,1));                       % �߽紦��
U = min(U,repmat(Ub',popsize,1));
if isempty(Parmaters)
    F = maxmin*feval(fitness,U);
else
    F = maxmin*feval(fitness,U,Parmaters);
end

F4 = [F_Par,F];
[F_Off,I4] = max(F4,[],2);                                % �������2+2ѡ��
Off = zeros(size(Par));
for i = 1:popsize
    tmp4 = [Par(i,:);U(i,:)];
    Off(i,:) = tmp4(I4(i),:);
end

end
