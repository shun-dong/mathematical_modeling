function varargout = PBURG( x, p, nfft, Fs)
%PBURG   Power Spectrum estimate via Burg method.
%   Pxx = PBURG(X,ORDER,NFFT) is the Power Spectral Density estimate of signal 
%   vector X using the Burg method.  ORDER is the model order of the AR
%   model equations. NFFT is the FFT length which determines the frequency grid.
%   Pxx is length (NFFT/2+1) for NFFT even, (NFFT+1)/2 for NFFT odd, and NFFT if
%   X is complex.  NFFT is optional; it defaults to 256.
%
%   [Pxx,F] = PBURG(X,ORDER,NFFT,Fs) returns a vector of frequencies at which
%   the PSD is estimated, where Fs is the sampling frequency.  Fs defaults to
%   2 Hz.
%
%   [Pxx,F,A] = PBURG(X,ORDER,NFFT) returns the vector A of model coefficients
%   on which Pxx is based.
%
%   PBURG with no output arguments plots the PSD in the next available figure.
%
%   You can obtain a default parameter for NFFT and Fs by inserting an empty
%   matrix [], e.g., PBURG(X,4,[],1000).
%
%   See also PMEM, PMTM, PMUSIC, PSD, LPC, PRONY.

%   Ref: S.L. Marple, DIGITAL SPECTRAL ANALYSIS WITH APPLICATIONS,
%              Prentice-Hall, 1987, Chapter 7

%   Author(s): D. Orofino
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 1997/11/26 20:13:37 $

error(nargchk(2,4,nargin))

if  isempty(p)
   error('Model order must be given, empty not allowed.')
end
if issparse(x),
   error('Input signal cannot be sparse.')
end
if nargin < 4, Fs = [];   end  
if nargin < 3, nfft = []; end

if isempty(nfft), nfft = 256; end
if isempty(Fs), Fs = 2; end

x  = x(:);
N  = length(x);
ef = x;
eb = x;
a  = 1;
E  = x'*x / N;
K = zeros(p,1);

for i = 2:p+1,
   ep = ef(i:N);
   em = eb(i-1:N-1);
   K(i-1) = 2 * ep' * em / (ep'*ep + em'*em);
   a = [a;0] - K(i-1) * [0;flipud(a)];
   
   for j = N:-1:i,
      ef_old = ef(j);
      ef(j)  = ef(j)   - K(i-1) * eb(j-1);
		eb(j)  = eb(j-1) - K(i-1) * ef_old;
   end
   
   E(i) = (1 - K(i-1)'*K(i-1)) * E(i-1);
end

Spec2 = abs( fft( a, nfft ) ) .^ 2;
Pxx   = E(end) ./ Spec2;

%--- Select first half only, when input is real
if isreal(x),
    if rem(nfft,2),    % nfft odd
        select = (1:(nfft+1)/2)';
    else
        select = (1:nfft/2+1)';
    end
else
    select = (1:nfft)';
end

Pxx = Pxx(select);
ff = (select - 1)*Fs/nfft;

if nargout == 0
   newplot;
   plot(ff,10*log10(Pxx)), grid on
   xlabel('Frequency'), ylabel('Power Spectrum Magnitude (dB)');
   title('Burg Spectral Estimate')
end

if nargout >= 1
    varargout{1} = Pxx;
end
if nargout >= 2
    varargout{2} = ff;
end
if nargout >= 3
    varargout{3} = a;
end
