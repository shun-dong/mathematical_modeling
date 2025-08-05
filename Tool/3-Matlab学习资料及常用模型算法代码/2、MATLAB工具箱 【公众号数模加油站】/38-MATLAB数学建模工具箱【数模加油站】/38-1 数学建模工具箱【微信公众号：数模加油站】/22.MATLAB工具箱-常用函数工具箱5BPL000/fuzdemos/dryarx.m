% This script requires the System Identification Toolbox from the MathWorks
% Roger Jang, Aug-10-96
% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.2 $

trn_data_n = 300;
%total_data_n = 1000;
total_data_n = 600;

if exist('arxstruc') == 2,
	load dryer2
	z = [y2 u2];
	z = dtrend(z);
	ave = mean(y2);
	ze = z(1:trn_data_n, :);
	zv = z(trn_data_n+1:total_data_n, :);
	T = 0.08;
	
	% Run through all different models
	tic
	V = arxstruc(ze, zv, struc(1:10, 1:10, 1:10));
	toc
	% Find the best model
	nn = selstruc(V, 0);
	% Plot loss fcn w.r.t. models
	% nn = selstruc(V);
	
	%nn = [2 2 3];
	% Time domain plot
	th = arx(ze, nn);
	th = sett(th, 0.08);
	u = z(:, 2);
	y = z(:, 1)+ave;
	yp = idsim(u, th)+ave;
	%save drydemo y yp nn
else
	load drydemo y yp nn
end

figTitle = 'ARX modeling for dryer device data';
figH = findobj(0, 'name', figTitle);
if isempty(figH),
	figH = figure('Name', figTitle, 'NumberTitle', 'off');
else
	set(0, 'currentfig', figH);
end

subplot(2,1,1); index = 1:trn_data_n;
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(a) Training Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
disp(['[na nb d] = ' num2str(nn)]);
xlabel('Time Steps');

subplot(2,1,2); index = (trn_data_n+1):(total_data_n);
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(b) Checking Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Steps');
