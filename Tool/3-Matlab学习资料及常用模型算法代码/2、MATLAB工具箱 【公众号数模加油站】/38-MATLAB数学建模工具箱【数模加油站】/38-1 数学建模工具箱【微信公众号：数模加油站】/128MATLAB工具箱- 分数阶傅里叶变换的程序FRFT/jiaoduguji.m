%%��ά���׹���������Ŀ�귽λ������(����ͼ��)

%�Ƕȱ仯 ˮƽ��λ�Ǵ�60�ȵ�120�� �����Ǵ�5�ȵ�65�� �����Ϊ15dB
%50��ͳ��ƽ��

clc
clear all
close all
%��������
fl=400;
fh=1000;
fs=4000;
ts=2.5;
point=ts*fs+1;

t=-1*ts/2:1/fs:ts/2;
S=sqrt(ts/fs);
dx=sqrt(ts*fs);
tt=-1*dx/2:1/dx:dx/2;%��һ��֮�������

n1=2*point-1;%????���Ծ������غ������
n2=1:n1;
thetao2=50:100;%ˮƽ��λ��
thetao1=5:55;%������


theta1=thetao1*pi/180;%������
theta2=thetao2*pi/180;%ˮƽ��λ��
snr=15;
%�˲���
b=fir1(256,[fl/(fs/2),fh/(fs/2)]);
numc=50;%50��ͳ��ƽ��
nums=length(thetao1);
for k=1:nums%kΪ��ɢ�Ƕ�ֵ
    for k1=1:numc%k1Ϊͳ��ƽ������
%���ź�
signal=chirp(t,700*S,ts/2,900);
noise=normrnd(0,1,1,point);
nx=normrnd(0,1,1,point);
ny=normrnd(0,1,1,point);
nz=normrnd(0,1,1,point);
%�������


b1=10^(snr/20);  
a1=std(signal);
a2=std(noise);
n=a2*b1/a1;
signal1=n*signal;
%���������ź�
p=signal1+noise;
%ͨ���˲���
p1=conv(b,p);
p2=p1(129:1:point+128);

vx=signal1*cos(theta2(k))*cos(theta1(k))+nx;
vx1=conv(b,vx);
vx2=vx1(129:1:point+128);

vy=signal1*sin(theta2(k))*cos(theta1(k))+ny;
vy1=conv(b,vy);
vy2=vy1(129:1:point+128);

vz=signal1*sin(theta1(k));
vz1=conv(b,vz);
vz2=vz1(129:1:point+128);


%����ͼ�㷨������100�㣬�ص�һ����Ȼ�����������199
zu=100;
k2=199;%������
add=50;%?????????????????����һ��
for k3=1:k2
    s1=1+add*(k3-1);
    s2=zu+add*(k3-1);  
    p3=p2(s1:s2);
    vx3=vx2(s1:s2);
    vy3=vy2(s1:s2);
    vz3=vz2(s1:s2);
    p4=fft(p3);
    vx4=fft(vx3);
    vy4=fft(vy3);
    vz4=fft(vz3);
    pvx=p4.*conj(vx4);
    pvy=p4.*conj(vy4);
    pvz=p4.*conj(vz4);
    pvx1(k3,:)=real(pvx);
    pvy1(k3,:)=real(pvy);
    pvz1(k3,:)=real(pvz);
end
pvx2=mean(pvx1);%����100�����ľ�ֵ
pvy2=mean(pvy1);
pvz2=mean(pvz1);

pvx3=mean(pvx2);%���д�һ��ľ�ֵ
pvy3=mean(pvy2);
pvz3=mean(pvz2);

thetaf1(k1,k)=atan(pvz3/(sqrt(pvx3^2+pvy3^2)));
thetas1(k1,k)=atan2(pvy3,pvx3);
%���ɽǶȣ�k1Ϊͳ��ƽ���Ĵ�����kΪ��ɢ�Ƕ�ֵ
thetaf2(k1,k)=thetaf1(k1,k)*180/pi;
thetas2(k1,k)=thetas1(k1,k)*180/pi;
%ͳ�����
errors1(k1,k)=thetas2(k1,k)-theta2(k)*180/pi;
errors2(k1,k)=errors1(k1,k)^2;

errorf1(k1,k)=thetaf2(k1,k)-theta1(k)*180/pi;
errorf2(k1,k)=errorf1(k1,k)^2;
end
errors3(k)=mean(errors2(:,k));
errorf3(k)=mean(errorf2(:,k));


end

errors4=sqrt(errors3);
errorf4=sqrt(errorf3);
thetaf=theta1*180/pi;
thetas=theta2*180/pi;


figure;
plot(thetas,errors4)


grid on
xlabel('Ŀ����ʵ�Ƕ�')
ylabel('��λ��׼�� ��λ����')
title('��ͬ�Ƕ��¹���Ŀ��ˮƽ��λ��������')
figure;
plot(thetaf,errorf4)


grid on
xlabel('Ŀ����ʵ�Ƕ�')
ylabel('��λ��׼�� ��λ����')
title('��ͬ�Ƕ��¹���Ŀ�긩����������')