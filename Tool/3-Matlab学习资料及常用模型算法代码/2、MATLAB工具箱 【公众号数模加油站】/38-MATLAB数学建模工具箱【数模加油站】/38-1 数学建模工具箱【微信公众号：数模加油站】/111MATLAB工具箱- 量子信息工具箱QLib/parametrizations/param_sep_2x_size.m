function n = param_sep_2x_size(desc)
%
% Get the dimension of the separable state parametrization param_sep_p_2x
% 
% Usage: n = param_sep_2x_size (desc)
%     desc           DM descriptor
%     n              The size of the parameter space
%
% Reference:
%     [1] Separability criterion and inseparable mixed states with positive
%         partial transposition, Pawel Horodecki,   PLA 232 (1997) p. 333
%

pd = prod(desc);
pd2 = pd*pd;
sd = sum(desc);

n = pd2*sd*2+pd2;