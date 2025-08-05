function [XCross,FCross,I] = CrossIndex(X1,F1,Pc)
% ����Ӧ����������������Ӧ������ʸ���Pc������뽻��Ⱥ��PCross������Ӧ��FCross
% ���������
% X1 - Ⱥ�壨��������
% F1 - Ⱥ����Ӧ��
% Pc - ����Ӧ������ʷ�Χ
% ���������
% XCross - ����Ⱥ�壨��������
% FCross - ����Ⱥ����Ӧ�ȣ��ѽ������У�
% I - ����Ⱥ�����

if nargin<3
    Pc = [0.6,0.9];
end

popsize = length(F1);

f_max = max(F1);
f_avg = mean(F1);
I = find(F1>f_avg);                     % ����ƽ�����±�
J = (1:popsize)';
J(I) = [];                              % С��ƽ�����±�

pc1 = max(Pc);
pc2 = min(Pc);

pc = zeros(popsize,1);
pc(I) = pc1-(pc1-pc2)*(F1(I)-f_avg)/(f_max-f_avg);      % ����ƽ���������С
pc(J) = pc1*ones(length(J),1);                          % С��ƽ��������ʴ�

%--------------------

P = rand(popsize,1);                        % ����[0,1]�����
I = find(P<pc);

if ~isempty(I)
    [FCross,J] = sort(F1(I),'descend');         % ��������
    I = I(J);
    XCross = X1(I,:);

    if mod(length(I),2)                         % �����ü���ż��
        XCross = XCross(1:end-1,:);
        FCross = FCross(1:end-1);
        I = I(1:end-1);
    end
else
    XCross = [];
    FCross = [];
end

end

