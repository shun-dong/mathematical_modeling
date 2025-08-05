function dm = param_prod(p, desc)
%
% Parametrization of a product DM
%
% Usage: dm = param_prod (p, desc)
%     p    Parameters. sum(desc(k).^2-1) of them
%     desc Descriptor. Optional for qbits only
%
% A product DM is an kron of single-particle DMs
%


global QLib;

if nargin < 2
    n33 = length(p)/3; % There are 3 params for a qbit dm
    r33 = round(n33);
    if abs(n33-r33) > QLib.close_enough
        error ('Cannot generate descriptor - number of parameters not a multiple of 3');
    end
    desc = ones(1,r33)*2;
end

pos = 1;
dm = 1;
for k=length(desc):-1:1
    next_pos = pos + desc(k)^2-1;
    dm = kron (dm, param_dm(p(pos:(next_pos-1))));
    pos = next_pos;
end
