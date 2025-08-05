function [x,f,F] = SwarmIntelligence(Options,Algorithm)
% Ⱥ�������㷨�ӿ�
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

switch Algorithm
    case 'MSFLA'
        [x,f,F] = SI_MSFLA(Options);        % �Ľ���������㷨��MSFLA��
    case 'SFLA'
        [x,f,F] = SI_SFLA(Options);         % ��׼��������㷨��SFLA��
    case 'PPNGA'
        [x,f,F] = SI_PPNGA(Options);        % α����С�����Ŵ��㷨��PPNGA��
    case 'AF_SFLA'
        [x,f,F] = SI_AF_SFLA(Options);      % ��Ⱥ��AF����SFLA����㷨
    case 'ABC'
        [x,f,F] = SI_ABC(Options);          % ��Ⱥ�㷨��ABC��
    case 'PSO'
        [x,f,F] = SI_PSO(Options);          % ��׼����Ⱥ�㷨��PSO��
    case 'DEr1'
        [x,f,F] = SI_DEr1(Options);         % ��׼��ֽ����㷨(DE/rand/1/bin)
    case 'DEb2'
        [x,f,F] = SI_DEb2(Options);         % ��׼��ֽ����㷨(DE/best/2/bin)
    case 'FMINCON'
        [x,f] = SI_FMINCON(Options);        % FMINCON�Ż�
        F = [];
    case 'GA'
        [x,f] = SI_GA(Options);             % GA�Ż�
        F = [];        
end

end
