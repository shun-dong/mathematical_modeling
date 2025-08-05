function p = param_p_3 (a)
%
% A parametrization of probability distribution, utilizing N-1 parameters
% 
% Usage: param_p_3(a)
%     a: Array of N-1 parameters. Natural range is 0..1 and cycles beyond
%     p: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is not uniform under permutation 
%


zavit = to_col(a)*2*pi;
sinsin = sin(zavit);
sinsin2 = sinsin .* sinsin;

p = diff([0 ; sort(sinsin2) ; 1]);
