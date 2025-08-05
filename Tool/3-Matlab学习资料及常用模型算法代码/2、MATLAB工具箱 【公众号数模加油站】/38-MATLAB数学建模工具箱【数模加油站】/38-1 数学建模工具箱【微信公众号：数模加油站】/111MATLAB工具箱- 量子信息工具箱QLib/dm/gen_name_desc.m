function name_desc = gen_name_desc(n)
%
% Generate the default name descriptor
% 
% Usage: name_desc = gen_name_desc(n)
%     n - How many particles
%     name_desc - Will contain {'A','B','C', ...}
%

name_desc = {};
for k=1:n
    name_desc{k} = char('A'+k-1);
end
