%drydata;
% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.2 $

%data(601:size(data,1), :) = [];
%input_index = [1 7 8];		% obtain from drypick.m
%input_index = [1 2 7];		% obtain from drypick3.m

ss = 0.01;
ss_dec_rate = 0.5;
ss_inc_rate = 1.5;

trn_data = data(1:trn_data_n, [input_index, size(data,2)]);
chk_data = data(trn_data_n+1:600, [input_index, size(data,2)]);

% generate FIS matrix
in_fismat = genfis1(trn_data);

[trn_out_fismat trn_error step_size chk_out_fismat chk_error] = ...
	anfis(trn_data, in_fismat, [1 nan ss ss_dec_rate ss_inc_rate], ...
	nan, chk_data, 1);

% Display the result
figTitle = 'ANFIS modeling for dryer device data';
figH = findobj(0, 'name', figTitle);
if isempty(figH),
	figH = figure('Name', figTitle, 'NumberTitle', 'off');
else
	set(0, 'currentfig', figH);
end

subplot('Position', [.06 .75 .7 .2]);
index = 1:trn_data_n;
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(a) Training Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
disp(['[na nb d] = ' num2str(nn)]);
xlabel('Time Steps');
subplot('Position', [.06 .45 .7 .2]);
index = (trn_data_n+1):(total_data_n);
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(b) Checking Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Steps');

y_hat = evalfis(data(1:600,input_index), chk_out_fismat);

subplot('Position', [.06 .75 .7 .2]);
index = 1:trn_data_n;
plot(index, data(index, size(data,2)), '-', ...
     index, y_hat(index), '.');
rmse = norm(y_hat(index)-data(index,size(data,2)))/sqrt(length(index));
title(['Training Data (Solid Line) and ANFIS Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Index'); ylabel('');

subplot('Position', [.06 .45 .7 .2]);
index = trn_data_n+1:600;
plot(index, data(index, size(data,2)), '-', index, y_hat(index), '.');
rmse = norm(y_hat(index)-data(index,size(data,2)))/sqrt(length(index));
title(['Checking Data (Solid Line) and ANFIS Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Index'); ylabel('');
