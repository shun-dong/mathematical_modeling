function n = param_H_2_size(desc)
% 
% Get number of parameters for param_H_2
%
% Usage: n = param_H_2_size(p)
%     desc  The descriptor of the DM or state on which H will act
%     n     The number of parameters 
%
% See param_H_2 for further details
%

n = prod(desc)^2;
