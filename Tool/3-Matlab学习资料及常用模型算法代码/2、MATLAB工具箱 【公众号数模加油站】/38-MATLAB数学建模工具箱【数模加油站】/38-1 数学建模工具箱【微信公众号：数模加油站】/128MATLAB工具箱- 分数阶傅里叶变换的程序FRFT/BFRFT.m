%FRFT
%50��ͳ��ƽ��

clc
clear all
close all
%��������
f0=2000;
B=500:200:2500;
fs=4*f0;

ts=0.5;
t=-1*ts/2:1/fs:ts/2;
alfa=pi/6;
alfa11=30;


t=-1*ts/2:1/fs:ts/2;
S=sqrt(ts/fs);
dx=sqrt(ts*fs);
tt=-1*dx/2:1/dx:dx/2;%��һ��֮�������
point=ts*fs+1;


snr=5;

%�˲���
% b=fir1(256,[(f0-B/2)/(fs/2),(f0+B/2)/(fs/2)]);
for k=1:length(B)%kΪsnr;
    k
    for k1=1:50%k1Ϊͳ��ƽ������
%���ź�
        signal=exp(i*2*pi*(f0)*tt*S+i*pi*(B(k)/ts)*tt.*tt*S*S);
        noise=normrnd(0,1,1,point);
        nx=normrnd(0,1,1,point);
        ny=normrnd(0,1,1,point);

        %�������
        %�����db/Hz
        b1=10^(snr/10);  
        a1=std(signal);
        a2=std(noise);
        n=sqrt(b1*a2*B(k)/a1/fs);

        signal1=n*signal;
        p=signal1+noise;

        %ͨ���˲���
%         p1=conv(b,p); 
%         p2=p1(129:1:point+128); 

        vx=signal1*cos(alfa)+nx;
%         vx1=conv(b,vx);
%         vx2=vx1(129:1:point+128);

        vy=signal1*sin(alfa)+ny;
%         vy1=conv(b,vy);
%         vy2=vy1(129:1:point+128);
%ʱ��
%         sypvy=mean(real(p.*conj(vy)));
%         sypvx=mean(real(p.*conj(vx)));
%         syalfa1(k1)=atan(sypvy/sypvx)*180/pi;
%Ƶ��
        p3=fft(p);
        vx3=fft(vx);
        vy3=fft(vy);
        
        pvy=real(p3.*conj(vy3));
        pvx=real(p3.*conj(vx3));
        pvx1=mean(pvx(f0/2-B(k)/4:f0/2+B(k)/4));
        pvy1=mean(pvy(f0/2-B(k)/4:f0/2+B(k)/4));
        alfa1(k1)=atan(pvy1/pvx1)*180/pi;
  
 %��������    
        a=atan(-1/(S*S*B(k)/ts))*2/pi+4;
        frp3=frft(p,a);
        frvx3=frft(vx,a);
        frvy3=frft(vy,a);
        frpvy=real(frp3.*conj(frvy3));
        frpvx=real(frp3.*conj(frvx3));
        [Cx,Ix]=max(frpvx);
        [Cy,Iy]=max(frpvy);
        frpvy1=mean(frpvy(Iy-15:Iy+15));
        frpvx1=mean(frpvx(Ix-15:Ix+15));
        fralfa1(k1)=atan(frpvy1/frpvx1)*180/pi; 

        
 
        
    end
%     Ƶ��
    alfa2(k)=mean(alfa1);
    error1=(alfa1-alfa2(k));
    error2(k)=sqrt(mean(error1.^2));
%     ʱ��;
%     syalfa2(k)=mean(syalfa1);
%     syerror1=syalfa1-alfa11;
%     syerror2(k)=sqrt(mean(syerror1.^2));
%    ��������
    fralfa2(k)=mean(fralfa1);
    frerror1=fralfa1-alfa11;
    frerror2(k)=sqrt(mean(frerror1.^2));
end


figure,
plot(B,error2,'-*');
hold on 
% plot(snr,syerror2,'-d');
% hold on
plot(B,frerror2,'-o');

xlabel('���������/��dB��')
ylabel('��λ���Ʊ�׼ƫ��/���㣩')

figure,
plot(B,alfa2,'-*')%Ƶ��
hold on 
% plot(snr,syalfa2,'-d');%ʱ��
% hold on 
plot(B,fralfa2,'-o');%��������
xlabel('���������/��dB��')
ylabel('���Ʒ�λ/���㣩')
