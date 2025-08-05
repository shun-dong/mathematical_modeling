function ok = is_pure (dm)
%
% Check if a dm is a pure state
%
% Usage: ok = is_pure (pure)
%     dm - The density matrix
%     ok - 0/1 no/yes
%

[v,d] = eig(dm);
ok = is_close(max(diag(d)),1);
