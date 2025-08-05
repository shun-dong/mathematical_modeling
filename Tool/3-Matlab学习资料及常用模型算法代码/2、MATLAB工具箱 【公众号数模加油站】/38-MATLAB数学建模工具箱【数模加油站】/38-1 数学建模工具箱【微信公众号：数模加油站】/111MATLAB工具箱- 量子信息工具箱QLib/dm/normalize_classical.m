function normalized = normalize_classical(unnormalized)
%
% Normalize a classical probablity distribution
%
% Usage: normalized = normalize_pure(unnormalized)
% 

norma = sum(unnormalized'*unnormalized);
normalized = unnormalized ./ norma;