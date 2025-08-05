function p = param_p_3_sqrt (a)
%
% A parametrization of probability distribution, utilizing N-1 parameters
% 
% Usage: param_p_3_sqrt(a)
%     a: Array of N-1 parameters. Natural range is 0..1 and cycles beyond
%     p: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is not uniform under permutation 
%

p = param_p_3(a).^0.5;
