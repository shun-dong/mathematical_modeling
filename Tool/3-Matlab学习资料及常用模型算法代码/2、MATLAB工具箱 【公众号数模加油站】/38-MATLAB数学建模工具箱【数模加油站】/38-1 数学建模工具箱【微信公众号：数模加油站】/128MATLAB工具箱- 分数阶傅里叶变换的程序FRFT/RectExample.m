%rectagle example
clear all;
clc;
a=0.5;
fs=2000;
t=-2:0.1:2;
N=length(t);
x=zeros(1,N);

%���ٹ�һ����T=4��fs=10����Ҫ��t����,ʹ��ﵽT=10�����Ǵӣ�-5:5��


%������ɢ�߶Ȼ���x=sqrt��T*fs����T=4��fs=10��N=40,dx=sqrt(40);
dx=sqrt(40);
S=sqrt(0.4);
tt=-2/S:1/dx:2/S;
NN=length(tt);
f=[zeros(find(t==-0.5),1);ones((find(t==0.5)-find(t==-0.5)),1);zeros(NN-find(t==0.5),1)];


% t=-0.1:1/fs:0.1;
% N=length(t);
% x=chirp(t,1000,0.1,1300);
% t1=-1000:1/fs:-0.1;
% t2=-1000:1/fs:1000;
% 
% f=[zeros(length(t1)-1,1);x';zeros(length(t2)-length(t1)-N,1)];
 x=f';

subplot(311);plot(tt,x);
frt=frft(x,a);

subplot(312);plot(tt,abs(frt)*S);
%Disfrt=Disfrft(x,a);
subplot(313);plot(angle(frt));