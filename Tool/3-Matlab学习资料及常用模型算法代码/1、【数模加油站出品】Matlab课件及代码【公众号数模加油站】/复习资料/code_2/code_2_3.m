clear;
clc;
% X = 1:20;
% [max,min] = max_min_values(X);
% max
% min
% f = @(x,y)x.^2+y.^2;
% % f(2,3)
% x = 1:5;
% y = 0.1:0.1:0.5;
% f(x,y)
% f1 = @(a,b)@(x) a*x+b;
% f1(2,3)

f = @(a) @(x)exp(x)+x^a+x^(sqrt(x))-100;
fzero(f(1),4)
A = 0:0.1:2;
x = @(a)fzero(f(a),4);  % x(a)
X = @(A) arrayfun(@(a) x(a),A);  % X(A)
Y = X(A)


% % 请关注微信公众号：【数模加油站】领取更多免费资料

