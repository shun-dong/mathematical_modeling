function pure = normalize_pure(unnormalized)
%
% Normalize a pure state (set its "pure_norm" to 1)
%
% Usage: pure = normalize_pure(unnormalized)
% 

pure = to_col(unnormalized ./ pure_norm(unnormalized));
