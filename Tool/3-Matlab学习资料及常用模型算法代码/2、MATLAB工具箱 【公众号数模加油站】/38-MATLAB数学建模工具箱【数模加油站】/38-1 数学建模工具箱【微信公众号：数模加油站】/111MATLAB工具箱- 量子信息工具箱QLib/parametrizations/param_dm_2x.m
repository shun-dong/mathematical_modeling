function rho = param_dm_2x (p)
%
% Parametrization of DM by direct specification of the real and imaginary
% parts, transforming this into an Hermitian matrix, and forcing trace 1
%
% rho = param_dm_2x (p)
%     p     The parametrization. For the size see param_dm_2x_size
%     rho   The resulting DM
%
% References :
%     [1] Grodalski, EWtlinger and James, Phys Lett A 300 (2002) 573-880
%

p = to_row(p);
nn = length(p)/2;
n = sqrt(nn);

T = reshape(p(1:nn),[n n]) + i*reshape(p((nn+1):(2*nn)),[n n]);

TTtag = T*T';

rho = TTtag / trace(TTtag);