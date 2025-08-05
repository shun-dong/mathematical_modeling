function [T,N,je,M2] = KMeans(X,M)
% K-Means ����
% �ο�����
% Richard O.Duda ��,��궫 ��. ģʽ����[M]. ����:��е��ҵ������. 2003. p424
%
% �������:
% X  - ������,ÿһ��һ����
% M  - ��������,ÿһ��һ����
%
% �������:
% T  - ����ǩ,��ʸ��
% N  - ÿһ�����
% je - ���ۺ���ֵ
% M2 - �¾�������,ÿһ��һ����


[d,n] = size(X);                        % ��������
[d,c] = size(M);
D = zeros(c,n);                         % �������
for i = 1:c
    tmp1 = X - repmat(M(:,i),1,n);
    D(i,:) = sum(tmp1.^2);              % ���������ĵľ����ƽ��
end
D = full(compet(1./(D+1e-50)));         % �������ȡ1,����Ϊ0

T = zeros(1,n);
for j = 1:n
    for i = 1:c
        if (D(i,j)==1)
            T(j) = i;                   % ����ǩ
            break;
        end
    end
end

if nargout>1
    
    N = zeros(1,c);
    for i = 1:c
        J = find(T==i);
        nj = length(J);
        N(i) = nj;                          % ÿһ�����
    end
    
    if nargout>2

        je = 0;
        for i = 1:c
            J = find(T==i);
            nj = length(J);
            tmp1 = X(:,J)-repmat(M(:,i),1,nj);
            je = je + sum(tmp1(:).^2);          % ���ۺ���
        end
        
        if nargout>3

            M2 = zeros(d,c);
            for i = 1:c
                J = find(T==i);
                tmp2 = mean(X(:,J),2);
                M2(:,i) = tmp2;                     % ����ʸ������(��������)
            end
            
            
            J = find(sum(M2)==0);                   % �п���ĳЩ��һ��������û�У�ֱ��ɾ��
            M2(:,J) = [];
            
        end
    end
end

