function [y] = RandLogistic(m,n)

if nargin==1
    y = rand(m,m); 
elseif nargin==0
    y = rand();    
else
    y = rand(m,n);
end

for i = 1:100
    y = 4*y.*(1-y);
end

end

