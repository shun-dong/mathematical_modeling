%% 三维图像绘制
clear;
clc;
t = [0:0.1:10*pi];
% x = sin(t) + t.*cos(t);
% y = cos(t) - t.*sin(t);
% z = t;
% plot3(x,y,z);
% 
% y = t;
% plot3(t,y,sin(t));

% t = t.';
% x = [t,t,t];
% y = [sin(t),sin(t)+2,sin(t)+4];
% z = t;
% plot3(x,y,z);

x = t;
% y = [sin(t);sin(t)+2;sin(t)+4];
z = t;
% plot3(x,y,z);

% plot3(x,sin(t),z,x,sin(t)+2,z,x,sin(t)+4,z);
% 
% x = @(t) exp(-t/10).*sin(5*t);
% y = @(t) exp(-t/10).*cos(5*t);
% z = @(t) t;
% fplot3(x,y,z,[-12,12],'-r');

% x = [2:6];
% y = [3:8]';
% % X = ones(size(y))*x;
% % Y = y*ones(size(x));
% [X,Y] = meshgrid(x,y);
% X;
% Y;

x = -1:0.2:2;
[X,Y] = meshgrid(x);
Z = X.*exp(-X.^2-Y.^2);
plot3(X,Y,Z);
mesh(X,Y,Z);
surf(X,Y,Z);

x = [2:6];
y = [3:8]';
% X = ones(size(y))*x;
% Y = y*ones(size(x));
[X,Y] = meshgrid(x,y);
Z = randn(size(X));
plot3(X,Y,Z);


% % 请关注微信公众号：【数模加油站】领取更多免费资料




