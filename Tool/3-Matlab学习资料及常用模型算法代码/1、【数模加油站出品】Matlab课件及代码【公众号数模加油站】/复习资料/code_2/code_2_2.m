%% 结构基础
clear;
clc;
% score = 97;
% if (score >=90) && (score <= 100)
%     res = 1;
% elseif (score >=80) && (score < 90)
%     res = 2;
% elseif (score >=60 && (score < 80))
%     res = 3;
% elseif (score >=0 && (score < 60))
%     res = 4;
% else
%     res = 0;
% end
% res;
% A = [1,2;1,3];
% if any(A(:))
%     res = 0;
% else
%     res = 10;
% end
%
% a = 10;
% b = 20;
% c = 15;
% if a > b
%     if a > c
%         max = a;
%     else
%         max = c;
%     end
% else
%     if b > c
%         max = b;
%     else
%         max = c;
%     end
% end
%
% season = randi([1,4])
% switch season
%     case 1
%         disp("春季")
%     case 2
%         disp("夏季")
%     case 3
%         disp("秋季")
%     otherwise
%         disp("冬季")
% end
%
% if season == 1
%     disp("春季")
% elseif season == 2
%     disp("夏季")
% elseif season == 3
%     disp("秋季")
% elseif season == 4
%     disp("冬季")
% end

% A = randi([-3,3],2,3)
% for i = A
%     i
% end

% x = 1:6;
% res_sum = 0;
% for i = x
%     res_sum = res_sum + i;
% end
% res_sum

% leap_year_num = 0;
% for i = 1:9999
%     if ((mod(i,4)==0) && (mod(i,100) ~=  0)) || (mod(i,400)==0)
%         leap_year_num = leap_year_num + 1;
%     end
% end
% leap_year_num
% f(1) = 1;
% f(2) = 1;
% n = 2;
% while f(n) <= 99999
%     n = n + 1;
%     f(n) = f(n-1) + f(n-2);
% end
% n
% f(n)
% while 1
%     disp("死循环");
% end
% i = 5;
% while i
%     i
%     i = i -1;
% end

% for i=1:10
%     if mod(i,2) == 0
%         continue;
%     end
%     i
% end
% n = 9;
% is_prime = 1;
% for i = 2:n-1
%     if(mod(n,i)==0)
%         is_prime = 0;
%         break;
%     end
% end
% is_prime

% for i = 1:2
%     for j = 1:3
%         if j <= i
%             i
%             j
%         else
%             break
%         end
%     end
% end

a = 6;
b = 10;
eps = 1e-8;  % 误差阈值
while 1
    c = (a+b) / 2;
    fc = c^3 - 8*c^2 + c - 5;
    if abs(fc) < eps
        break
    end
    fa = a^3 - 8*a^2 + a - 5;
    if fa * fc < 0
        b = c;
    else
        a = c;
    end
end
x0 = c;
x0


% % 请关注微信公众号：【数模加油站】领取更多免费资料



