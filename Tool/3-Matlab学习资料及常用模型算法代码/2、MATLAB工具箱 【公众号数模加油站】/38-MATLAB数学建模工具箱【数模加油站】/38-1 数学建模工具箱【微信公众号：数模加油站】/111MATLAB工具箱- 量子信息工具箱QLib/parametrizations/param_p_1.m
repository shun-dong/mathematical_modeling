function p = param_p_1 (a)
%
% Parametrization of probability distribution.
% 
% Usage: param_p_1(a)
%     a: Array of length N-1. Range 0..1 and cycle beyond
%     p: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is NOT uniform under permutation (it's not
% even close) and it's cumulative sum is not smooth either.
% 
% See param_p_1_sqrt for further details
%      

p = param_p_1_sqrt(a);
p = p.*p;


