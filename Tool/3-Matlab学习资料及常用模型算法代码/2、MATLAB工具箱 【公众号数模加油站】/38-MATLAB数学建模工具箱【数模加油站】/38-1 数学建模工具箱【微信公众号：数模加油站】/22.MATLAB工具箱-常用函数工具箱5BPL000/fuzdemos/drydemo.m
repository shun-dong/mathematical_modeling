function slide=drydemo
% This is a slideshow file for use with playshow.m and makeshow.m
% Too see it run, type 'playshow drydemo', 

% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.2 $
if nargout<1,
  playshow drydemo
else
  %========== Slide 1 ==========

  slide(1).code={
   'a=imread(''dryblock.jpg'', ''jpg'');',
   'image(a); axis image;',
   'axis off;' };
  slide(1).text={
   'This slide show addresses the use of ANFIS function in the Fuzzy Logic Toolbox for nonlinear dynamical system identification. This demo also requires the System Identification Toolbox, as a comparison is made between a nonlinear ANFIS and a linear ARX model.'};

  %========== Slide 2 ==========

  slide(2).code={
   'load dryer2;',
   'data_n = length(y2);',
   'output = y2;',
   'input = [[0; y2(1:data_n-1)]',
	 '[0; 0; y2(1:data_n-2)]',
	 '[0; 0; 0; y2(1:data_n-3)]',
	 '[0; 0; 0; 0; y2(1:data_n-4)]',
	 '[0; u2(1:data_n-1)]',
	 '[0; 0; u2(1:data_n-2)]',
	 '[0; 0; 0; u2(1:data_n-3)]',
	 '[0; 0; 0; 0; u2(1:data_n-4)]',
	 '[0; 0; 0; 0; 0; u2(1:data_n-5)]',
	 '[0; 0; 0; 0; 0; 0; u2(1:data_n-6)]];',
   'data = [input output];',
   'data(1:6, :) = [];',
   'input_name = str2mat(''y(k-1)'',''y(k-2)'',''y(k-3)'',''y(k-4)'',''u(k-1)'',''u(k-2)'',''u(k-3)'',''u(k-4)'',''u(k-5)'',''u(k-6)'');',
   'trn_data_n = 300;',
   'index = 1:100;',
   'subplot(''Position'', [.06 .75 .7 .2]);',
   'plot(index, y2(index), ''-'', index, y2(index), ''o'');',
   'ylabel(''y(k)'');',
   'subplot(''Position'', [.06 .45 .7 .2]);',
   'plot(index, u2(index), ''-'', index, u2(index), ''o'');',
   'ylabel(''u(k)'');',
   '' };
  slide(2).text={
   'The data set for ANFIS and ARX modeling was obtained from a laboratory device called Feedback''s Process Trainer PT 326, as described in Chapter 17 of Prof. Ljung''s book "System Identification".  The device''s function is like a hair dryer: air is fanned through a tube and heated at the inlet. The air temperature is measure by a thermocouple at the outlet. The input u(k) is the voltage over a mesh of resistor wires to heat incoming air; the output y(k) is the outlet air temperature.'};

  %========== Slide 3 ==========

  slide(3).code={
   '' };
  slide(3).text={
   'The data points was collected at a sampling time of 0.08 second. One thousand input-output data points were collected from the process as the input u(k) was chosen to be a binary random signal shifting between 3.41 and 6.41 V. The probability of shifting the input at each sample was 0.2. The data set is available from the System Identification Toolbox; and the above plots show the output temperature y(k) and input voltage u(t) for the first 100 time steps.'};

  %========== Slide 4 ==========

  slide(4).code={
   'dryarx' };
  slide(4).text={
   'A conventional method is to remove the means from the data and assume a linear model of the form: y(k)+a1*y(k-1)+...+am*y(k-m)=b1*u(k-d)+...+bn*u(k-d-n+1), where ai (i = 1 to m) and bj (j = 1 to n) are linear parameters to be determined by least-squares methods. This structure is called the ARX model and it is exactly specified by three integers [m, n, d]. To find an ARX model for the dryer device, the data set was divided into a training (k = 1 to 300) and a checking (k = 301 to 600) set.  An exhaustive search was performed to find the best combination of [m, n, d], where each of the integer is allowed to changed from 1 to 10 independently. The best ARX model thus found is specified by [m, n, d] = [5, 10, 2], with a training RMSE of 0.1122 and a checking RMSE of 0.0749. The above figure demonstrates the fitting results of the best ARX model.'};

  %========== Slide 5 ==========

  slide(5).code={
   '' };
  slide(5).text={
   'The ARX model is inherently linear and the most significant advantage is that we can perform model structure and parameter identification rapidly. The performance in the above plots appear to be satisfactory. However, if a better performance level is desired, we might want to resort to a nonlinear model.  In particular, we are going to use a neuro-fuzzy modeling approach, ANFIS, to see if we can push the performance level by using a fuzzy inference system.' };
 
  %========== Slide 6 ==========

  slide(6).code={
   'trn_data_n = 300;',
   'trn_data = data(1:trn_data_n, :);',
   'chk_data = data(trn_data_n+1:trn_data_n+300, :);',
   '[input_index, elapsed_time]=seqsrch(3, trn_data, chk_data, input_name);',
   'fprintf(''\nElapsed time = %f\n'', elapsed_time);',
   'winH1 = gcf;',
   '' };
  slide(6).text={
   'To use ANFIS for system identification, the first thing we need to do is input selection. That is, to determine which variables should be the input arguments to an ANFIS model.  For simplicity, we suppose that there are 10 input candidates (y(k-1), y(k-2), y(k-3), y(k-4), u(k-1), u(k-2), u(k-3), u(k-4), u(k-5), u(k-6)), and the output to be predicted is y(k). A heuristic approach to input selection is called sequential forward search, in which each input is selected sequentially to optimize the total squared error. This can be done by the function seqsrch; the result is shown in the above plot, where 3 inputs (y(k-1), u(k-3), and u(k-4)) are selected with a training RMSE of 0.0609 and checking RMSE of 0.0604.'};

  %========== Slide 7 ==========

  slide(7).code={
   '' };
  slide(7).text={
   'For input selection, another more computation intensive approach is to do an exhaustive search on all possible combinations of the input candidates. The function that performs exhaustive search is exhsrch, which selects 3 inputs from 10 candidates.  However, exhsrch usually involves a significant amount of computation if all combinations are tried.  For instance, if 3 is selected out of 10, the total number of ANFIS models is C(10, 3) = 120.'};

%========== Slide 8 ==========

  slide(8).code={
   'drypick3;',
   'winH2 = gcf;',
   '' };
  slide(8).text={
   'Fortunately, for dynamical system identification, we do know that the inputs should not come from either of the following two sets of input candidates exclusively:',
   'Y = {y(k-1), y(k-2), y(k-3), y(k-4)}',
   'U = {u(k-1), u(k-2), u(k-3), u(k-4), u(k-5), u(k-6)}',
   'A reasonable guess would be to take two inputs from Y and one from U to form the inputs to ANFIS; the total number of ANFIS models is then C(4,2)*6=36, which is much less.  The above plot shows that the selected inputs are y(k-1), y(k-2) and u(k-3), with a training RMSE of 0.0474 and checking RMSE of 0.0485, which are better than ARX models and ANFIS via sequential forward search.'};

  %========== Slide 9 ==========
  slide(9).code={
   'close(winH1);',
   'close(winH2);',
   'dryperf;',
   '' };
  slide(9).text={
   'The popped window shows ANFIS predictions on both training and checking data sets.  Obviously the performance is better than those of the ARX model.'}; 

  %========== Slide 10 ==========

  slide(10).code={
   'subplot(''Position'', [.06 .45 .7 .4]);',
   'a=imread(''drytable.jpg'', ''jpg'');',
   'image(a); axis image;',
   'axis off;' };
  slide(10).text={
   'The above table is a comparison among various modeling approaches. The ARX modeling spends the least amount of time to reach the worse precision, which the ANFIS modeling via exhaustive search takes the largest amount of time to reach the best percision.  In other words, if fast modeling is the goal, then ARX is the right choice.  But if precision is the utmost concern, then we can go for ANFIS that is designed for nonlinear modeling and higher precision.'};

end
