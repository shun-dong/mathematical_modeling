function [h,a] = firrcos(N,f0,df,Fs)
%FIRRCOS Raised Cosine FIR Filter design.
%    FIRRCOS(N,F0,DF,Fs) returns an order N low pass linear phase FIR filter 
%    with a raised cosine transition band.  The filter has cutoff frequency 
%    F0, transition width DF, and sampling frequency Fs, all in Hz.
%    F0 must be between 0 and Fs/2.  DF must be small enough so that 
%    F0 +/- DF/2 is between 0 and Fs/2.
%    FIRRCOS minimizes the integral squared error in the frequency domain.  
%    The filter order N must be even.
%
%    FIRRCOS(N,F0,DF) uses a default sampling frequency of Fs = 2.
%
%    See also FIRLS, FIR1, FIR2.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.7 $

% To get the same filter as rcosfir in the Communications Toolbox, use
%  hh=firrcos(RATE*N_T(2)*2,1/(2*T),R/T,RATE/T)*RATE

%    T. Krauss, 2/8/96

    if nargin<4
        Fs = 2;
    end

    if (f0<=0) | (f0>=Fs/2)
        error('Cutoff frequency must be between 0 and Fs/2.')
    end
    if ((f0-df/2)<0) | ((f0+df/2)>Fs/2)
        error('Transition region must be between 0 and Fs/2.')
    end

    w0 = 2*pi*f0/Fs;
    m = 2*pi*df/Fs;
    if rem(N,2)
       error('Order must be even.')
    end

    n = 0:N/2;

    a = w0-m/2;
    b = w0+m/2;

% lowpass part - integral of cos(w*n) from 0 to a:
    lp = a*sinc(a*n/pi);

    if df == 0 % zero transition width
        hp_dc = 0;
        hp = 0;
    else
% constant part of raised sine:
        hp_dc = 0.5*(b*sinc(b*n/pi) - a*sinc(a*n/pi));
% sinusoidal part of raised sine:
        % in symbolic, solve
        % y = '( 1/2*sin(pi/(b-a)*(w-(a+(b-a)/2))))*cos(w*n)' 
        % yy=int(y,'w','a','b');
        % yys=simple(yy)
        %yys =
        %1/2*(-b+a)^2*n*(sin(n*b)+sin(n*a))/(-n*b+n*a-pi)/(-n*b+n*a+pi)

        %  Find where n*m == +/- pi:
        nms = (n*m).^2;
        ind = find((abs(nms-pi^2)>sqrt(eps)));
        ni = 1:length(n);
        ni(ind) = [];
    
        hp = zeros(size(n));
        hp(ind) = -0.5*(a-b)^2*n(ind).*( sin(n(ind)*b)+sin(n(ind)*a) )./ ...
                   ( (n(ind)*(a-b)-pi).*(n(ind)*(a-b)+pi) );

        %  Use L'Hopital's for n*(a-b) = +/- pi:
        hp(ni) = -0.5*( sin(n(ni)*b)+sin(n(ni)*a) + ...
                    n(ni).*(b*cos(n(ni)*b)+a*cos(n(ni)*a)) ) ./ (2*n(ni));

    end

    h = (lp+hp_dc+hp)/pi;
    h = [fliplr(h(2:end)) h];

    if nargout > 1
        a = 1;
    end

