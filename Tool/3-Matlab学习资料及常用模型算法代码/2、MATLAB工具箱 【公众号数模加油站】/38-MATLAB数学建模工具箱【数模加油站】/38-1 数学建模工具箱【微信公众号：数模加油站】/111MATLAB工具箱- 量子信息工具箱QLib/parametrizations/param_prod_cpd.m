function cpd = param_prod_cpd(p, desc)
%
% Parametrization of a CPD product state 
% (i.e. outer product of of single-particle CPDs)
%
% Usage: cpd = param_prod_cpd(p,desc)
%     p     The parameters (see param_prod_cpd_size for how many)
%     desc  Descriptor (optional is all bits)
%     cpd    Thre resulting cpd state
%

if nargin < 2
    desc = 2*ones(1,length(p));
end

cpd1 = 1;
pos = 1;
for k=1:length(desc)
    pos2 = pos + desc(k)-1;
    cpd0 = param_p_1(p(pos:(pos2-1)));
    cpd1 = kron(cpd1,cpd0);
    pos = pos2;
end

cpd = cpd1;
