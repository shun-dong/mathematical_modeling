function [T,N,jf,M2] = FuzzyKMeans(X,M,b)
% ģ�� K-Means ����
% �ο�����
% [1] ������ ����. ģʽʶ��[M]. ����:�廪��ѧ������. 1999. p280
% [2] Richard O.Duda ��,��궫 ��. ģʽ����[M]. ����:��е��ҵ������. 2003. p425-426
%
% �������:
% X  - ������,ÿһ��һ����
% M  - ��������,ÿһ��һ����
% b  - ����b
%
% �������:
% T  - ����ǩ,��ʸ��
% N  - ÿһ�����
% jf - ���ۺ���ֵ
% M2 - �¾�������,ÿһ��һ����

[d,n] = size(X);                        % ��������
[d,c] = size(M);
U = zeros(c,n);                         % �����Ⱦ���
for i = 1:c
    tmp1 = X - repmat(M(:,i),1,n);
    U(i,:) = sum(tmp1.^2);              % ���������ĵľ����ƽ��
end
U = 1./(U+1e-50);
U = U.^(1/(b-1));
U = U./repmat(sum(U),c,1);              % �����Ⱦ���

T = zeros(1,n);
D = full(compet(U));
for j = 1:n
    for i = 1:c
        if (D(i,j)==1)
            T(j) = i;
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

        jf = 0;
        for i = 1:c
            jf = jf + sum(U(i,:).^b.*sum((X - repmat(M(:,i),1,n)).^2));
        end

        if nargout>3

            M2 = zeros(d,c);
            for i = 1:c
                tmp2 = U(i,:).^b;
                tmp3 = sum(X.*repmat(tmp2,d,1),2)/sum(tmp2);
                M2(:,i) = tmp3;                     % ����ʸ������(��������)
            end

        end
    end
end



