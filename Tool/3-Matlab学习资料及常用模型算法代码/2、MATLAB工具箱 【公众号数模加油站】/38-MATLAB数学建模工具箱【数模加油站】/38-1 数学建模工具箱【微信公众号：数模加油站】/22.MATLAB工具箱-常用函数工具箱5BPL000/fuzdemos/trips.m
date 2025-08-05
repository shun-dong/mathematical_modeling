function slide=trips
% This is a slideshow file for use with playshow.m and makeshow.m
% Too see it run, type 'playshow trips', 

% Copyright (c) 1994-98 by The MathWorks, Inc.
% $Revision: 1.5 $
if nargout<1,
  playshow trips
else
  %========== Slide 1 ==========

  slide(1).code={
   '    tripdata',
   '    plot(datin)' };
  slide(1).text={
   ' Press the "Start" button to see a demonstration of',
   ' subtractive clustering and how it can be used with',
   ' multi-dimensional data.'};

  %========== Slide 2 ==========

  slide(2).code={
   'h=findobj(gcf, ''type'', ''axes'');',
   'delete(h)',
   'set(gca, ''Units'',''normalized'', ''Position'',[0.075 0.47 0.65 0.45])',
   'plot(datin)' };


  slide(2).text={
   ' This is a plot of the input data for a model identification',
   ' problem. We are interested in estimating the number',
   ' of auto trips generated from an area based on the area''s',
   ' demographics. Five factors were considered: population,',
   ' number of houses, vehicle ownership, income, and employment.',
   '',
   ' >> tripdata',
   ' >> plot(datin)'};

  %========== Slide 3 ==========

  slide(3).code={
   'watchon;',
   'a=genfis2(datin,datout,0.45);',
   'axisHndl=gca;',
   'axes( ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   '',
   'plotfis(a);',
   'watchoff;' };
  slide(3).text={
   ' Using the GENFIS2 function (which is based on the',
   ' subtractive clustering algorithm in the SUBCLUST function),',
   ' we generate a fuzzy inference system that calculates the',
   ' output based on the five inputs.',
   '',
   ' >> a = genfis2(datin,datout,0.45);',
   ' >> plotfis(a);'};

  %========== Slide 4 ==========

  slide(4).code={
   'axisHndlList=findobj(gcf,''Type'',''axes'');',
   'axisHndlList(find(axisHndlList==axisHndl))=[];',
   'delete(axisHndlList);',
   '',
   'fuzout=evalfis(datin,a);',
   'subplot(''Position'', [.06 .75 .7 .2]), plot(datin)',
   'subplot(''Position'', [.06 .45 .7 .2]), plot([datout fuzout])',
   '' };
  slide(4).text={
   ' The upper plot displays 75 data points for the five input',
   ' variables. The lower plot displays the corresponding outputs',
   ' and the outputs predicted by the fuzzy model.',
   '',
   ' >> fuzout=evalfis(datin,a);',
   ' >> subplot(2,1,1), plot(datin)',
   ' >> subplot(2,1,2), plot([datout fuzout])'};

  %========== Slide 5 ==========

  slide(5).code={
   's=findobj(gcf, ''type'', ''axes'');',
   'delete(s)',
   'axes( ''Units'',''normalized'', ''Position'',[0.10 0.47 0.65 0.45]);',
   'plot(datout,fuzout,''bx'',[0 10],[0 10],''r:'')',
   'axis square',
   'xlabel(''Actual Value'')',
   'ylabel(''Predicted Value'')' };
  slide(5).text={
   ' Here is a plot of the actual output values (X axis) versus the',
   ' predicted output values (Y axis). If the prediction were a',
   ' perfect one, the data points would lie right along the diagonal',
   ' line X = Y.',
   '',
   ' >> plot(datout,fuzout,''yx'',[0 10],[0 10],''c:'')',
   ' >> xlabel(''Actual Value'')',
   ' >> ylabel(''Predicted Value'')'};

  %========== Slide 6 ==========

  slide(6).code={
   'chkfuzout=evalfis(chkdatin,a);',
   'plot(chkdatout,chkfuzout,''bx'',[0 10],[0 10],''r:'')',
   'axis square',
   'xlabel(''Actual Value'')',
   'ylabel(''Predicted Value'')' };
  slide(6).text={
   ' We set aside 25 of the original 100 data points as checking',
   ' data. Since we did not use this data to create our model, it',
   ' is a useful measure of how good our model is.',
   '',
   ' >> chkfuzout=evalfis(chkdatin,a);',
   ' >> plot(chkdatout,chkfuzout,''yx'',[0 10],[0 10],''c:'')',
   ' >> xlabel(''Actual Value'')',
   ' >> ylabel(''Predicted Value'')'};

  %========== Slide 7 ==========

  slide(7).code={
   '' };
  slide(7).text={
   ' Clustering can be a very effective technique for dealing with',
   ' large sets of data: the principal idea is to distill natural',
   ' groupings of data from a large data set thereby allowing',
   ' concise representation of a model''s behavior. This demo has',
   ' shown how accurate predictions can be made despite the',
   ' multi-dimensional nature of the problem.   With the results of this',
   ' clustering experiment in hand, we  could now potentially go on',
   ' to use other techniques, such  as ANFIS.'};
end
