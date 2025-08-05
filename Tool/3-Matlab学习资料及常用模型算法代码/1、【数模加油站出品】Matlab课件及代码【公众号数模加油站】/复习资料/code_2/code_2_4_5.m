clear;
clc;
x = -6 + 8i;
abs(x);

mod(9,3);

sqrt(1:9);
format long g
% format short
sqrt(1:9);
sqrt(-4);

exp(1:9);
log(exp(2));
log10(1000);

round(3541.59,-3);
sin(2*pi);

A = [1:9];
x = 5;
A == x;
~isempty(find(A == x));

x = 0:4;
y = 0:3;
[xx,yy] = meshgrid(x,x);
xx;
yy;
% z = xx.^2+yy.^2 % f(x,y) = x^2+y^2

seed = 3;
rng(seed);
randi(10,3,3)
%%
A = [1:9];
x = 5:10;
ismember(x,A)


% % 请关注微信公众号：【数模加油站】领取更多免费资料

