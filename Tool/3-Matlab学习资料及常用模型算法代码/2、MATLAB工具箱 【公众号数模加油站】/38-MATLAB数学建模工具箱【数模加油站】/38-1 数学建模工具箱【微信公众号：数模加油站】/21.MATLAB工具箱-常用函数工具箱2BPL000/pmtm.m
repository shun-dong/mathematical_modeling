function varargout=pmtm(x,varargin);
%PMTM   Power Spectrum estimate via the Thomson multitaper method.
%   Pxx = PMTM(X) is the Power Spectral Density (PSD) estimate of
%   time series X using MTM (multitaper method).  
%
%   Pxx = PMTM(X,NW) uses NW as the "time-bandwidth product" for the discrete
%   prolate spheroidal sequences (or Slepian sequences) used as data windows.  
%   Typical choices for NW are 2, 5/2, 3, 7/2, or 4 (the default is 4). The
%   number of sequences used to form Pxx is 2*NW-1.
%
%   Pxx = PMTM(X,NW,NFFT) defines the frequency grid NFFT. When X is real, Pxx 
%   is length (NFFT/2+1) for NFFT even or (NFFT+1)/2 for NFFT odd; when X is 
%   complex, Pxx is length NFFT.  NFFT is optional; it defaults to the greater 
%   of 256 and the next power of 2 greater than the length of X.
%
%   [Pxx,F] = PMTM(X,NW,NFFT,Fs) returns a vector of frequencies at which the 
%   PSD is estimated, where Fs is the sampling frequency.  Fs defaults to 2 Hz.
%   
%   [Pxx,F] = PMTM(X,NW,NFFT,Fs,method) uses the algorithm in method for
%   combining the individual spectral estimates:
%      'adapt'  - Thomson's adaptive non-linear combination (default).
%      'unity'  - linear combination with unity weights.
%      'eigen'  - linear combination with eigenvalue weights.
%
%   [Pxx,Pxxc,F] = PMTM(X,NW,NFFT,Fs,method) returns the 95% confidence interval
%   Pxxc for Pxx. [Pxx,Pxxc,F] = PMTM(X,NW,NFFT,Fs,method,P) where P is a scalar
%   between 0 and 1, returns the P*100% confidence interval for Pxx. Confidence
%   intervals are computed using a chi-squared approach. Pxxc(:,1) is the lower
%   bound of the confidence interval, Pxxc(:,2) is the upper bound.
%
%   PMTM with no output arguments plots the PSD in the current or next 
%   available figure, with confidence intervals.
%
%   [Pxx,Pxxc,F] = PMTM(X,E,V,NFFT,Fs,method,P) is the PSD estimate, confidence
%   interval, and frequency vector from the data tapers in E and their 
%   concentrations V.
%
%   [Pxx,Pxxc,F] = PMTM(X,DPSS_PARAMS,NFFT,Fs,method,P) is the PSD estimate, 
%   confidence interval, and frequency vector from the data tapers computed
%   with the function DPSS with parameters in the cell array DPSS_PARAMS.
%   The elements of DPSS_PARAMS contain the parameters to DPSS starting with
%   the second one. For example, PMTM(X,{3.5,'calc','trace'},512,Fs) forces 
%   direct calculation of the Slepian sequences.  See HELP DPSS for options.
%
%   You can obtain default parameters by inserting an empty matrix [], e.g.
%   PMTM(X,[],[],10000) uses defaults for NW and NFFT.
%
%   EXAMPLE
%      Fs = 1000;   t = 0:1/Fs:.3;  x = cos(2*pi*t*200)+randn(size(t));
%      [Pxx,Pxxc,f] = pmtm(x,3.5,512,Fs,[],.99);
%      plot(f,10*log10([Pxx Pxxc]))
%
%   See also DPSS, PSD, PMEM, PMUSIC.

%   Author: Eric Breitenberger, version date 10/1/95.
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.13 $   $Date: 1997/12/02 18:36:30 $

% defaults:
N=length(x);
NW = 4;
nfft = max(256,2^nextpow2(N));
Fs = 2;
method = 'adapt';
conf = .95;

if length(varargin)>0
    if length(varargin{1})>0
        NW = varargin{1};
    end
    if iscell(NW)
        [E,V]=dpss(N,NW{:});
        NW = NW{1};
    elseif length(NW)>1 
        E = NW;
        if length(varargin)<2
            error('Must provide V with E matrix.')
        else
            V = varargin{2};
        end
        varargin(2) = [];
        if size(E,2)~=length(V)
            error('Number of columns of E and length of V do not match.')
        end
        NW = size(E,2)/2;  % only used for computation of # of tapers k
    else
     % Get the dpss, one way or another:
        [E,V] = dpss(N,NW);
    end
else
 % Get the dpss, one way or another:
    [E,V] = dpss(N,NW);
end

if length(varargin)>1 & ~isempty(varargin{2}), nfft = varargin{2}; end
if length(varargin)>2 & ~isempty(varargin{3}), Fs = varargin{3}; end
if length(varargin)>3 & ~isempty(varargin{4}), method = lower(varargin{4}); end
if length(varargin)>4 & ~isempty(varargin{5}), conf = varargin{5}; end

% error checking:
switch method
case {'adapt','unity','eigen'}
   % do nothing
otherwise
   error('Method must be ''adapt'',''unity'', or ''eigen''.')
end

if ~all(size(conf)==[1 1])
    error('Confidence interval parameter P must be a scalar.')
end

x=x(:);
k=min(round(2*NW),N); % By convention, the first 2*NW 
                      % eigenvalues/vectors are stored 
k=max(k-1,1);
V=V(1:k);

% Compute the windowed dfts and the
%   corresponding spectral estimates:
if N<=nfft
    Sk=abs(fft(E(:,1:k).*x(:,ones(1,k)),nfft)).^2;
else  
    % use CZT to compute DFT on nfft evenly spaced samples around the 
    % unit circle:
    Sk=abs(czt(E(:,1:k).*x(:,ones(1,k)),nfft)).^2;
end

% Select the proper points from fft:
if isreal(x)
    if rem(nfft,2)==0, M=nfft/2+1; else M=(nfft+1)/2; end
else
    M = nfft;
end
Sk=Sk(1:M,:);

switch method

case 'adapt'
    % Set up the iteration to determine the adaptive weights: 

    sig2=x'*x/N;                % Power
    S=(Sk(:,1)+Sk(:,2))/2;    % Initial spectrum estimate
    Stemp=zeros(M,1);
    S1=zeros(M,1);

    % The algorithm converges so fast that results are
    % usually 'indistinguishable' after about three iterations.

    % This version uses the equations from P&W pp 368-370

    % Set tolerance for acceptance of spectral estimate:
    tol=.0005*sig2/M;
    i=0;
    a=sig2*(1-V);

    % Do the iteration:
    while sum(abs(S-S1)/M)>tol
      i=i+1;
      % calculate weights
      b=(S*ones(1,k))./(S*V'+ones(M,1)*a'); 
      % calculate new spectral estimate
      wk=(b.^2).*(ones(M,1)*V');
      S1=sum(wk'.*Sk')./ sum(wk');
      S1=S1';
      Stemp=S1; S1=S; S=Stemp;  % swap S and S1
    end

case {'unity','eigen'}
    % Compute the averaged estimate: simple arithmetic
    % averaging is used. The Sk can also be weighted 
    % by the eigenvalues, as in Park et al. Eqn. 9.;
    % note that that eqn. apparently has a typo. as
    % the weights should be V and not 1/V.
    if strcmp(method,'eigen')
        wt = V(:);    % Park estimate
    else
        wt = ones(k,1);
    end
    S = Sk*wt/k;
end

% Calculate confidence limits
if nargout==0 | nargout==3
% don't calculate these unless needed, since it can take a while.
    c=S*chi2conf(conf,k);
end

ff = (0:M-1)'/nfft*Fs;  % frequency vector

if nargout == 0
% do plots
   newplot;
   plot(ff,10*log10([S c])), grid on
   xlabel('Frequency'), ylabel('Power Spectrum Magnitude (dB)');
   title('MTM Spectral Estimate')
end
if nargout > 0, varargout{1} = S; end
if nargout > 1, varargout{2} = ff; end
if nargout > 2, varargout{2} = c; varargout{3} = ff; end

