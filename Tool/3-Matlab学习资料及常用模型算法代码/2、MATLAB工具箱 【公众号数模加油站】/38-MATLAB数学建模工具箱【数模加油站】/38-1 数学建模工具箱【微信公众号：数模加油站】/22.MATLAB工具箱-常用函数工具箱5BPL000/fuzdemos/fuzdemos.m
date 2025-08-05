function fuzdemos(action)
%FUZDEMOS List of all Fuzzy Logic Toolbox demos.
%   The command FUZDEMOS by itself will open a figure window
%   with buttons corresponding to each demo. To see a demo,
%   press a button.
%
%   Demos include the pole and cart demo, the truck backing demo, 
%   fuzzy c-means clustering, and others.

%   Kelly Liu, 10-24-97
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 1997/12/12 20:36:37 $

if nargin<1,

   action='#initialize';
end

switch action,
 case'#initialize',

labelList=[ ...
    'ANFIS: Noise cancellation                    '
    'ANFIS: Time-series prediction                '
    'ANFIS: Gas mileliage prediction              '
    'Fuzzy c-means clustering                     '
    'Subtractive clustering                       '
    'Ball juggler                                 '
    'Inverse kinematics                           '
    'Defuzzification                              '
    'Membership function gallery                  '];

nameList=[ ...
    'noisedm         '
    'mgtsdemo        '
    'gasdemo         '
    'fcmdemo         '
    'trips           '
    'juggler         '
    'invkine         '
    'defuzzdm        '
    'mfdemo          '];

% Add SIMULINK demos if SIMULINK is available
if exist('open_system')==5,
    labelList2=[ ...
    'Water Tank (sim)                '
    'Water Tank with Rule View (sim) '
    'Cart and pole (sim)             '
    'Cart and two poles (sim)        '
    'Ball and beam (sim)             '
    'Backing truck (sim)             '];
    labelList=str2mat(labelList,labelList2);
    nameList2=[ ...
    'sltank     '
    'sltankrule '
    'slcp1      '
    'slcpp1     '
    'slbb       '
    'sltbu      '];
    nameList=str2mat(nameList,nameList2);
end


figNum=figure('name', 'Fuzzy Logic Toolbox Demos',...
              'NumberTitle','off', ...
              'Units', 'pixel', 'Position', [240 318 340 504]);
set(figNum, 'Userdata', nameList);
listHndl=uicontrol(figNum, 'Style', 'listbox', 'Position', [20 120 300 350],...
                   'String', labelList,  ...
                   'Tag', 'listbox');
uicontrol(figNum, 'Style', 'pushbutton', 'String', 'Run this demo',...
                  'Position', [20, 60, 300, 30], 'Callback', 'fuzdemos #rundemo'); 
uicontrol(figNum, 'Style', 'pushbutton', 'String', 'Close',...
                  'Position', [20, 20, 300, 30], 'Callback', 'close(gcbf)'); 
case '#rundemo'
 nameList=get(gcbf, 'Userdata');
 listHndl=findobj(gcbf, 'Tag', 'listbox');
 index=get(listHndl, 'Value');
 eval(deblank(nameList(index,:)));
end

