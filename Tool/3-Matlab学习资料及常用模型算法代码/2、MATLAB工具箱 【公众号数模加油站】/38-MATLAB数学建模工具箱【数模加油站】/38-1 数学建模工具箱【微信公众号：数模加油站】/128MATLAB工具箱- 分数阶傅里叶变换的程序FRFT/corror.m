%Notch CW LFM instantaneous frequancy;
% ÿ1�뷢һ������
clc;
close all;
clear all;
T=30/1000;%����ʱ��30ms
ts=1.6;%����ʱ��1s��
f0=15000;
fs=160000;
B=5000;
t=0:1/fs:T-1/fs;
tt=0:1/fs:ts-1/fs;
k=B/T;

%signal s1=CW;s2=LFM;

s1=exp(i*2*pi*f0*t+i*pi*k*t.*t);
% s1=cos(2*pi*f0*t+pi*k*t.*t);
       % modulate ��������LFM
s_chirp=[zeros(1,200*fs/1000),s1,zeros(1,1370*fs/1000)];



SNR=5;
N1=length(s1);
N=length(s_chirp);
%signal+noise;
snr_lin=10^(SNR/10);
noise_std=sqrt(std(s_chirp)/snr_lin);
noise=noise_std*randn(1,length(s_chirp));
sn1=s_chirp+noise;


fs1=fft(sn1);
f=0:fs/N:fs/2-fs/N;
% % % % % % % % % % % % % % % % % % ��FFT
PP=fs1.*conj(fs1)/N;
figure(1),plot(f,abs(fs1(1:N/2)));xlabel('Frequency'),ylabel('Ƶ��ǿ��');
figure(2),plot(tt,sn1);xlabel('ʱ��'),ylabel('ԭʼ�źŷ���');

v=xcorr(sn1,s1)/N1;
sv=v(N:2*N-1);
figure(3);plot(tt,10*log10(abs(sv)));xlabel('ʱ��'),ylabel('��һ������');
[C,I]=find(sv==max(sv));
I/fs