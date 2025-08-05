clear;
clc;
% x = [1:9];
% y = [0.1:0.2:1.7];
% X = x+y*i
% plot(X);
% 
% % 当X和Y为矩阵时
% t = 0:0.01:2*pi;
% t = t.';
% x = [t,t,t];
% y = [sin(t),sin(2*t),sin(0.5*t)];
% plot(x,y);

% 绘制多条曲线
% x1 = linspace(0,2*pi,10);
% x2 = linspace(0,2*pi,20);
% x3 = linspace(0,2*pi,200);
% y1 = sin(x1);
% y2 = sin(x2)+2;
% y3 = sin(x3)+4;
% plot(x1,y1,':g',x2,y2,x3,y3);
% 
% % fplot函数
% fplot(@(x)sin(1./x),[0,0.2]);
% x = [0:0.005:0.2];
% y = sin(1./x);
% plot(x,y);

% fplot(@(t)t*sin(t),@(t)t*cos(t),[0,10*pi],'-r');
% 对数坐标
x = logspace(-1,2);
y = x;
semilogx(x,y);
% 极坐标
% theta = 0:0.01:2*pi;
% rho = sin(theta) .* cos(theta);
% polarplot(theta,rho);

% 条形图
x = [2021,2022,2023];
y = [10,20;20,30;100,200];
bar(x,y);

% 直方图
x = randn(1000,1);
nbins = 25;
h = histogram(x,nbins);
counts = h.Values;

x = 1:2:9
pie(x)

t = 0:pi/50:2*pi;
x = 16*sin(t).^3;
y = 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t);
scatter(x,y,'red',"filled")

A = [4,5];
quiver(0,0,A(1),A(2));

% 属性设置
x = linspace(0,2*pi,200);
y = [sin(x);sin(2*x);sin(0.5*x)];
plot(x,y);
axis([0,6.5,-1.5,1.5]);
title('三个正弦函数曲线y=sin{\theta}','FontSize',24);
xlabel('X');
ylabel('Y');
text(2.5,sin(2.5),'sin(x)');
text(2.5,sin(2*2.5),'sin(2x)');
legend('sin(x)','sin(2x)','sin(0.5x)');

% 图形保持
t = linspace(0,2*pi,200);
x = sin(t);
y = cos(t);
plot(x,y,'b');
axis equal
hold on
x1 = 2*sin(t);
y2 = 2*cos(t);
plot(x1,y2,'r');

%%
clear;
clc;
A = [4,5];
B = [-10,10];
C = A+B;
hold on
quiver(0,0,A(1),A(2));
quiver(0,0,B(1),B(2));
quiver(0,0,C(1),C(2));
title('A向量+B向量的结果');
xlabel('X');
ylabel('Y');
text(A(1),A(2),'A');
text(B(1),B(2),'B');
text(C(1),C(2),'C');
% grid on


% % 请关注微信公众号：【数模加油站】领取更多免费资料





