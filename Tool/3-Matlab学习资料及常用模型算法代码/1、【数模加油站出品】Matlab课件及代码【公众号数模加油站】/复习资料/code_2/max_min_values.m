function [max,min] = max_min_values(X)
max = subfuc1(X);
min = subfuc2(X);
    function r = subfuc1(X)
        x1 = sort(X,'descend');
        r = x1(1);
    end
    function r = subfuc2(X)
        x1 = sort(X);
        r = x1(1);
    end
end
