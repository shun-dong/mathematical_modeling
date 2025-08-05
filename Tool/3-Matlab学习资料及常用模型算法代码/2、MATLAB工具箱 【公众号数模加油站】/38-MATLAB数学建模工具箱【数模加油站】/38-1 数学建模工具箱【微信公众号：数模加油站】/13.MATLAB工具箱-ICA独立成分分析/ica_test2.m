% ������Ϊ����ʹ��
% �����Դ�źŷ�������
% Դ�ź�S
clc,close all, clear all;
S = demosig;
[M,K] = size(S);
for(i=1:M)
    subplot(M,1,i);
    plot(S(i,:)), title(['ԭʼ�ź�',int2str(i)]);
end

% ����ź��е�ÿһ�ж���Դ�źŵ�һ��������ϣ�ϵ�����
Sweight=rand(size(S,1)); 
MixedS=Sweight*S;     % ����Ͼ����������в����
figure,
for(i=1:M)
    subplot(M,1,i);
    plot(MixedS(i,:)), title(['����ź�',int2str(i)]);
end


MixedS_bak=MixedS;                  
%%%%%%%%%%%%%%%%%%%%%%%%%%  ��׼��  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MixedS_mean=zeros(3,1);
for i=1:3
    MixedS_mean(i)=mean(MixedS(i,:));
end                                        % ����MixedS�ľ�ֵ

for i=1:3
    for j=1:size(MixedS,2)
        MixedS(i,j)=MixedS(i,j)-MixedS_mean(i);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%  �׻�  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MixedS_cov=cov(MixedS');                    % covΪ��Э����ĺ���
[E,D]=eig(MixedS_cov);                      % ���źž����Э�������������ֵ�ֽ�
Q=inv(sqrt(D))*(E)';                        % QΪ�׻�����
MixedS_white=Q*MixedS;                      % MixedS_whiteΪ�׻�����źž���
IsI=cov(MixedS_white');                     % IsIӦΪ��λ��            

%%%%%%%%%%%%%%%%%%%%%%%%��FASTICA�㷨  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=MixedS_white;                            % �����㷨����X���в���
[VariableNum,SampleNum]=size(X);
numofIC=VariableNum;                       % �ڴ�Ӧ���У�����Ԫ�������ڱ�������
B=zeros(numofIC,VariableNum);              % ��ʼ��������w�ļĴ����,B=[b1  b2  ...   bd]
for r=1:numofIC
    i=1;maxIterationsNum=100;               % ����������������������ÿ�������������Ե������������˴�����
    IterationsNum=0;
    b=rand(numofIC,1)-.5;                  % �������b��ֵ
    b=b/norm(b);                           % ��b��׼�� norm(b):����Ԫ��ƽ���Ϳ�����
    while i<=maxIterationsNum+1
        if i == maxIterationsNum           % ѭ����������
            fprintf('\n��%d������%d�ε����ڲ���������', r,maxIterationsNum);
            break;
        end
        bOld=b;                          
        a2=1;
        u=1;
        t=X'*b;
        g=t.*exp(-a2*t.^2/2);
        dg=(1-a2*t.^2).*exp(-a2*t.^2/2);
        b=((1-u)*t'*g*b+u*X*g)/SampleNum-mean(dg)*b;
                                           % ���Ĺ�ʽ���μ����۲��ֹ�ʽ2.52
        b=b-B*B'*b;                        % ��b������
        b=b/norm(b); 
        if abs(abs(b'*bOld)-1)<1e-9        % �����������
             B(:,r)=b;                     % ������������b
             break;
         end
        i=i+1;        
    end
%    B(:,r)=b;                                % ������������b
end

%%%%%%%%%%%%%%%%%%%%%%%%%%  ICA��������ݸ�ԭ����ͼ  %%%%%%%%%%%%%%%%%%%%%%%%%
ICAedS=B'*Q*MixedS_bak;                     % ����ICA��ľ���
figure,
for(i=1:M)
    subplot(M,1,i);
    plot(ICAedS(i,:)), title(['�����ź�',int2str(i)]);
end
