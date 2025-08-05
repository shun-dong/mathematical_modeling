function slide=mgtsdemo
% This is a slideshow file for use with playshow.m and makeshow.m
% Too see it run, type 'playshow mgtsdemo', 

% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.6 $
if nargout<1,
  playshow mgtsdemo
else
  %========== Slide 1 ==========

  slide(1).code={
   'load mgdata.dat',
   'time = mgdata(:, 1);',
   'ts = mgdata(:, 2);',
   'plot(time, ts);',
   'xlabel(''Time (sec)''); ylabel(''x(t)'');',
   'title(''Mackey-Glass Chaotic Time Series'');' };
  slide(1).text={
   '',
   ' Press the "Start" button to see a demonstration of chaotic',
   ' time series prediction using ANFIS.',
   '',
   ' This demo uses Fuzzy Logic Toolbox functions ANFIS and',
   ' GENFIS1.',
   ''};

  %========== Slide 2 ==========

  slide(2).code={
   '' };
  slide(2).text={
   ' The Mackey-Glass time-delay diff. equation is defined by',
   '',
   ' dx(t)/dt = 0.2x(t-tau)/(1+x(t-tau)^10) - 0.1x(t)',
   '',
   ' When x(0) = 1.2 and tau = 17, we have a non-periodic and',
   ' non-convergent time series that is very sensitive to',
   ' initial conditions. (We assume x(t) = 0 when t < 0.)'};

  %========== Slide 3 ==========

  slide(3).code={
   's=findobj(gcf, ''type'', ''axes'');',
   'delete(s)',
   'axes( ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   '',
   'trn_data = zeros(500, 5);',
   'chk_data = zeros(500, 5);',
   '',
   '% prepare training data',
   'start = 101;',
   'trn_data(:, 1) = ts(start:start+500-1);',
   'start = start + 6;',
   'trn_data(:, 2) = ts(start:start+500-1);',
   'start = start + 6;',
   'trn_data(:, 3) = ts(start:start+500-1);',
   'start = start + 6;',
   'trn_data(:, 4) = ts(start:start+500-1);',
   'start = start + 6;',
   'trn_data(:, 5) = ts(start:start+500-1);',
   '',
   '% prepare checking data',
   'start = 601;',
   'chk_data(:, 1) = ts(start:start+500-1);',
   'start = start + 6;',
   'chk_data(:, 2) = ts(start:start+500-1);',
   'start = start + 6;',
   'chk_data(:, 3) = ts(start:start+500-1);',
   'start = start + 6;',
   'chk_data(:, 4) = ts(start:start+500-1);',
   'start = start + 6;',
   'chk_data(:, 5) = ts(start:start+500-1);',
   '',
   'index = 118:1117+1; % ts starts with t = 0',
   'plot(time(index), ts(index));',
   'axis([min(time(index)) max(time(index)) min(ts(index)) max(ts(index))]);',
   'xlabel(''Time (sec)''); ylabel(''x(t)'');',
   'title(''Mackey-Glass Chaotic Time Series'');',
   '' };
  slide(3).text={
   ' Now we want to build an ANFIS that can predict x(t+6) from',
   ' the past values of this time series, that is, x(t-18), x(t-12),',
   ' x(t-6), and x(t). Therefore the training data format is',
   '          [x(t-18), x(t-12), x(t-6), x(t); x(t+6]',
   ' From t = 118 to 1117, we collect 1000 data pairs of the above',
   ' format. The first 500 are used for training while the others',
   ' are used for checking. The plot shows the segment of the time',
   ' series where data pairs were extracted from.'};

  %========== Slide 4 ==========

  slide(4).code={
   'fismat = genfis1(trn_data);',
   'position(1,:)=[.1 .8 .25 .15];',
   'position(2,:)=[.42.8 .25 .15];',
   'position(3,:)=[.1 .5 .25 .15];',
   'position(4,:)=[.42 .5 .25 .15];',
   '',
   'for input_index=1:4,',
   '    subplot(''Position'', position(input_index, :))',
   '    [x,y]=plotmf(fismat,''input'',input_index);',
   '    plot(x,y)',
   '    axis([-inf inf 0 1.2]);',
   '    xlabel([''Input '' int2str(input_index)]);',
   'end' };
  slide(4).text={
   ' We use GENFIS1 to generate an initial FIS matrix from training',
   ' data. The command is quite simple since default values for',
   ' MF number (2) and MF type (''gbellmf'') are used:',
   '',
   ' >> fismat = genfis1(trn_data);',
   '',
   ' The initial MFs for training are shown in the plots.'};

  %========== Slide 5 ==========

  slide(5).code={
   '' };
  slide(5).text={
   ' There are 2^4 = 16 rules in the generated FIS matrix and the',
   ' number of fitting parameters is 108, including 24 nonlinear',
   ' parameters and 80 linear parameters. This is a proper balance',
   ' between number of fitting parameters and number of training',
   ' data (500). Ten epochs of training take about 4 min. on a SUN',
   ' SPARC II workstation. The ANFIS command looks like this:',
   '',
   ' >> [fismat1, error] = anfis(trn_data, fismat, [], [], chk_data);',
   '',
   ' To save time, we will load the training results directly.'};

  %========== Slide 6 ==========

  slide(6).code={
   '% load training results',
   'load mganfis.mat',
   '',
   '% plot final MF''s on x, y, z, u',
   'for input_index=1:4,',
   '    subplot(''Position'', position(input_index,:))',
   '    [x,y]=plotmf(trn_out_fismat,''input'',input_index);',
   '    plot(x,y)',
   '    axis([-inf inf 0 1.2]);',
   '    xlabel([''Input '' int2str(input_index)]);',
   'end' };
  slide(6).text={
   ' After ten epochs of training, the final MFs are shown in the',
   ' plots. Note that these MFs after training do not change',
   ' drastically. Obviously most of the fitting is done by the linear',
   ' parameters while the nonlinear parameters are mostly for fine-',
   ' tuning for further improvement.',
   '',
   ' Press "Next" to see error curve plot.'};

  %========== Slide 7 ==========

  slide(7).code={
   's=findobj(gcf, ''type'', ''axes'');',
   'delete(s)',
   'axes( ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   '',
   '% error curves plot',
   'epoch_n = 10;',
   'tmp = [trn_error chk_error];',
   'plot(tmp);',
   'hold on; plot(tmp, ''o''); hold off;',
   'xlabel(''Epochs'');',
   'ylabel(''RMSE (Root Mean Squared Error)'');',
   'title(''Error Curves'');',
   'axis([0 epoch_n min(tmp(:)) max(tmp(:))]);',
   '' };
  slide(7).text={
   ' This plot displays error curves for both training and',
   ' checking data. Note that the training error is higher than the',
   ' checking error. This phenomenon is not uncommon in ANFIS',
   ' learning or nonlinear regression in general; it could indicate',
   ' that the training process is not close to finished yet.',
   '',
   ' Press "Next" to see comparisons.'};

  %========== Slide 8 ==========

  slide(8).code={
   'input = [trn_data(:, 1:4); chk_data(:, 1:4)];',
   'anfis_output = evalfis(input, trn_out_fismat);',
   'index = 125:1124;',
   'plot(time(index), [ts(index) anfis_output]);',
   'set(gca, ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   'xlabel(''Time (sec)'');',
      };
  slide(8).text={
   ' This plot shows the original time series and the one predicted',
   ' by ANFIS. The difference is so tiny that it is impossible to tell',
   ' one from another by eye inspection. That is why you probably',
   ' see only the ANFIS prediction curve. The prediction errors',
   ' must be viewed on another scale.',
   '',
   ' Press "Next" to view prediction errors of ANFIS.'};

  %========== Slide 9 ==========

  slide(9).code={
   's=findobj(gcf, ''type'',  ''axes'');',
   'delete(s)',
   '',
   'diff = ts(index)-anfis_output;',
   ' % to get rid of previous lengend',
   'plot(time(index), diff);',
   'set(gca, ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   'xlabel(''Time (sec)'');',
   'title(''ANFIS Prediction Errors'');',
   '' };
  slide(9).text={
   ' Prediction error of ANFIS is shown here. Note that the scale',
   ' is about a hundredth of the scale of the previous plot.',
   ' Remember that we have only 10 epochs of training in this case;',
   ' better performance is expected if we have extensive training.'};
end
