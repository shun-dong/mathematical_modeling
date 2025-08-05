function dm = normalize_dm(unnormalized)
%
% Normalize a density matrix to have trace 1
%
% Usage: dm = normalize_dm(unnormalized)
% 

dm = unnormalized ./ sqrt(trace(unnormalized));