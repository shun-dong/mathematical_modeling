%% 句柄/窗口控制
clear;
clc;
% x = 1:10;
% y = x.^2;
% h = plot(x,y);
% h1 = text(5,25,'说明');
% h1.FontSize = 24;

% x = linspace(0,2*pi,100);
% y = sin(x);
% h = plot(x,y);
% get(h)
% set(h,'Color','red')

% x = linspace(0,2*pi,100);
% subplot(2,2,1);
% plot(x,sin(x));
% title('sin(x)');
% 
% subplot(2,2,2);
% plot(x,cos(x));
% title('cos(x)');
% subplot(2,2,3);
% plot(x,tan(x));
% title('tan(x)');
% 
% subplot(2,2,4);
% plot(x,cot(x));
% title('cot(x)');


x = -1:0.2:2;
[X,Y] = meshgrid(x);
Z = X.*exp(-X.^2-Y.^2);
subplot(1,3,1);
plot3(X,Y,Z);
subplot(1,3,2);

mesh(X,Y,Z);
subplot(1,3,3);

surf(X,Y,Z);


% % 请关注微信公众号：【数模加油站】领取更多免费资料
