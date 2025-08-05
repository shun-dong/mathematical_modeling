function delete(obj)

%   Author: T. Krauss
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.2 $

obj = struct(obj);
for i = 1:length(obj)
    fig = get(obj(i).h,'parent');
    ud = get(fig,'userdata');
    
    ind = find(obj(i).h == [ud.Objects.fdax.h]);
    if isempty(ind)
        error('Not a valid object')
    end
        
    objud = get(obj(i).h,'userdata');
    
    % need to delete any lines which are children of this axes
    lines = ud.Objects.fdline.h;
    if length(lines)>1
        lines = [lines{:}];
    end
    for j = 1:length(lines)
        if get(lines(j),'parent') == obj(i).h
            delete(ud.Objects.fdline(j))
        end
    end
    ud = get(fig,'userdata');
    
    delete(obj(i).h)
    
    ud.Objects.fdax(ind) = [];
    
    set(fig,'userdata',ud)
end
if ~isempty(obj)
    setpos(ud.Objects.fdax,fig)
end

