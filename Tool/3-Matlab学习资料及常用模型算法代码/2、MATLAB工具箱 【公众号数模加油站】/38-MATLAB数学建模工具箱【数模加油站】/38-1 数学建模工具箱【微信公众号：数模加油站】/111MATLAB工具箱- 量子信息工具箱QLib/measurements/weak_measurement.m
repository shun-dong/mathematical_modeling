function w = weak_measurement(pre, op, post)
%
% Compute the real part of a weakly measured value
%
% Usage:
%     pre   The pre-selected state
%     op    The operator measured
%     post  The post-selected state
%     w     The weak-ly measured value
%

mehane = post' * pre;
if is_close(mehane, 0)
    w = NaN;
else
    w = real ((post' * op * pre) / mehane);
end
