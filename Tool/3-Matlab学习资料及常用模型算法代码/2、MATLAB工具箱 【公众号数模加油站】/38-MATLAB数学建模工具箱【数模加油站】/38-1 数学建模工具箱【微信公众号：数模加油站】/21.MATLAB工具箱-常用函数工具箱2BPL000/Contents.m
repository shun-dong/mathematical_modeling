% Signal Processing Toolbox.
% Version 4.1 21-Nov-1997
%
% What's new.
%   Readme     - New features, bug fixes, and changes in this version.
%
% Waveform generation.
%   chirp      - Swept-frequency cosine generator.
%   diric      - Dirichlet (periodic sinc) function.
%   gauspuls   - Gaussian pulse generator.
%   pulstran   - Pulse train generator.
%   rectpuls   - Sampled aperiodic rectangle generator.
%   sawtooth   - Sawtooth function.
%   sinc       - Sinc or sin(pi*x)/(pi*x) function
%   square     - Square wave function.
%   tripuls    - Sampled aperiodic triangle generator.
%
% Filter analysis and implementation.
%   abs        - Magnitude.
%   angle      - Phase angle.
%   conv       - Convolution.
%   fftfilt    - Overlap-add filter implementation.
%   filter     - Filter implementation.
%   filtfilt   - Zero-phase version of filter.
%   filtic     - Determine filter initial conditions.
%   freqs      - Laplace transform frequency response.
%   freqspace  - Frequency spacing for frequency response.
%   freqz      - Z-transform frequency response.
%   grpdelay   - Group delay.
%   impz       - Impulse response (discrete).
%   latcfilt   - Lattice filter implementation.
%   unwrap     - Unwrap phase.
%   upfirdn    - Up sample, FIR filter, down sample.
%   zplane     - Discrete pole-zero plot.
%
% Linear system transformations.
%   convmtx    - Convolution matrix.
%   latc2tf    - Lattice or lattice ladder to transfer function conversion.
%   poly2rc    - Polynomial to reflection coefficients transformation.
%   rc2poly    - Reflection coefficients to polynomial transformation.
%   residuez   - Z-transform partial fraction expansion.
%   sos2ss     - Second-order sections to state-space conversion.
%   sos2tf     - Second-order sections to transfer function conversion.
%   sos2zp     - Second-order sections to zero-pole conversion.
%   ss2sos     - State-space to second-order sections conversion.
%   ss2tf      - State-space to transfer function conversion.
%   ss2zp      - State-space to zero-pole conversion.
%   tf2latc    - Transfer function to lattice or lattice ladder conversion.
%   tf2ss      - Transfer function to state-space conversion.
%   tf2zp      - Transfer function to zero-pole conversion.
%   zp2sos     - Zero-pole to second-order sections conversion.
%   zp2ss      - Zero-pole to state-space conversion.
%   zp2tf      - Zero-pole to transfer function conversion.
%
% IIR digital filter design.
%   butter     - Butterworth filter design.
%   cheby1     - Chebyshev type I filter design.
%   cheby2     - Chebyshev type II filter design.
%   ellip      - Elliptic filter design.
%   maxflat    - Generalized Butterworth lowpass filter design.
%   yulewalk   - Yule-Walker filter design.
%
% IIR filter order selection.
%   buttord    - Butterworth filter order selection.
%   cheb1ord   - Chebyshev type I filter order selection.
%   cheb2ord   - Chebyshev type II filter order selection.
%   ellipord   - Elliptic filter order selection.
%
% FIR filter design.
%   cremez     - Complex and nonlinear phase equiripple FIR filter design.
%   fir1       - Window based FIR filter design - low, high, band, stop, multi.
%   fir2       - Window based FIR filter design - arbitrary response.
%   fircls     - Constrained Least Squares filter design - arbitrary response.
%   fircls1    - Constrained Least Squares FIR filter design - low and highpass.
%   firls      - FIR filter design - arbitrary response with transition bands.
%   firrcos    - Raised cosine FIR filter design.
%   intfilt    - Interpolation FIR filter design.
%   kaiserord  - Window based filter order selection using Kaiser window.
%   remez      - Parks-McClellan optimal FIR filter design.
%   remezord   - Parks-McClellan filter order selection.
%
% Transforms.
%   czt        - Chirp-z transform.
%   dct        - Discrete cosine transform.
%   dftmtx     - Discrete Fourier transform matrix.
%   fft        - Fast Fourier transform.
%   fftshift   - Swap vector halves.
%   hilbert    - Hilbert transform.
%   idct       - Inverse discrete cosine transform.
%   ifft       - Inverse fast Fourier transform.
%
% Statistical signal processing and spectral analysis.
%   cohere     - Coherence function estimate.
%   corrcoef   - Correlation coefficients.
%   cov        - Covariance matrix.
%   csd        - Cross Spectral Density.
%   pburg      - Power Spectrum estimate via Burg's method.
%   pmtm       - Power Spectrum estimate via the Thomson multitaper method.
%   pmusic     - Power Spectrum estimate via MUSIC eigenvector method.
%   psd        - Power Spectrum estimate via Welch's method.
%   pyulear    - Power Spectrum estimate via the Yule-Walker AR Method.
%   spectrum   - psd, csd, cohere and tfe combined.
%   tfe        - Transfer function estimate.
%   xcorr      - Cross-correlation function.
%   xcov       - Covariance function.
%
% Windows.
%   bartlett   - Bartlett window.
%   blackman   - Blackman window.
%   boxcar     - Rectangular window.
%   chebwin    - Chebyshev window.
%   hamming    - Hamming window.
%   hanning    - Hanning window.
%   kaiser     - Kaiser window.
%   triang     - Triangular window.
%
% Parametric modeling.
%   invfreqs   - Analog filter fit to frequency response.
%   invfreqz   - Discrete filter fit to frequency response.
%   levinson   - Levinson-Durbin recursion.
%   lpc        - Linear Predictive Coefficients using autocorrelation method.
%   prony      - Prony's discrete filter fit to time response.
%   stmcb      - Steiglitz-McBride iteration for ARMA modeling.
%   ident      - See the System Identification Toolbox.
%
% Specialized operations.
%   cceps      - Complex cepstrum.
%   decimate   - Resample data at a lower sample rate.
%   deconv     - Deconvolution.
%   demod      - Demodulation for communications simulation.
%   dpss       - Discrete prolate spheroidal sequences (Slepian sequences). 
%   dpssclear  - Remove discrete prolate spheroidal sequences from database.
%   dpssdir    - Discrete prolate spheroidal sequence database directory.
%   dpssload   - Load discrete prolate spheroidal sequences from database.
%   dpsssave   - Save discrete prolate spheroidal sequences in database.
%   interp     - Resample data at a higher sample rate.
%   interp1    - General 1-D interpolation. (MATLAB Toolbox)
%   medfilt1   - 1-Dimensional median filtering.
%   modulate   - Modulation for communications simulation.
%   rceps      - Real cepstrum and minimum phase reconstruction.
%   resample   - Resample sequence with new sampling rate.
%   specgram   - Spectrogram, for speech signals.
%   spline     - Cubic spline interpolation.
%   vco        - Voltage controlled oscillator.
%
% Analog lowpass filter prototypes.
%   besselap   - Bessel filter prototype.
%   buttap     - Butterworth filter prototype.
%   cheb1ap    - Chebyshev type I filter prototype (passband ripple).
%   cheb2ap    - Chebyshev ty[pe II filter prototype (stopband ripple).
%   ellipap    - Elliptic filter prototype.
%
% Frequency translation.
%   lp2bp      - Lowpass to bandpass analog filter transformation.
%   lp2bs      - Lowpass to bandstop analog filter transformation.
%   lp2hp      - Lowpass to highpass analog filter transformation.
%   lp2lp      - Lowpass to lowpass analog filter transformation.
%
% Filter discretization.
%   bilinear   - Bilinear transformation with optional prewarping.
%   impinvar   - Impulse invariance analog to digital conversion.
%
% Other.
%   besself    - Bessel analog filter design.
%   conv2      - 2-D convolution.
%   cplxpair   - Order vector into complex conjugate pairs.
%   detrend    - Linear trend removal.
%   fft2       - 2-D fast Fourier transform.
%   fftshift   - Swap quadrants of array.
%   ifft2      - Inverse 2-D fast Fourier transform.
%   polystab   - Polynomial stabilization.
%   stem       - Plot discrete data sequence.
%   strips     - Strip plot.
%   xcorr2     - 2-D cross-correlation.
%
% Signal GUI (Graphical User Interface).
%   sptool      - Signal Processing Tool interface.
%
% Demonstrations.
%   cztdemo    - Chirp-z transform and FFT demonstration.
%   filtdemo   - Filter design demonstration.
%   moddemo    - Modulation/demodulation demonstration.
%   sosdemo    - Second-order sections demonstration.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
%       $Revision: 1.43 $

