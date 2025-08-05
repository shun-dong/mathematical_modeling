%% Wavelet Packets: Decomposing the Details
% This example shows how wavelet packets differ from the discrete wavelet
% transform (DWT). The example shows how the wavelet packet transform
% results in equal-width subband filtering of signals as opposed to the
% coarser octave band filtering found in the DWT.
%
% This makes wavelet packets an attracive alternative to the  DWT in a
% number of applications. Two examples presented here are time-frequency
% analysis and signal classification.
%
% If you use an orthogonal wavelet with the wavelet packet transform, you
% additionally end up with a partioning of the signal energy among the
% equal-width subbands.
%
% The example focuses on the 1-D case, but many of the concepts extend
% directly to the wavelet packet transform of images.
%% Discrete Wavelet and Discrete Wavelet Packet Transforms
% The following figure shows a DWT tree for a 1-D input signal.
%
% <<wv_tree.png>>
%
% *Figure 1:* DWT Tree down to level 3 for a 1-D input signal.
% $\tilde{G}(f)$ is the scaling (lowpass) analysis filter and
% $\tilde{H}(f)$ represents the wavelet (highpass) analysis filter. The
% labels at the bottom show the partition of the frequency axis [0,1/2]
% into subbands.
%
% The figure shows that subsequent levels of the DWT operate only on the
% outputs of the lowpass (scaling) filter. At each level, the DWT divides
% the signal into octave bands. In the critically-sampled DWT, the outputs
% of the bandpass filters are downsampled by two at each level. In the
% undecimated discrete wavelet transform, the outputs are not dowsampled.
%
% Compare the DWT tree with the full wavelet packet tree.
%
% <<modwpt_nat_order.png>>
%
% *Figure 2:* Full wavelet packet tree down to level 3.
%
% In the wavelet packet transform, the filtering operations are also
% applied to the wavelet, or detail, coefficients. The result is that
% wavelet packets provide a subband filtering of the input signal into
% progressively finer equal-width intervals. At each level, $j$, the
% frequency axis [0,1/2] is divided into $2^j$ subbands. The subbands in
% hertz at level j are approximately
%
% $[ \frac{n \mathrm{Fs}}{2^{j+1}}, \frac{(n+1) \mathrm{Fs}}{2^{j+1}}) \quad n=0,1,\ldots 2^j-1$
% where Fs is the sampling frequency.
% 
%
% How good this bandpass approximation is depends on how
% frequency-localized the filters are. For Fejer-Korovkin filters like
% 'fk18' (18 coefficients), the approximation is quite good. For a filter
% like the Haar ('haar'), the approximation is not accurate.
%
%
% In the critically-sampled wavelet packet transform the outputs of the
% bandpass filters are downsampled by two. In the undecimated wavelet
% packet transform, the outputs are not downsampled.

%% Time-Frequency Analysis with Wavelet Packets
% Because wavelet packets divide the frequency axis into finer intervals
% than the DWT, wavelet packets are superior at time-frequency analysis.
% As an example, consider two intermittent sine waves with frequencies of
% 150 and 200 Hz in additive noise. The data are sampled at 1 kHz. To
% prevent the loss of time resolution inherent in the critically-sampled
% wavelet packet transform, use the undecimated transform.

dt = 0.001;
t = 0:dt:1-dt;
x = ...
cos(2*pi*150*t).*(t>=0.2 & t<0.4)+sin(2*pi*200*t).*(t>0.6 & t<0.9);
y = x+0.05*randn(size(t));
[wpt,~,F] = modwpt(x,'TimeAlign',true);
contour(t,F.*(1/dt),abs(wpt).^2); grid on;
xlabel('Time (secs)'); ylabel('Hz');
title('Time-Frequency Analysis -- Undecimated Wavelet Packet Transform');
%%
% Note that the wavelet packet transform is able to separate the 150 and
% 200 Hz components. This is not true of the DWT, because 150 and 200 Hz 
% fall in the same octave band. The octave bands for a level-four DWT are 
% (in Hz)
% 
% * [0,31.25)
% * [31.25,62.5)
% * [62.5,125)
% * [125,250)
% * [250,500)
%
% Demonstrate that these two components are time-localized by the DWT but
% not separated in frequency.
mra  = modwtmra(modwt(y,'fk18',4),'fk18');
J = 5:-1:1;
freq = 1/2*(1000./2.^J);
contour(t,freq,flipud(abs(mra).^2));
grid on;
ylim([0 500])
xlabel('Time (secs)'); ylabel('Hz');
title('Time-Frequency Analysis -- Undecimated Wavelet Transform');


%%
% Of course, the continuous wavelet transform (CWT) provides a higher
% resolution time-frequency analysis than the wavelet packet transform, but
% wavelet packets have the added benefit of being an orthogonal transform
% (when using an orthogonal wavelet). An orthogonal transform means that
% the energy in the signal is preserved and partitioned among the
% coefficients as the next section demonstrates.

%% Energy Preservation in the Wavelet Packet Transform
% In addition to filtering a signal into equal-width subbands at each
% level, the wavelet packet transform partitions the signal's energy among
% the subbands. This is true for both the decimated and undecimated wavelet
% packet transforms. To demonstrate this, load a dataset containing a
% seismic recording of an earthquake. This data is similar to the time
% series used in the signal classification example below.
load kobe;
plot(kobe)
grid on;
xlabel('Seconds');
title('Kobe Earthquake Data');
%%
% Obtain both the decimated and undecimated wavelet packet transforms of
% the data down to level 3. To ensure consistent results for the decimated
% wavelet packet transform, the example sets the |dwtmode| to periodization
% and returns it to your original setting at the end of the example. 

st = dwtmode('status','nodisplay');
dwtmode('per','nodisplay');
wptreeDecimated = wpdec(kobe,3,'fk18');
wptUndecimated = modwpt(kobe,3); 
%%
% First, extract all the wavelet packet coefficients at level three for the 
% decimated transform.

wpcfs = zeros(8,381);
for kk = 7:14
wpcfs(kk-6,:) = wpcoef(wptreeDecimated,kk);
end
%%
% Now compute the total energy in both the decimated and undecimated
% wavelet packet level-three coefficients and compare to the energy in the
% original signal.

decimatedEnergy = sum(sum(abs(wpcfs).^2,2))
undecimatedEnergy = sum(sum(abs(wptUndecimated).^2,2))
signalEnergy = norm(kobe,2)^2
%%
% The DWT shares this important property with the wavelet packet transform.
wt = modwt(kobe,'fk18',3);
undecimatedWTEnergy = sum(sum(abs(wt).^2,2))
%%
% Because the wavelet packet transform at each level divides the frequency
% axis into equal-width intervals and partitions the signal energy among
% those intervals, you can often construct useful feature vectors for
% classification just by retaining the relative energy in each wavelet
% packet. The next example demonstrates this.
%% Wavelet Packet Classification -- Earthquake or Explosion?
% Seismic recordings pick up activity from many sources. It is important to
% be able to classify this activity based on its origin. For example,
% earthquakes and explosions may present similar time-domain signatures,
% but it is very important to differentiate between these two events. The
% dataset |EarthQuakeExplosionData| contains 16 recordings with 2048
% samples. The first 8 recordings (columns) are seismic recordings of
% earthquakes, the last 8 recordings (columns) are seismic recordings of
% explosions. Load the data and plot an earthquake and explosion recording
% for comparison. The data is taken from the R package astsa Stoffer
% (2014), which supplements Shumway and Stoffer (2011). The author has
% kindly allowed its use in this example.
%
% Plot a time series from each group for comparison.

load EarthQuakeExplosionData;
subplot(2,1,1)
plot(EarthQuakeExplosionData(:,3));
xlabel('Time'); title('Earthquake Recording');
grid on;
subplot(2,1,2);
plot(EarthQuakeExplosionData(:,9));
xlabel('Time'); title('Explosion Recording');
grid on;
%%
% Form a wavelet packet feature vector by decomposing each time series down
% to level three using the 'fk6' wavelet with an undecimated wavelet packet
% transform. This results in 8 subbands with an approximate width of 1/16
% cycles/sample. Use the relative energy in each subband to create a
% feature vector. As an example, obtain a wavelet packet relative energy
% feature vector for the first earthquake recording.

[wpt,~,F,E,RE] = modwpt(EarthQuakeExplosionData(:,1),3,'fk6');
%%
% RE contains the relative energy in each of the 8 subbands. If you sum all
% the elements in RE, it is equal to 1. Note that this is a significant
% reduction in data. A time series of length 2048 is reduced to a vector
% with 8 elements, each element representing the relative energy in the
% wavelet packet nodes at level 3. The helper function
% |helperEarthQuakeExplosionClassifier| obtains the relative energies for
% each of the 16 recordings at level 3 using the 'fk6' wavelet. This
% results in a 16-by-8 matrix and uses these feature vectors as inputs to a
% kmeans classifier. The classifier uses the Gap statistic criterion to
% determine the optimal number of clusters for the feature vectors between
% 1 and 6 and classifies each vector. Additionally, the classifier performs
% the exact same classification on the undecimated wavelet transform
% coefficients at level 3 obtained with the 'fk6' wavelet and power spectra
% for each of the time series. The undecimated wavelet transform results in
% a 16-by-4 matrix (3 wavelet subbands and 1 scaling subband). The power
% spectra result in a 16-by-1025 matrix. You must have the Statistics and
% Machine Learning Toolbox(TM) and the Signal Processing Toolbox(TM) to run
% the classifier.

Level = 3;
[WavPacketCluster,WtCluster,PspecCluster] = ...
helperEarthQuakeExplosionClassifier(EarthQuakeExplosionData,Level)
dwtmode(st,'nodisplay');
%%
% |WavPacketCluster| is the clustering output for the undecimated wavelet
% packet feature vectors. |WtCluster| is the clustering output using the
% undecimated DWT feature vectors, and |PspecCluster| is the output for the
% clustering based on the power spectra. The wavelet packet classification
% has identified two clusters (|OptimalK: 2|) as the optimal number.
% Examine the results of the wavelet packet clustering.

WavPacketCluster.OptimalY
%%
% You see that only two errors have been made. Of the eight earthquake
% recordings, seven are classified together (group 2) and one is mistakenly
% classified as belonging to group 1. The same is true of the 8 explosion
% recordings -- 7 are classified together and 1 is misclassified.
% Classification based on the level-three undecimated DWT and power spectra
% return one cluster as the optimal solution.
%
% If you repeat the above with the level equal to 4, the undecimated
% wavelet transform and wavelet packet transform perform identically with
% both identifying two clusters as optimal and missclassifying one time
% series (the same two time series) in each group.

%% Conclusions
% In this example, you learned how the wavelet packet transform differs
% from the discrete wavelet transform. Specifically, the wavelet packet
% tree also filters the wavelet (detail) coefficients, while the wavelet
% transform only iterates on the scaling (approximation) coefficients.
%
% You learned that the wavelet packet transform shares the important
% energy-preserving property of the DWT while providing superior frequency
% resolution. In some applications, this superior frequency resolution
% makes the wavelet packet transform an attractive alternative to the DWT.
%% References
% Wickerhauser, M.V. "Adapted wavelet analysis from theory to software."
% IEEE Press, 1994.
%
% Percival, D.B. and Walden, A.T. "Wavelet methods for time series
% analysis". Cambridge University Press, 2000.
%
% Shumway, R.H. and Stoffer, D.H. "Time series analysis and its
% applications with R examples." Springer, 2011.
%
% Stoffer, D.H. "astsa: Applied Statistical Time Series Analysis." R
% package version 1.3. http://CRAN.R-project.org/package=astsa , 2014.
%% Appendix
% The following helper function is used in this example:
%
% * <matlab:edit('helperEarthQuakeExplosionClassifier') helperEarthQuakeExplosionClassifier>
displayEndOfDemoMessage(mfilename)

