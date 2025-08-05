%Ŀ���ź�Ϊchirp signal f0=7000,B=1750,T=0.5845,fs=4*f0;
%�˲����������Ĺ��ʸĳ�dbHz
clc
clear all
close all
%��������

f0=7000;
B=1750;
fs=4*f0;

ts=0.5845;
t=-1*ts/2:1/fs:ts/2;
alfa=pi/4;
alfa11=45;
point=ts*fs+1;


t=-1*ts/2:1/fs:ts/2;
S=sqrt(ts/fs);
dx=sqrt(ts*fs);
tt=-1*dx/2:1/dx:dx/2;%��һ��֮�������
alfa=pi/4;
point=ts*fs+1;
 a=atan(-1/(S*S*B/ts))*2/pi+4;
snr=-15:0;
%�˲���
b=fir1(256,[(f0-B/2)/(fs/2),(f0+B/2)/(fs/2)]);
for k1=1:length(snr)
    for k=1:100
        signal=exp(i*2*pi*(f0-B/2)*tt*S+i*pi*(B/ts)*tt.*tt*S*S);
        noise=normrnd(0,1,1,point);
        nx=normrnd(0,1,1,point);
        ny=normrnd(0,1,1,point);
        %  �����db/Hz
         b1=10^(snr(k1)/10);  
         a1=std(signal);
         a2=std(noise);
  %      n=sqrt(2*b1*B*(std(noise)^2)/point);
         n=sqrt(b1*a2/a1);
%         b1=10^(snr(k1)/10);  
%         a1=std(signal);
%         a2=std(noise)*B/fs;
%         n=sqrt(2*b1*B*(std(noise)^2)/point);
        signal1=n*signal;
        p=signal1+noise;
        
   
     snrpiji(k1)=10*log10((std(signal1)^2*point/B)/(std(noise)^2));
        
        %ͨ���˲���
        p1=conv(b,p); 
        p2=p1(129:1:point+128); 

        vx=signal1*cos(alfa)+nx;
        vx1=conv(b,vx);
        vx2=vx1(129:1:point+128);
 
        vy=signal1*sin(alfa)+ny;
        vy1=conv(b,vy);
        vy2=vy1(129:1:point+128);
%����ͼ�㷨������512�㣬�ص���64����Ȼ�����������124
        zu=512;
        k2=61;%������
        add=256;%?????????????????����512-64
        for k3=1:k2
            s1=1+add*(k3-1);
            s2=zu+add*(k3-1);  
            p3=p2(s1:s2);
            vx3=vx2(s1:s2);
            vy3=vy2(s1:s2);
          
            p4=frft(p3,a);
            vx4=frft(vx3,a);
            vy4=frft(vy3,a);

            pvx=p4.*conj(vx4);
            pvy=p4.*conj(vy4);
             
            pvx1(k3,:)=real(pvx);
            pvy1(k3,:)=real(pvy);        
        end
        pvx2=mean(pvx1);
        pvy2=mean(pvy1);
        
        pvx3=mean(pvx2);
        pvy3=mean(pvy2);
        alfa1(k)=atan(pvy3/pvx3)*180/pi;%k1Ϊ����ȣ�kΪͳ�ƴ���
       

    end
    alfa2(k1)=mean(alfa1);
     error1=(alfa1-45);
    error2(k1)=sqrt(mean(error1.^2));
end

plot(snr,error2,'*');
dy=(1/(6*B*ts))*(1./(10.^(snr/10)));%ˮƽ�Ƕȵ�CRBΪ1/��3*M*sina^2*snr��
hold on ;
plot(snr,sqrt(dy)*180/pi);
xlabel('�����')
ylabel('��λ��׼�� ��λ����')
title('FRFT��ͬ������¹���Ŀ��ˮƽ��λ��������')