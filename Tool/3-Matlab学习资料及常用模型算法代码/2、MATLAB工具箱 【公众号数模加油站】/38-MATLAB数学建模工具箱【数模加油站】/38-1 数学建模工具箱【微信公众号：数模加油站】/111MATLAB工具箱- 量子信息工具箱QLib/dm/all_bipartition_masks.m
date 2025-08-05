function ret=all_bipartition_masks(N)
%
% Get a list of all bipartitions of a set of particles.
%
% Usage: ret = all_mask(N)
%
%     N     How many particles? Also length(desc)
%     ret   Each row is a different mask
%           2^(N-1) x N logical matrix
% 
% Notes: 
% 1.  The complementary subsets are calculated by "~ret"
%     If you wish to skip the "all-in" mask, ignore the last line of ret
% 2.  Unlike all_masks, this function will not return both a subset mask and it's complement.
% 3.  By it's nature, bipartition is not symmetric. In this implementation, the last 
%     particle is always present all subsets. 
% 4.  Note 3 implies that the "all-in" mask is also returned.
%

ret = all_masks(N-1);
ret(:,end+1) = 1;
