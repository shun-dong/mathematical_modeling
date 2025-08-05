% README file for the Signal Processing Toolbox.
% Version 4.1   21-Nov-1997
%
% List of changes:
%
% * NOTE: Items marked with * have changed in a way which might affect your 
%         code!
%
% FIXES
% ~~~~~
%   cremez
%       * Results structure fixes:  RES.H is now the actual frequency
%         response on the frequency grid returned by RES.fgrid.  RES.fextr
%         was wrong and has been corrected.  RES.fgrid and RES.fextr are
%         now normalized correctly with 1 corresponding to half the
%         sampling frequency.
%       - The problem where cremez would return a complex filter when it
%         was supposed to return a real filter has been fixed.
%
%  invfreqz
%  invfreqs
%       - Now both work for complex filters.
%
%  levinson
%  lpc
%  xcorr
%       * Incorrectly returned conjugate for complex cases.
%
%
% ENHANCEMENTS
% ~~~~~~~~~~~~
%    hamming
%    hanning
%    blackman
%       - now accept two new parameters to describe window sampling:
%         'symmetric' or 'periodic'; passing in an empty matrix now returns
%         an empty matrix; passing in one point returns unity.
%
%
% NEW FUNCTIONS
% ~~~~~~~~~~~~~
%    pburg   
%       - power spectrum estimate using Burg's method.
%    pyulear 
%       - power spectrum estimate using Yule-Walker AR method.
%
% GRAPHICAL USER INTERFACE
% ~~~~~~~~~~~~~~~~~~~~~~~~
%   SPTOOL          - Support for importing component structures from the
%                     MATLAB command line was added.
%   FILTER DESIGNER - The Filter Designer was completely redesigned.  It has
%                     a better interface and now it's extensible.
%                     Measurements of the filter design can be viewed as
%                     the filter is designed.  It also allows the overlay
%                     of spectra.  
%   FILTER VIEWER   - Now supports the viewing (overlaying) of multiple
%                     filters. Measurement rulers were added.
%   SPECTRUM VIEWER - The following new PSD methods were added: Burg, FFT
%                     and Yule-Walker AR.
%

% -----------------------------------------------------------------------------
% README file for the Signal Processing Toolbox.
% Version 4.0.1   04-Apr-1997
%
% This version contains fixes to bugs and a few enhancements in the GUI and 
% functions.  The full Readme file for version 4.0 is included below.
%
% List of changes:
%
% * NOTE: Items marked with * have changed in a way which might affect your 
%         code!
%
%   chebwin 
%       - Supports even length windows.
%       - Gives more accurate side-lobe heights especially when R is small 
%         (< ~20 dB).
%       * This improvement will cause your results to change where you use the 
%         Chebyshev window (especially when R is small).
%   cremez 
%       - Allows for LGRID grid density input to improve exactness of the
%         filter design in some cases.
%       - Returns a few more results in the RES structure output.
%   dpss 
%       * Always computes Slepian sequences directly, returning more accurate 
%         (and slightly different) results for large N.
%       - Uses MEX-file based algorithm which is much faster than in ver 4.0.  
%       - Can return any range of the N sequences, not just the first 2*NW. 
%   impinvar
%       - Now works for multiple poles. 
%   lpc
%       * Now calculates the correct gain G based on a biased autocorrelation.
%        The gain factor is now 1/sqrt(length(X)) times the previous gain
%        factor.
%   pmem
%       - The default for Fs is changed to 2, to be consistent with other 
%         spectral estimation routines.  
%       * This change will affect your plots if you use the second output 
%         argument to this function without specifying Fs on input.
%   prony
%       * Now works correctly for complex inputs.
%   remez
%       - Is now a "function-function", which allows you to write a function 
%         that defines the desired frequency response.  This feature is 
%         completely backwards compatible but allows greater flexibility in 
%         designing filters with arbitrary frequency responses.  See the 
%         remez.m M-file for details about how to do this.  
%       - Now takes an LGRID grid density input to improve exactness of the 
%         filter design.  By increasing this parameter your filter may be more 
%         exactly equiripple but will take longer to design.  
%       - A bug in filters which have very short bands in relation to the 
%         filter length is fixed.
%       - Now optionally returns the maximum error, extremal frequencies, 
%         frequency grid, and other results in a RES structure (like cremez).
%   resample
%       - For all combinations of signal length, P, Q, and filter length, the 
%         output length is now exactly ceil(N*P/Q) where N is the input signal
%         length.  For some short signals and filters the length was too 
%         small.
%   sptool
%       - Now works with 0 and 1 length signals and filters.
%       - Allows for non-evenly spaced power spectrum data (imported only).
%       - Minor appearance / layout improvements to buttons, popupmenus, etc.
%       - Now remembers last location of save, export, and import from disk 
%         operations.
%       - Fills in '.mat' when you type in a MAT-file name with no extension
%         when importing from disk into SPTool.
%       - Limits the number of popupmenu items to 24 in the "Selection" area of
%         Signal Browser and Spectrum Viewer.
%       - Saves Preferences on disk only at end of SPTool session.
%
% ----------------------------------------------------------------------------
% README file for the Signal Processing Toolbox.
% Version 4.0  15-Nov-1996
% 
% The README FILE
% This file contains a list of bug fixes, enhancements, and new features in
% the Signal Processing Toolbox since version 3.0.  There is also an important 
% section highlighting changes which might affect the behavior of any m-files
% that you have which use the Toolbox.
% 
% Use help on any of these files for more information.
% 
% BUG FIXES
%   butter, cheby1 - Exact zeros and numerator polynomials for analog case.
%   buttord, cheb1ord, cheb2ord, ellipord - The minimum filter order was 
%     incorrectly overestimated for some bandstop filters.  This has been
%     corrected. 
%   decimate - Uses a lower order Chebyshev anti-aliasing filter in case
%     the default 8th order filter is bogus.  Prevents problems when using
%     very high decimation factors.  See the help for more information.
%   impinvar - The filter is now scaled by 1/Fs.  This causes the magnitude
%     response of the discrete filter to match that of the analog filter.
%   rc2poly - Modified to correctly deal with complex inputs.
%   remez, firls - The coefficients in the differentiator case are now correct
%     so that when applied to a signal the output is the correct sign.
%   remez - The maximum number of iterations was increased from 25 to 250 to 
%     prevent the design of non-equiripple filters.  Also seg faults are now
%     avoided in the case of a large number of bands and a short filter.
% 
% ENHANCEMENTS TO OLD FUNCTIONS
%   cceps - New output parameter for keeping track of rotation applied before
%     FFT, useful in inversion.
%   fftfilt - Support for multiple filters.
%   fir1 - Now works for multiple band filters (in addition to low, high, 
%     band-pass and band-stop filters).  New 'noscale' option to prevent 
%     scaling of response after windowing.
%   firls - No matrix inversion when full band is specified.  This makes the
%     design of these filters much more efficient.
%   levinson - Support has been added for complex inputs, and multiple column 
%     input.
%   lpc - Support has been added for complex and multiple column inputs.  Also, 
%     the gain is now output for the AR estimates.
%   remezord - Cell array output with 'cell' option for convenience.
%   resample - Uses upfirdn and is MUCH faster when q (the decimation factor) 
%     is larger than one.  Also, resample is now vectorized to work on the
%     columns of a signal matrix.
%   specgram - Works on a set of specified frequencies using either czt or 
%     upfirdn.
%   strips - New scaling parameter allows control of the vertical height of
%     the strips. 
%   psd, csd - Chi-squared confidence intervals have been added.
%   xcorr, xcov - Option for computing the correlation at a specified number 
%     of lags.
% 
% NEW FUNCTIONS
%   SIGNAL GENERATION
%     chirp      - Swept-frequency cosine generator.
%     gauspuls   - Gaussian pulse generator.
%     pulstran   - Pulse train generator.
%     rectpuls   - Sampled aperiodic rectangle generator.
%     tripuls    - Sampled aperiodic triangle generator.
%     
%   FILTER DESIGN
%     cremez - FIR filter design which minimizes the complex Chebyshev error
%       to design arbitrary, including non-linear phase and complex, FIR
%       filters.
%     fircls, fircls1 - Constrained Least-Squares algorithm for minimizing
%       LS error subject to maximum ripple constraints. 
%     firrcos - Raised cosine FIR filter design from frequency domain 
%       specifications for communications applications.
%     kaiserord - Order estimation formula for finding the minimum
%       order FIR Kaiser windowed filter to meet a set of frequency
%       domain specifications.
%     maxflat - Maximally flat IIR and symmetric FIR lowpass filter design.
%       Also known as generalized Butterworth filters.  
%   
%   MULTIRATE FILTER BANKS
%     upfirdn - MEX-file implementing upsampling, FIR filtering, and 
%       downsampling using an efficient multirate implementation.
%       Algorithm supports multiple signals and/or multiple filters.
%   
%   LATTICE FILTER SUPPORT
%     latc2tf, tf2latc  - Conversion of lattice (or lattice/ladder) 
%       coefficients to and from transfer function form.
%     latcfilt - Fast MEX implementation of lattice and lattice/ladder filters.
%     
%   SPECTRAL ANALYSIS
%     pmem - PSD estimate using Maximum Entropy method.
%     pmusic - PSD estimate using MUSIC algorithm.
%     pmtm - PSD and confidence intervals using Multiple-taper method.
%     dpss - Discrete Prolate Spheroidal sequences (Slepian sequences).
%     dpsssave, dpssload, dpssdir, dpssclear - DPSS data base for storing
%       long sequences.
% 
%   OTHER
%     icceps - inverse Complex Cepstrum.
%     
% NEW - GRAPHICAL USER INTERFACE (GUI) TOOLS
% 
%   SPTOOL - graphical environment for analyzing and manipulating Signals, 
%     Filters, and Spectra.  You manage and keep track of these objects in 
%     the SPTool figure, and bring up client tools for more detailed 
%     analysis.  The client tools are:
%
%     SIGNAL BROWSER  - Interactive signal browsing allows display, measurement,
%                       and analysis of signals.
%     FILTER VIEWER   - Graphical tool for viewing the magnitude & phase 
%                       response, group delay, zeros & poles, impulse response, 
%                       and step response of a digital filter.
%     FILTER DESIGNER - filter design tool for designing lowpass, highpass, 
%                       bandpass and bandstop filters to meet a frequency 
%                       domain attenuation criterion.
%     SPECTRUM VIEWER - Graphical analysis of frequency domain data using 
%                       different methods of spectral estimation. 
%   
%  ************************************************************************
%  *** WARNING !!! ***
%  The following functions have been fixed or enhanced in a way that might
%  affect your existing code.  
%
%     csd      - default detrending mode changed to 'none'.
%              - confidence intervals have changed.
%     cohere   - default detrending mode changed to 'none'.
%     psd      - default detrending mode changed to 'none'
%              - confidence intervals have changed.
%     tfe      - default detrending mode changed to 'none'.
%     resample - uses upfirdn for efficiency.  The output of this function
%        will differ from previous versions in two cases:
%        i) Zero-order hold.   
%           Previously the output was purely causal, now returns the nearest 
%           sample.
%        ii) Input filter with even filter length.
%           Sometimes would error out.  Now will always work accurately, 
%           but give slightly different output.
%     impinvar - filter now scaled by 1/Fs for correct scaling of magnitude
%                response.
%     remez, firls - differentiators have changed sign - need to remove
%       minus sign from your code where you use this filter.
%
% Use HELP on these files or TYPE them for more information.

%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.33 $  $Date: 1997/12/04 20:59:22 $


  
