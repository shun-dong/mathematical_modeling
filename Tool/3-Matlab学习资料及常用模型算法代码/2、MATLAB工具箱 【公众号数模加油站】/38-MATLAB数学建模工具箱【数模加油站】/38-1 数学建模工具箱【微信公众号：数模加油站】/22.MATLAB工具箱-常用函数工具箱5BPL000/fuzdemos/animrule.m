function [sys, x0] = animrule(t, x, u, flag, fismatrix)
%ANIMRULE call fuzzy rule viewer during simulation.
%   Animation of fuzzy rules during simulation. This function calls ruleview 
%   during simulation to show how rules are fired. 
%
%   Animation S-function: animrule.m
%   SIMULINK file: fuzblkrule.mdl 
%
%   Type sltankrule in MATLAB command line to see a demo.

%   Kelly Liu 10-6-97
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 1997/12/01 21:44:03 $



if ~isempty(flag) & flag == 2,
    xx=allchild(0);
    figN=[];
    for i=1:length(xx)
       name=get(xx(i), 'name');
       if length(name)>11 & strcmp(name(1:12), 'Rule Viewer:');
          figN=xx(i);
          break;
       end
    end
    if ~isempty(figN)
      set(figN, 'HandleVisibi', 'on');
      ruleview('#simulink', u, figN);
      set(figN, 'HandleVisibi', 'callback');
    end
    sys = [];
    drawnow;    % for invoking with rk45, etc.
elseif ~isempty(flag) & flag == 9,   % When simulation stops ...
    % ====== change labels of standard UI controls
elseif ~isempty(flag) & flag == 0,
    % ====== find animation block & figure
    name=fismatrix.name;
    figNum=findobj(allchild(0), 'name', ['Rule Viewer: ' name]);
    if isempty(figNum)
     ruleview(fismatrix);
     figNum=findobj(allchild(0), 'name', ['Rule Viewer: ' name]);
     position=get(figNum, 'Position');
     set(figNum, 'Position', position+[.2 -.2 0 0]);
    else
     figure(figNum);
    end
    sys = [0 0 0 -1 0 0];
elseif nargin == 5, % for callbacks of GUI

end
