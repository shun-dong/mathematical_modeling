function p = param_p_2x (a)
%
% A parametrization of probability distribution, utilizing N parameters
% 
% Usage: param_p_2x(a)
%     a: Array of N parameters. Range 0..1 and cycle beyond
%     p: P's (real positive), which sum up to 1
%
% NOTE: The resulting distribution is uniform under permutation 
%       (but far from uniform - p's close to 1 are rate (which is as it should be)). 
% NOTE: For all zeros, the function returns a NaN distribution
%


zavit = to_col(a)*2*pi;
sinsin = sin(zavit);
sinsin2 = sinsin .* sinsin;

p = sinsin2;

s = sum(p);
if is_close(s,0)
    p = NaNs(size(p));
else
    p = p ./ sum(p);
end
