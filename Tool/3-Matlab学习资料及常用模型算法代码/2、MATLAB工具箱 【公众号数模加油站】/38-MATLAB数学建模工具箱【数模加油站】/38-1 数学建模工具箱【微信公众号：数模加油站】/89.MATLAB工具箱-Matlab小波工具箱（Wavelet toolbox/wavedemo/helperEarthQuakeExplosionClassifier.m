function [WavPacketCluster,WtCluster,PspecCluster] = helperEarthQuakeExplosionClassifier(Data,Level)  
%   This function is provided solely in support of the featured example
%   waveletpacketsdemo.m. 
%   This function may be changed or removed in a future release.
%   Data - The data matrix with individual time series as column vectors.
%   Level - The level of the wavelet packet and wavelet transforms

NP = 2^Level;
NW = Level+1;
WpMatrix = zeros(16,NP);
WtMatrix = zeros(16,NW);

for jj = 1:8
    [~,~,~,~,RE] = modwpt(Data(:,jj),Level,'fk6');
    wt = modwt(Data(:,jj),Level,'fk6');
    WtMatrix(jj,:) = sum(abs(wt).^2,2)./norm(Data(:,jj),2)^2;
    WpMatrix(jj,:) = RE;
end

for kk = 9:16
    [~,~,~,~,RE] = modwpt(Data(:,kk),Level,'fk6');
    wt = modwt(Data(:,kk),Level,'fk6');
    WtMatrix(kk,:) = sum(abs(wt).^2,2)./norm(Data(:,kk),2)^2;
    WpMatrix(kk,:) = RE;
end

% For repeatability
rng('default');

WavPacketCluster = evalclusters(WpMatrix,'kmeans','gap','KList',1:6,...
    'Distance','cityblock');

WtCluster = evalclusters(WtMatrix,'kmeans','gap','KList',1:6,...
'Distance','cityblock');

Pxx = periodogram(Data,hamming(numel(Data(:,1))),[],1,'power');

PspecCluster = evalclusters(Pxx','kmeans','gap','KList',1:6,...
    'Distance','cityblock');



