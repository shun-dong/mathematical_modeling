% Compute the commutation relations of SU(N) generators

clc

N = 5;
fprintf ('SU(%d): Find the commutation relations for the SU generators\n\n',N);

SU_gen_cache(N);

% If there's only one member of SU(N) in the comm., show it
factor = zeros(N^2-2,N^2-2);
which  = zeros(N^2-2,N^2-2)-1;
fprintf ('WhichG? Gen:');
for x=1:N^2-2
    fprintf ('%4d', x);
end
fprintf('\n');
for y=2:(N^2-1)
    fprintf ('    Gen %2d: ', y);
    for x=1:(y-1)
        c = comm(QLib.SU.gen{N}{y},QLib.SU.gen{N}{x});
        % now search
        rel = NaN;
        vich = NaN;
        for k=1:N^2
            tmp_rel = mat_scale (c, QLib.SU.gen{N}{k});
            if ~isnan(tmp_rel)
                rel = tmp_rel;
                vich = k;
            end
        end
        if ~isnan(vich)
            which(y-1,x) = vich;
            factor(y-1,x) = rel;
            fprintf ('%4d', vich);
        else
            fprintf (' (*)');
        end
    end
    fprintf ('\n');
end
fprintf ('\n\n');

% And show the factor multiplying it
for y=2:(N^2-1)
    for x=1:(y-1)
        if which(y-1,x) > 0
            if imag(factor(y-1,x)) ~= 0
                fprintf (' %8gi', imag(factor(y-1,x)));
            elseif real(factor(y-1,x)) == 0
                fprintf (' %9g', factor(y-1,x));
            else
                fprintf (' %4g%+4gi', real(factor(y-1,x)),image(factor(y-1,x)));
            end
        else
            fprintf ('       (*)');
        end
    end
    fprintf ('\n');
end
fprintf ('\n');

% But for SU(3) and above, the comm relation is sometimes a sum
% of multiple SU(N) generators. When this is so, specify

for y=2:(N^2-1)
    for x=1:(y-1)
        if which(y-1,x) < 0
            fprintf ('[gen%2d,gen%2d] = ',y,x);
            c = comm(QLib.SU.gen{N}{y},QLib.SU.gen{N}{x});
            for k = 1:(N^2-1)
                g = QLib.SU.gen{N}{k};
                if abs(trace(c' * g)) > QLib.close_enough
                    factor = trace(c'*g) / trace(g'*g);
                    if is_close(real(factor),0)
                        fprintf (' %+gi', imag(factor));
                    elseif is_close(imag(factor),0)
                        fprintf (' %+gi', imag(factor));
                    else
                        fprintf (' (%+g%+gi)', real(factor), imag(factor));
                    end
                    fprintf (' g%d', k);
                end
            end
            fprintf ('\n');
        end
    end
end