function dephased_pure = no_globa_phase (pure)
%
% Remove global phase from a pure state
%
% Usage: dephased_pure = no_globa_phase (pure)
%     pure - A pure state
%     dephased_pure - The result, see below
%
% The phase normalization we use for pure states is that the first non-zero
% element is real.
%

idx = min(find(abs(pure))); % First non-zero element

if length(idx) >= 1
    z = pure(idx(1));
    x = (real(z) - i*imag(z)) / abs(z);
    dephased_pure = pure.*x;
    dephased_pure(1) = real(dephased_pure(1)); % Eliminate tiny imaginary part
else
    dephased_pure = pure;
end
