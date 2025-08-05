% Show the scaling of the negativity for a division an "n of M" bipartition
% of the GHZ state

clc

DESC = [5 2 3 3 4 2];
Nmax = 6;
ret = NaNs(Nmax-1,Nmax);

for N=2:(Nmax-1)
    desc = DESC(1:N)
    pure = GHZ(desc, ones(length(desc),1), desc);
    dm = pure2dm(pure);
    for k=0:N
        fprintf ('(%2d,%2d) of (%2d,%2d)\n', N,k, Nmax-1, N);
        mask = zeros(N,1); 
        if (k > 0)
            mask(1:k) = 1;
        end
        ret(N,k+1) = real(negativity(dm, mask, desc));              
    end
end

ret