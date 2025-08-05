function [lineinfo,colorCount] = nextcolor(co,lso,colorCount)
%Returns next available color and linestyle and increments colorCount
% Inputs:
%      co - cell array of colors
%      lso - cell array of line styles
%      colorCount - number of colors allocated thus far
% Outputs:
%      lineinfo - structure with .color and .linestyle fields
%
% Used by sigbrowse, filtview and spectview

%       Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.3 $

lc = length(co);
ls = length(lso);
   
colorCount = colorCount + 1;

lineinfo.color = co{rem(colorCount-1,lc)+1};
lineinfo.linestyle = lso{rem(ceil(colorCount/lc)-1,ls)+1};
    
