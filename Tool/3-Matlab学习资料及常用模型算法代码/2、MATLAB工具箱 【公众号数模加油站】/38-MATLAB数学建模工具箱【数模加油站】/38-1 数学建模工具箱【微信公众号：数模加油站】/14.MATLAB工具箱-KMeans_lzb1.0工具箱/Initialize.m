function [M] = Initialize(X,c)
% ��c-1����Ľ���õ�c����Ĵ����
% �ο�����
% ������ ����. ģʽʶ��[M]. ����:�廪��ѧ������. 1999. p236
%
% �������:
% X - ������,ÿһ��һ����
% c - ����������
%
% �������:
% M - ��������,ÿһ��һ����

n = size(X,2);              % ��������
M = zeros(size(X,1),c);     % ��c-1����Ľ���õ�c����Ĵ����
M(:,1) = mean(X,2);
Dis = zeros(1,n);
for i = 2:c
    for k = 1:n
        d0 = inf;
        for j = 1:i-1
            d1 = norm(X(:,k)-M(:,j));
            if d1<d0
                d0 = d1;
            end
        end
        Dis(k) = d0;
    end
    [tmp,m] = max(Dis);
    M(:,i) = X(:,m);
end

% figure;
% plot(X(1,:),X(2,:),'k.'); hold on; 
% plot(M(1,:),M(2,:),'r.','MarkerSize',30); hold off;
% title('��c-1����Ľ���õ�c����Ĵ����')
