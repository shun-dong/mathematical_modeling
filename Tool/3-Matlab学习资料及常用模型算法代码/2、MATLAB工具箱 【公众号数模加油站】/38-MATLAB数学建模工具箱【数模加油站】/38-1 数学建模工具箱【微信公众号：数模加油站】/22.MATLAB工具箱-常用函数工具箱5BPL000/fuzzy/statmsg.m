function statmsg(figNumber,msgStr)
%STATMSG Send message to GUI status field.
%   STATMSG(figNumber,msgStr) causes the message contained in msgStr
%   to be passed to the status line (a text uicontrol field with the
%   Tag property set to "status") of the specified figure. 

%   Ned Gulley, 4-27-94
%   Copyright (c) 1994-98 by The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 1997/12/01 21:45:53 $

set(findobj(figNumber,'Type','uicontrol','Tag','status'),'String',msgStr);
