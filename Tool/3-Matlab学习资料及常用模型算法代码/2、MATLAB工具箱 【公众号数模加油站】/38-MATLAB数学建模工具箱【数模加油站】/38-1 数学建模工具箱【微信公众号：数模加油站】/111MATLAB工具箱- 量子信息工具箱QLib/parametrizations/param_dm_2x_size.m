function sz = param_dm_2x_size(desc)
%
% Get size of a parametrization of DM by direct specification of the 
% real and imaginary parts, transforming this into an Hermitian matrix, 
% and forcing trace 1.
%
% rho = param_dm_2x (p)
%     p     The parametrization. For the size see param_dm_2x_size
%     rho   The resulting DM
%
% References :
%     [1] Grodalski, EWtlinger and James, Phys Lett A 300 (2002) 573-880
%

sz = 2*prod(desc)^2;