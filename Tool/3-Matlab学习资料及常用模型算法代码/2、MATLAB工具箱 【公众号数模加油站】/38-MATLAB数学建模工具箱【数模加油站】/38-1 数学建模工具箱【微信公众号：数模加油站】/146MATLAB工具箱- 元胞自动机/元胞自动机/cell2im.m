function CellData=cell2im(cells)
[n,m]=size(cells);
a=ones(n,m);
a1=a; a2=a;a3=a;
for ii=1:n
   for jj=1:m
     if cells(ii,jj)==1
         a1(ii,jj)=0;
         a2(ii,jj)=0;
     end
   end
end
CellData=cat(3,a1,a2,a3);
end