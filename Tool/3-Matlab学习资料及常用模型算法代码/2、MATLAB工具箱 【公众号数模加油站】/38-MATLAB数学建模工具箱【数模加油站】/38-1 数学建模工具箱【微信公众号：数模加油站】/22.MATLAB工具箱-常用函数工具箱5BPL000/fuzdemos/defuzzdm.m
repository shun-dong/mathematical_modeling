function defuzzdm
%DEFUZZDM Defuzzification methods.
%   DEFUZZDM displays five defuzzification methods supported in the
%   Fuzzy Logic Toolbox.
%
%       See also DEFUZZ.

%   Roger Jang, 10-28-93, 9-29-94.
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 1997/12/01 21:44:10 $

FigTitle = 'Defuzzification Methods';
fig = findobj(0,'Name',FigTitle);

if isempty(fig),
    fig = figure('Unit','pixel',...
        'Name',FigTitle,...
        'NumberTitle','off');
%%%%    set(0,'Current',fig)
end

x = -10:0.1:10;
offset = 0.03;

mf1 = trapmf(x, [-10, -8, -2, 2]);
mf2 = trapmf(x, [-5, -3, 2, 4]);
mf3 = trapmf(x, [2, 3, 8, 9]);
mf1 = max(0.5*mf2, max(0.9*mf1,0.1*mf3));

lineColor=[0 0 1];
lineStyle=':';
dotColor=[0 0 1];
set(fig,'DefaultTextFontWeight','bold','DefaultTextColor','k')
axColor=[.4 .4 .4];
set(fig,'Color',[1 1 1],'DefaultAxesXColor',axColor,'DefaultAxesYColor',axColor)

subplot(211);
plot(x, mf1,'LineWidth',3);
patch(x,mf1,'y')
set(gca,'XLim',[min(x) max(x)],'YLim',[0 1.2],'Color',[.9 .9 .9]);

hold on;

x1 =  defuzz(x, mf1, 'centroid');
plot([x1 x1], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x1, 0.8, 'Color',dotColor,'Marker','.','MarkerSize',20);
x2 =  defuzz(x, mf1, 'bisector');
plot([x2 x2], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x2, 0.6, 'Color',dotColor,'Marker','.','MarkerSize',20);
x3 =  defuzz(x, mf1, 'mom');
plot([x3 x3], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x3, 0.4, 'Color',dotColor,'Marker','.','MarkerSize',20);
x4 =  defuzz(x, mf1, 'som');
plot([x4 x4], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x4, 0.2, 'Color',dotColor,'Marker','.','MarkerSize',20);
x5 =  defuzz(x, mf1, 'lom');
plot([x5 x5], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x5, 0.2, 'Color',dotColor,'Marker','.','MarkerSize',20);

text(x1, 0.8-offset, 'centroid', 'hor', 'center', 'ver', 'top');
text(x2, 0.6-offset, 'bisector', 'hor', 'center', 'ver', 'top');
text(x3, 0.4-offset, 'mom', 'hor', 'center', 'ver', 'top');
text(x4, 0.2-offset, 'som', 'hor', 'center', 'ver', 'top');
text(x5, 0.2-offset, 'lom', 'hor', 'center', 'ver', 'top');
hold off

subplot(212);
mf1=fliplr(mf1);
plot(x, mf1,'LineWidth',3);
patch(x,mf1,'y')
set(gca,'XLim',[min(x) max(x)],'YLim',[0 1.2],'Color',[.9 .9 .9]);

hold on;

x1 =  defuzz(x, mf1, 'centroid');
plot([x1 x1], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x1, 0.8, 'Color',dotColor,'Marker','.','MarkerSize',20);
x2 =  defuzz(x, mf1, 'bisector');
plot([x2 x2], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x2, 0.6, 'Color',dotColor,'Marker','.','MarkerSize',20);
x3 =  defuzz(x, mf1, 'mom');
plot([x3 x3], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x3, 0.4, 'Color',dotColor,'Marker','.','MarkerSize',20);
x4 =  defuzz(x, mf1, 'som');
plot([x4 x4], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x4, 0.2, 'Color',dotColor,'Marker','.','MarkerSize',20);
x5 =  defuzz(x, mf1, 'lom');
plot([x5 x5], [0 1.2], 'Color',lineColor,'LineStyle',lineStyle); 
plot(x5, 0.2, 'Color',dotColor,'Marker','.','MarkerSize',20);

text(x1, 0.8-offset, 'centroid', 'hor', 'center', 'ver', 'top');
text(x2, 0.6-offset, 'bisector', 'hor', 'center', 'ver', 'top');
text(x3, 0.4-offset, 'mom', 'hor', 'center', 'ver', 'top');
text(x4, 0.2-offset, 'som', 'hor', 'center', 'ver', 'top');
text(x5, 0.2-offset, 'lom', 'hor', 'center', 'ver', 'top');
hold off
