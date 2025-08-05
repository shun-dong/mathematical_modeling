function tbxStruct=Demos
% DEMOS Demo list for the Fuzzy Logic toolbox

% Kelly Liu, 8-6-96
% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 1997/12/12 20:35:47 $

if nargout==0, demo toolbox; return; end

tbxStruct.Name='Fuzzy Logic';
tbxStruct.Type='toolbox';

tbxStruct.Help= {
         ' The Fuzzy Logic Toolbox contains comprehensive '  
         ' tools to help you do automatic control, signal '  
         ' processing, system identification, pattern     '  
         ' recognition, time series prediction, data      '
	 ' mining, and financial applications.            '
	 '                                                '};
tbxStruct.DemoList={
         'Fuzzy C-Means', 'fcmdemo', '',
	 'Noise Cancellation','noisedm', '',
	 'Time-Series Prediction', 'mgtsdemo', '',
         'Gas mileage prediction', 'gasdemo', '',
	 'Subtractive Clustering', 'trips', '',
	 'Ball Juggler','juggler', '',
	 'Inverse Kinematics', 'invkine', '',
	 'Defuzzification', 'defuzzdm', '',
	 'MF gallery', 'mfdemo', '',
         'Water tank', 'sltank', 'SIMULINK',
         'Water tank with rule viewer', 'sltankrule', 'SIMULINK',
         'Cart and pole', 'slcp1', 'SIMULINK',
	 'Cart and two poles ', 'slcpp1', 'SIMULINK', 
	 'Ball and beam', 'slbb', 'SIMULINK',
	 'Backing truck', 'sltbu', 'SIMULINK',
         'Shower model', 'shower', 'SIMULINK'};


