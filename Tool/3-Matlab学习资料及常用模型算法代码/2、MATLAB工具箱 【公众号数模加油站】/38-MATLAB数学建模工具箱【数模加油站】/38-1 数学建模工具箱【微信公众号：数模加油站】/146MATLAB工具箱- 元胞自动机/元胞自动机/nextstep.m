function cells=nextstep(cells)
%index definition for cell update
[n,m]=size(cells);
x = 2:n-1;
y = 2:m-1;
%nearest neighbor sum
sums=zeros(n,m);
sums(x,y) = cells(x,y-1) + cells(x,y+1) + ...
    cells(x-1, y) + cells(x+1,y) + ...
    cells(x-1,y-1) + cells(x-1,y+1) + ...
    cells(3:n,y-1) + cells(x+1,y+1);
% The CA rule
cells = (sums==3) | (sums==2 & cells);
end