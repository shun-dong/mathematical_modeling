function p = param_p_2x_sqrt (a)
%
% A parametrization of the square root of a probability distribution,
% utilizing N parameters
% 
% Usage: param_p_2x_sqrt (a)
%     a: Array of N parameters. Range 0..1 and cycle beyond
%     result: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is not uniform under permutation 
%       (but not as bad as param_p). 
% NOTE: For all zeros, the function returns a NaN distribution
%

p = param_p_2x(a);
p = p.^0.5;
