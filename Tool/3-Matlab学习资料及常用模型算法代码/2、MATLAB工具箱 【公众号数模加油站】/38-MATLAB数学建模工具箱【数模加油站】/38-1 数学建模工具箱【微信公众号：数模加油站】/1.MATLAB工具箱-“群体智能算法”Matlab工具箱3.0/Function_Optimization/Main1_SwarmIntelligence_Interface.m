
% ��Ⱥ�������㷨��Matlab������ Version3.0
% "Swarm Intelligence Alogrihtm" Matlab Toolbox - trial version 2.0
%
% �������Ҫʹ��˵����
% 1�������˰���Ⱥ�������㷨��'PPNGA','SFLA','MSFLA','AF-SFLA','PSO','ABC','DEr1','DEb2'
% 2����Ӧ�Ⱥ���������һ������Parmaters�����ձ��ļ�Options.Parmaters���ݵĲ�����ʵ���μ�m�ļ�F3_Rastrigin.m
% 3��������������������ֹ��������ֹ����3�Ǳ���ģ���ֹ����1,2�ǿ�ѡ�ģ�����Ҫʱ��ȥ���뼴��
% 4�����Ż����������У�С��Ⱥ���������Ⱥ���ø������ƣ�ʵ�ʹ������ⲻһ����һ�����ø��ã�Ҫ����ʵ������ȷ��
% 5�����㷨���������У�ȱʡ����һ�㲻��Ҫ�Ķ���������ԭ���϶ԸĶ�������Ľ���䶯���Ÿ���������
%
% �ӿ��ļ�
% Main_SwarmIntelligence_Interface.m
%
% ��Ӧ�Ⱥ����ļ�
% F0_Yours.m
% F1_Sphere.m
% F2_Rosenbrock.m
% F3_Rastrigin.m
% F4_Griewank.m
% F5_Schaffer.m
% 
% �ر���ʾ: �����������ַ���������Ч�˷������ʼ�������ľֲ���С����
% 1�����ɴ�����ȡ����
% 2�����ӽ�������maxgen
% 3���Ӵ���Ⱥ��ģpopsize
%
% ʹ��ƽ̨ - WinXP SP2�����ϰ汾��Win7��û�е��ԣ���Matlab7.0 -> Matlab2011b
% ���ߣ�½�񲨣��������̴�ѧ
% ��ӭͬ�����Ž���������������������������������ҵĸ�����ҳ
% �����ʼ���luzhenbo@yahoo.com.cn
% ������ҳ��http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

%--------------------------------------
% �Ż��������壨������ϸ˵���μ�m�ļ���Options.fitness��

Options.dim = 3;                            % �Ż�������ά��
Options.fitness = 'F0_Yours';               % �Ż�����
Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
Options.Lb = -5.12;                         % �����½磨��ά�ɷֱ����ã�
Options.Ub = 5.12;                          % �����Ͻ磨��ά�ɷֱ����ã�

% Options.dim = 30;                           % �Ż�������ά��
% Options.fitness = 'F1_Sphere';              % �Ż�����
% Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
% Options.Lb = -100;                          % �����½磨��ά�ɷֱ����ã�
% Options.Ub = 100 ;                          % �����Ͻ磨��ά�ɷֱ����ã�

% Options.dim = 30;                           % �Ż�������ά��
% Options.fitness = 'F2_Rosenbrock';          % �Ż�����
% Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
% Options.Lb = -30;                           % �����½磨��ά�ɷֱ����ã�
% Options.Ub = 30;                            % �����Ͻ磨��ά�ɷֱ����ã�

% Options.dim = 30;                           % �Ż�������ά��
% Options.fitness = 'F3_Rastrigin';           % �Ż�����
% Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
% Options.Lb = -100;                          % �����½磨��ά�ɷֱ����ã�
% Options.Ub = 100;                           % �����Ͻ磨��ά�ɷֱ����ã�
% Options.Parmaters = 10;                     % �Ż�����Options.fitness����    

% Options.dim = 30;                           % �Ż�������ά��
% Options.fitness = 'F4_Griewank';            % �Ż�����
% Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
% Options.Lb = -600;                          % �����½磨��ά�ɷֱ����ã�
% Options.Ub = 600;                           % �����Ͻ磨��ά�ɷֱ����ã�

% Options.dim = 30;                           % �Ż�������ά��
% Options.fitness = 'F5_Schaffer';            % �Ż�����
% Options.maxmin = -1;                        % ��ֵ���ͣ�1���ֵ��-1��Сֵ��
% Options.Lb = -100;                          % �����½磨��ά�ɷֱ����ã�
% Options.Ub = 100;                           % �����Ͻ磨��ά�ɷֱ����ã�

%--------------------------------------------------------------------------
% �Ż���������

% ����Ⱥ����
Options.show = 50;                          % ��ʾ���
Options.popsize = 200;                      % ��Ⱥ��ģ
Options.maxgen = 500;                       % ��ֹ����3������������������������ֹ��
Options.localmin = 50;                      % ��ֹ����1���������localmin�β����£�������ֹ����ȥ��Ч��
Options.tolfun = 1e-16;                     % ��ֹ����2���������tolfun��������ֹ����ȥ��Ч��

% С��Ⱥ���ã������Ⱥ���ø������ƣ�
% Options.show = 500;                         % ��ʾ���
% Options.popsize = 20;                       % ��Ⱥ��ģ
% Options.maxgen = 5000;                      % ��ֹ����3������������������������ֹ��
% Options.localmin = 500;                     % ��ֹ����1���������localmin�β����£�������ֹ����ȥ��Ч��
% Options.tolfun = 1e-16;                     % ��ֹ����2���������tolfun��������ֹ����ȥ��Ч��

%--------------------------------------------------------------------------
% �㷨�������ã�����Ϊȱʡ���ã�һ�㲻��Ҫ�Ķ���������ԭ���϶ԸĶ�������Ľ���䶯���Ÿ��������⣩

Options.seed = sum(100*clock);              % ��ʼ��������ӣ�ʹ�ô�����㷨��ʼ��Ⱥ����ͬ��
% Options.quick = 5;                          % ���Ž���ٴ�����Ϊ0ʱ,�Ŷ�������Ч��
% Options.ismu = 0;                           % �Ƿ�����������������ʱ��Ч��Ϊ0ʱ,����������Ч��PPNGA��MSFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
% Options.ispop = 0;                          % �Ƿ��Ⱥ�Ż�����������ʱ��Ч��Ϊ0ʱ,��������Ⱥ��PPNGA��MSFLA��SFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
% Options.Pc = [0.6,0.99];                    % ����Ӧ������ʣ��������ӣ�
% Options.Pm = [0.01,0.1];                    % ����Ӧ������ʣ��������ӣ�
% Options.c1 = 2;                             % ����ϵ��1������Ⱥ�㷨��PSO��
% Options.c2 = 2;                             % ����ϵ��2������Ⱥ�㷨��PSO��
% Options.w1 = 0.9;                           % ����Ȩϵ��1������Ⱥ�㷨��PSO��
% Options.w2 = 0.4;                           % ����Ȩϵ��2������Ⱥ�㷨��PSO��
% Options.limit = 50;                         % ������Ʋ�������Ⱥ�㷨��ABC��
% Options.F = [0,1];                          % �������ӣ���ֽ����㷨,DEr1��DEb2��
% Options.CR = [0.8,1];                       % ������ʣ���ֽ����㷨,DEr1��DEb2��

%--------------------------------------------------------------------------
% ��������


[x1,f1,F1] = SwarmIntelligence(Options,'PPNGA');    % α����С�����Ŵ��㷨��PPNGA��
[x2,f2,F2] = SwarmIntelligence(Options,'SFLA');     % ��׼��������㷨��SFLA��
[x3,f3,F3] = SwarmIntelligence(Options,'MSFLA');    % �Ľ���������㷨��MSFLA��
[x4,f4,F4] = SwarmIntelligence(Options,'AF_SFLA');  % ��Ⱥ��AF����SFLA����㷨
[x5,f5,F5] = SwarmIntelligence(Options,'PSO');      % ��׼����Ⱥ�㷨��PSO��
[x6,f6,F6] = SwarmIntelligence(Options,'ABC');      % ��Ⱥ�㷨��ABC��
[x7,f7,F7] = SwarmIntelligence(Options,'DEr1');     % ��׼����㷨(DE/rand/1/bin)
[x8,f8,F8] = SwarmIntelligence(Options,'DEb2');     % ��׼����㷨(DE/best/2/bin)

% [x9,f9] = SwarmIntelligence(Options,'FMINCON');     % FMINCON�Ż�
% [x10,f10] = SwarmIntelligence(Options,'GA');        % GA�Ż�

%--------------------------------------------------------------------------
% ��������

% Algorithm = 'PPNGA';
% Algorithm = 'SFLA';
% Algorithm = 'MSFLA';
% Algorithm = 'AF_SFLA';
% Algorithm = 'PSO';
% Algorithm = 'ABC';
% Algorithm = 'DEr1';
% Algorithm = 'DEb2';
% [x1,f1,F1] = SwarmIntelligence(Options,Algorithm);    
% 
% Options2 = Options;
% Options2.ismu = 1;
% [x2,f2,F2] = SwarmIntelligence(Options2,Algorithm);   
% 
% Options3 = Options;
% Options3.ispop = 1;
% [x3,f3,F3] = SwarmIntelligence(Options3,Algorithm);  
% 
% Options4 = Options;
% Options4.ismu = 1;
% Options4.ispop = 1;
% [x4,f4,F4] = SwarmIntelligence(Options4,Algorithm);  

% �������:
% Options - �Ż���������
%     Options.dim - �Ż�������ά��
%     Options.fitness - �Ż�����
%     Options.Parmaters - �Ż�����Options.fitness����
%     Options.maxmin - ��ֵ���ͣ�1���ֵ��-1��Сֵ
%     Options.Lb - �����½�
%     Options.Ub -  �����Ͻ�
%
%     Options.show - ��ʾ���
%     Options.popsize - ��Ⱥ��ģ
%     Options.maxgen - ��ֹ����3������������������������ֹ��
%     Options.localmin - ��ֹ����1���������localmin�β����£�������ֹ����ȥ��Ч��
%     Options.tolfun - ��ֹ����2���������tolfun��������ֹ����ȥ��Ч��
%
%     Options.seed - ��ʼ��������ӣ�ȱʡֵsum(100*clock)��ʹ�ô�����㷨��ʼ��Ⱥ����ͬ��
%     Options.quick - ���Ž���ٴ�����ȱʡֵ5��Ϊ0ʱ,�Ŷ�������Ч��;
%     Options.ismu - �Ƿ���������ȱʡֵ0����������ʱ��Ч��Ϊ0ʱ,����������Ч��PPNGA��MSFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
%     Options.ispop - �Ƿ��Ⱥ�Ż���ȱʡֵ0����������ʱ��Ч��Ϊ0ʱ,��������Ⱥ��PPNGA��MSFLA��SFLA�㷨������Ϊ1�����ܴ�����Ӱ�죩
%     Options.Pc - ����Ӧ������ʣ��������ӣ�,ȱʡֵ[0.6,0.99];
%     Options.Pm - ����Ӧ������ʣ��������ӣ�,ȱʡֵ[0.01,0.1];
%     Options.c1 - ����ϵ��1������Ⱥ�㷨,PSO��,ȱʡֵ2;
%     Options.c2 - ����ϵ��2������Ⱥ�㷨,PSO��,ȱʡֵ2;
%     Options.w1 - ����Ȩϵ��1������Ⱥ�㷨,PSO��,ȱʡֵ0.9;
%     Options.w2 - ����Ȩϵ��2������Ⱥ�㷨,PSO��,ȱʡֵ0.4;
%     Options.limit - ������Ʋ�������Ⱥ�㷨,ABC��,ȱʡֵ50;
%     Options.F - �������ӣ���ֽ����㷨,DEr1��DEb2��,ȱʡֵ[0,1];
%     Options.CR - ������ʣ���ֽ����㷨,DEr1��DEb2��,ȱʡֵ[0.8,1];
%
% Algorithm - �㷨
%     'MSFLA' - �Ľ���������㷨��MSFLA��
%     'SFLA' - ��׼��������㷨��SFLA��
%     'PPNGA' - α����С�����Ŵ��㷨��PPNGA��
%     'AF_SFLA' - ��Ⱥ��AF����SFLA����㷨
%     'ABC' - ��Ⱥ�㷨��ABC��
%     'PSO' - ��׼����Ⱥ�㷨��PSO��
%     'DEr1' - ��׼��ֽ����㷨(DE/rand/1/bin)
%     'DEb2' - ��׼��ֽ����㷨(DE/best/2/bin)
%     'FMINCON' - FMINCON�Ż�
%     'GA' - GA�Ż�
%
% �������:
% x - ���Ž�
% f - ������Ӧ��
% F - ����������Ӧ��

%--------------------------------------------------------------------------
% �����ͼ

figure; xlabel('gen'); ylabel('log10(F)'); title(Options.fitness(4:end)); hold on
plot(log10(F1),'b.-');
plot(log10(F2),'m.-');
plot(log10(F3),'k.-');
plot(log10(F4),'c.-');
plot(log10(F5),'g.-');
plot(log10(F6),'.-','color',[0.4 0.4 0.4]);
plot(log10(F7),'y.-');
plot(log10(F8),'r.-');
legend('PPNGA','SFLA','MSFLA','AF-SFLA','PSO','ABC','DEr1','DEb2'); 
hold off;

% figure; xlabel('gen'); ylabel('log10(F)'); title(Options.fitness(4:end)); hold on
% plot(log10(F1),'b.-');
% plot(log10(F2),'k.-');
% plot(log10(F3),'g.-');
% plot(log10(F4),'r.-');
% legend('none','ismu=1','ispop=1','ismu=1 & ispop=1'); 
% hold off;

