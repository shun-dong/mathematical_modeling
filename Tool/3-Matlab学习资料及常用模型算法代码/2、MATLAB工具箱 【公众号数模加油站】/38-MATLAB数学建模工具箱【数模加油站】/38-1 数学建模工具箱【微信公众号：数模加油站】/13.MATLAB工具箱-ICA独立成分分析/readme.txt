1.������Ϊfastica,��������Ϊ��
function [Out1, Out2, Out3] = fastica(mixedsig, varargin)

- mixedsig: �۲����źţ�M*K�б�ʾ�� M·�۲��źţ�����K�������㡣
- varargin: �ɵ�������������Բ��ա�Matlab��FastICA�������ʹ��˵��.pdf��

- Out1: icasig,���Ϻ���źţ�ÿһ�б�ʾ���ƶ���������IC����
- Out2��A����������Ļ�Ͼ���
- Out3: W����������Ľ��Ͼ���


2.ʹ��������MixedS.matΪ�������ݣ���
eg1: [icasig, A, W] = fastica(MixedS)

eg2: [icasig] = fastica(MixedS)

eg3: [A, W] = fastica(MixedS)

eg4: % 'numOfIC'Ϊ������������Ĭ�Ϻ��������ź�������ͬ��'displayMode'���û�ͼģʽ��

     [icasig, A, W] = fastica(MixedS, 'numOfIC', 3, 'displayMode', 'signals')


3.����˵�����Բμ���Matlab��FastICA�������ʹ��˵��.pdf��


4.fasticag�ṩ���ӻ����������Ǹ���ʵ�������޷��������ݣ������޷�����ʹ�á�