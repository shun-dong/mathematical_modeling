A = rand(2000,1000);
B = rand(2000,1000);
beta = 0.5;
tic
K1 = zeros(size(A,1),size(B,1));
 for i = 1 : size(A,1)
   for j = 1 : size(B,1)
     K1(i,j) = exp(-sum((A(i,:)-B(j,:)).^2)/beta);
   end
 end
 t1 = toc;
 tic;
 sA = (sum(A.^2, 2));
 sB = (sum(B.^2, 2));
 K2 = exp(bsxfun(@minus,bsxfun(@minus,2*A*B', sA), sB')/beta);
 t2 = toc;
