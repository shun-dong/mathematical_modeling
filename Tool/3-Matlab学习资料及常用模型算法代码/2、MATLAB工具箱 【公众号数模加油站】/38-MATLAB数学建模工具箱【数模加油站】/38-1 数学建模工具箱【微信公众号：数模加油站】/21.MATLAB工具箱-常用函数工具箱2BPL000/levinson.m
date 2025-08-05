function a=levinson(R,N);
%LEVINSON  Levinson-Durbin Recursion.
%   A = LEVINSON(R,N) solves the Yule-Walker system of equations
%   using the Levinson-Durbin recursion.  R is a vector of 
%   autocorrelation coefficients, starting with lag 0 as the first element. 
%   N is the order of the recursion; A will be a length N+1 row, with 
%   A(1) = 1.
%
%   If you do not specify N, LEVINSON uses N = LENGTH(R)-1.
%
%   The Yule-Walker system of equations is of the form:
%       [  R(1)   R(2)* ...  R(N)* ] [  A(2)  ]  = [  -R(2)  ]
%       [  R(2)   R(1)  ... R(N-1)*] [  A(3)  ]  = [  -R(3)  ]
%       [   .        .         .   ] [   .    ]  = [    .    ]
%       [ R(N-1) R(N-2) ...  R(2)* ] [  A(N)  ]  = [  -R(N)  ]
%       [  R(N)  R(N-1) ...  R(1)  ] [ A(N+1) ]  = [ -R(N+1) ]
%   (where * denotes complex conjugation).
%   If N is small (< 195), LEVINSON uses the \ function to solve this
%   system.  This is faster than the Levinson-Durbin recursion because
%   \ is built-in.
%
%   If R is a matrix, LEVINSON finds coefficients for each column of R,
%   and returns them in the rows of A.
%
%   See also LPC, PRONY, STMCB.

%   Author(s): T. Krauss, 3-18-93
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 1997/11/26 20:13:32 $

%   Reference(s):
% 	  [1] Lennart Ljung, "System Identification: Theory for the User",
%         pp. 278-280

    error(nargchk(1,2,nargin))
    if nargin < 2, N = length(R)-1; end
    if length(R)<(N+1), error('Correlation vector too short.'), end

    R=conj(R); % Sets up to solve as in most textbooks
    
    [r,c]=size(R);
    if c>=1 & r==1
        R = R(:);   % force R to be a column
    end   
    numsigs = size(R,2);   % number of columns of R
      % if R is a matrix, use each column as an input

    if (N>195),     % use higher overhead, but asymptotically faster algorithm
        c = conj(R(2,:))./R(1,:);
        for n = 2:N,
            flipc = conj(c(n-1:-1:1,:));
            c1 = ( conj(R(n+1,:)) - sum(conj(R(n:-1:2,:)).*c,1) ) ./ ...
                 ( R(1,:) - sum(conj(R(n:-1:2,:)).*flipc,1) );
            c = [c-c1(ones(1,n-1),:).*flipc; c1];
        end
        a = [ones(1,numsigs); -c].';
    else    % use the good old \ command
        a=[];
        for i=1:numsigs
            b=-conj(R(2:N+1,i));
            a = [ a; 1 (toeplitz(R(1:N,i))\(b(:))).' ];
        end
    end
