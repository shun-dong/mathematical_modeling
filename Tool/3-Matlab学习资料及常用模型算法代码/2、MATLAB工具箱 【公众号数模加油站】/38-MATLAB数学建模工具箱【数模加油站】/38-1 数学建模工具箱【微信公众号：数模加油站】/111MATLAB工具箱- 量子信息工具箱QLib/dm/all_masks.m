function ret = all_masks(N)
%
% Get a list of all masks to all subsets of particles
% 
% Usage: ret = all_mask(N)
%
%     N     How many particles? Also length(desc)
%     ret   Each row is a different mask
%           2^N x N logica matrix
%

ret = logical(zeros(2^N,N));

for b = uint32(0):uint32((2^N-1))
    mask = 1;
    for d=uint32(1):uint32(N)
        if bitand(b,mask)
            ret(b+1,d) = 1;
        end
        mask = mask * 2;
    end
end

