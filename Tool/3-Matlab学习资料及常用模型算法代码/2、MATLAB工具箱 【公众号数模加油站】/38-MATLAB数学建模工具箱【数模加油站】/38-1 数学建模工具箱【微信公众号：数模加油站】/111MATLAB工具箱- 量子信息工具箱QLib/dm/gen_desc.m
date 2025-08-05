function desc = gen_desc(a) 
%
% Generate a N qbit descriptor for a dm, pure or CPD
%
% Usage: desc = gen_desc(a) 
%
%     a - A vector for a pure state (size 2^N for some N) or
%         A matrix of size 2^N x 2^N for some N
%     desc - A vector of 2's of the appropriate length
%
% Will issue and error if the parameter does not conform to a 2^N size or failed validation
%

global QLib;

if (size(a,1) == size(a,2))
    N = size(a,1); % DM
elseif size(a,2) == 1
    N = size(a,1); % CPD or pure state
else
    error ('gen_desc: parameter must be a dm (square matrix) or a CPD / pure state (column vector)');
end

n22 = log2(N);
r22 = round(n22);
if abs(n22 - r22) > QLib.close_enough
    error (sprintf ('gen_desc: size of parameter is %d, which is not a power of 2', N));
end

desc = ones(1,r22)*2;



