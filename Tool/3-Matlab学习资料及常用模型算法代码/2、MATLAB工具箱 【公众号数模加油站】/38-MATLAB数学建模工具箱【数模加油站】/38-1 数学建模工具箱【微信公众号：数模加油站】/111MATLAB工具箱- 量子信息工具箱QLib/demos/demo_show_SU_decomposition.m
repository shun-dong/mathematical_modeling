% Is a sum of matrices from SU(n) x SU(m) equivalent to SU(n*m) ?
% Hint: yes
% This is verified by replicating all SU(n*m) generators using sums of SU(n)xSU(m)
%
% SU(n)xSU(m) had n^2*m^2 members, which are clearly linearly independent
% SU(n*m) also had (n*m)^2 linearly independent members.
% Therefore, these groups are equivalent, i.e. are a rotation of each other

clc

desc2 = [5 3];

disp (sprintf('Is Sum(SU(%d)*SU(%d)) == SU(%d) ?', desc2(1), desc2(2), prod(desc2)));

SU_gen_cache (prod(desc2));

gen1 = {};
for k1=1:length(QLib.SU.gen{desc2(1)})
    for k2=1:length(QLib.SU.gen{desc2(2)})
        gen1{end+1} = kron(QLib.SU.gen{desc2(1)}{k1}, QLib.SU.gen{desc2(2)}{k2});
    end
end

gen2 = {};
for kk=1:length(QLib.SU.gen{prod(desc2)})
    gen2{kk} = QLib.SU.gen{prod(desc2)}{kk};
end

for k=1:length(gen1)
    test_set = {};
    for m=1:length(gen1)
        test_set{m} = gen1{m};
    end
    test_set{end+1} = gen2{k};
    if are_these_linearly_independent(test_set{:})
        disp (sprintf('SU(%d)*SU(%d)', desc2(1), desc2(2)));
        gen1{:}
        disp ('Generator %d of SU(%d)', k, prod(desc2));
        gen2{k}
        error (sprintf('Surprise 1: SU(%d)*SU(%d) cannot parse SU(%d)''s generator %d', desc2(1), desc2(2), prod(desc2), k));
    end
end

for k=1:length(gen1)
    test_set = {};
    for m=1:length(gen2)
        test_set{m} = gen2{m};
    end
    test_set{end+1} = gen1{k};
    if are_these_linearly_independent(test_set{:})
        disp (sprintf('SU(%d)*SU(%d)', desc2(1), desc2(2)));
        gen1{:}
        disp ('Generator %d of SU(%d)', k, prod(desc2));
        gen2{k}
        error (sprintf('Surprise 1: SU(%d)*SU(%d) cannot parse SU(%d)''s generator %d', desc2(1), desc2(2), prod(desc2), k));
    end
end

disp ('Answer: Yes');