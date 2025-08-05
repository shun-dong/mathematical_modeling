function cp = cannonize_pure(pure)
%
% Set the global phase of a pure state to 1 (i.e. make the first non-zero element real)
%
% Usage: cp = cannonize_pure(pure)
%
% Note: The function does not normalize the state (i.e. set its norm to 1).
%       To do that you need to cannonize_pure(normalize_pure(pure))
%

v = pure(find(pure, 1, 'first'));
cp = pure ./ v .* abs(v);
