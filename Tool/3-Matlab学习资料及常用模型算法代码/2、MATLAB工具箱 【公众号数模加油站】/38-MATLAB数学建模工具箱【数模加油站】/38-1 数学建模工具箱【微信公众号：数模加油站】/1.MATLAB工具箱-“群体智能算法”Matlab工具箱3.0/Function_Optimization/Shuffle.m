function [Ones,I2] = Shuffle(Alls,d)
% ϴ�ƺ���
% �������:
% All - ���е���
% d - һ�����õ����Ƶ�����
% �������:
% Ones - һ�����õ�����
% I2 - �Ƶ����

m = length(Alls);
I1 = 1:m;
I2 = zeros(1,d);
for i = 1:d
    j = ceil(length(I1)*rand());        % ����������
    I2(i) = I1(j);                      % ����ѡ��
    I1(j) = [];                         % ��ԭ������ɾ������ѡ��
end
Ones = Alls(I2);