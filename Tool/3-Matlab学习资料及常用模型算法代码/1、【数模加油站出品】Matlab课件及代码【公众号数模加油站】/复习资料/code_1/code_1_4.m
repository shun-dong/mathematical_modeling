%% 矩阵基础
clear;
clc;
%% 直接输入法
a = [1,2 3;4 5 6];

%% 函数创建法
b = zeros(100);
c = zeros(100,99);
% rand(n),rand(m,n)
d = rand(5,6);

% randi([imin,imax],m,n),randi([imin,imax],n)
e = randi([1,6],20);

% randn(n),% randn(m,n)
f = randn(5,6);

%% 矩阵元素的修改和删除
A = [1 2 3 4;2:5;3:6];
A(2,:) = 10;
A([1,3],[1,2]) = 0;
A(4) = 0;  % 线性索引
A(5,6) = 888;
A(:,[1,end]) = [];
A(1) = [];

%% 矩阵拼接重构重排
A = [1 2 3 4;2:5;3:6];
B = ones(3,2);

C = [A B];
C2 = cat(2,A,B);

B2 = ones(2,4);
B3 = ones(3,4);
D = [A;B2;B3];
D2 = cat(1,A,B2);

A = randi(10,2,6)
% B = reshape(A,3,[])
% A(:)
% B(:)

% sort(A,1);  % 按照列进行升序排序
sort(A,2,'descend') % 按照行进行降序排序
sortrows(A,2,'descend')

%% 矩阵运算
clear;
clc;
% % 函数运算
% A = randi(10,3,4)
% sum(A,1)  % 计算每一列的和
% sum(A,2)
% sum(A(:))
% sum(A,"all")
% prod(A(:))
% prod(A,"all")

% 算术运算
A = randi(10,3,3)
B = randi(10,1,4);

% A ^ 3
% A * A * A
A2 = [1 2 3+i;2-i,2,3]
A2'
A2.'

% 关系运算
A = [1:4]
B = ones(3,4)
A == B
%% 课后小练
clear;
clc;
score = [95 80 85 79;95 67 78 90;95 67 78 75; 95 67 64 73;86 85 82 84;86 87 84 88]
score_1 = sortrows(score,2);
score_2 = sortrows(score,[1,3]);
score_2 = sortrows(score,[1,3],'descend')


% % 请关注微信公众号：【数模加油站】领取更多免费资料





