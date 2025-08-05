function pure = param_prod_pure(p, desc)
%
% Parametrization of a pure state product state 
% (i.e. outer product of of single-particle pure states)
%
% Usage: pure = param_prod_pure(p,desc)
%     p     The parameters (see param_prod_pure_size for how many)
%     desc  Descriptor (optional is all qbits)
%     pure    Thre resulting pure state
%

if nargin < 2
    desc = 2*ones(1,length(p)/2);
end

pure1 = 1;
pos = 1;
for k=1:length(desc)
    pos2 = pos + desc(k)*2-2;
    pure0 = param_pure_1(p(pos:(pos2-1)));
    pure1 = kron(pure1,pure0);
    pos = pos2;
end

pure = pure1;
