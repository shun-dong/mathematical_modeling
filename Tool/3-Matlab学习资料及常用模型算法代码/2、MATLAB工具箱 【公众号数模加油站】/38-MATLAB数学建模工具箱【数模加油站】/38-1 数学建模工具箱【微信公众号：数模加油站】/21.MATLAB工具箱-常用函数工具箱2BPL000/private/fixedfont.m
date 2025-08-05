function [fontname,fontsize] = fixedfont
%FIXEDFONT Returns name and size of a fixed width font for this system.
%   Example usage:
%     [fontname,fontsize] = fixedfont;

%   Copyright (c) 1988-98 by The MathWorks, Inc.
% $Revision: 1.3 $

switch computer
case 'PCWIN'
    fontname = 'courier';
case 'MAC2'
    fontname = 'monaco';
otherwise
    fontname = 'fixed';
end
    
fontsize = get(0,'defaultuicontrolfontsize');
