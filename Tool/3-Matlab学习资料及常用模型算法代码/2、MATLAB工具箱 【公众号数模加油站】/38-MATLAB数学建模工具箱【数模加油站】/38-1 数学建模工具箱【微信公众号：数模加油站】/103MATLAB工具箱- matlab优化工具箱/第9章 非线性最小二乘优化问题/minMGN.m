function [x,minf] = minMGN(f,x0,var,eps)
format long;
if nargin == 3
    eps = 1.0e-6;
end
S = transpose(f)*f;
k = length(f);
n = length(x0);
x0 = transpose(x0);
tol = 1;
A = jacobian(f,var);

while tol>eps
    Fx = zeros(k,1);
    for i=1:k
        Fx(i,1) = Funval(f(i),var,x0);
    end
    Sx = Funval(S,var,x0);
    Ax = Funval(A,var,x0);
    gSx = transpose(Ax)*Fx;

    dx = -transpose(Ax)*Ax\gSx;
    alpha = 1;
    while 1
        S1 = Funval(S,var,x0+alpha*dx);
        S2 = Sx+2*(1.0e-5)*alpha*transpose(dx)*gSx;
        if S1>S2
            alpha = alpha/2;
            continue;
        else
            break;
        end
    end
    x0 = x0 + alpha*dx;
    tol = norm(dx);
end
x = x0;
minf = Funval(S,var,x);
format short;


