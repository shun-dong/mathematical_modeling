%% 逻辑基础
A = randi([-3,3],2,4);
B = randi([-3,3],1,4);
A & B;
A | B;
~A;
xor(A,B);
% C = randi([-3,3],1,4)
% D = A & B
% D & C
% A & B & C
% (3>4)&(2>-1)
% A = randi([0,100],1,20)
% res = (60<=A) & (A<80)
% res2 = ~res
% res3 = (A<60) | (A>=80)
clear;
clc;
% B = randi([0,100],2,5)
% B(6) = 0;
% B
% any(B,1)
% any(B,2)

score = randi([50,100],5,3)
% any(score < 60,2);
% all(score >= 60,1)
find(sum(score < 60,2)==1);
find(sum(score,2) > 260)

% A = randi([0,2],2,3)
% 
% ind = find(A,2,'last')
% [row,col] = find(A)
% [row,col,v] = find(A)



% % 请关注微信公众号：【数模加油站】领取更多免费资料

