function ans = get(obj,prop)
%GET Method for fdmeas object

%   Author: T. Krauss
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.3 $

obj = struct(obj);

if ~iscell(prop)
    prop = {prop};
end

prop = prop(:);
obj = obj(:);

ans = cell(length(obj),length(prop));
for i = 1:length(obj)
    for j = 1:length(prop)
        ans{i,j} = getprop(obj(i),prop{j});
    end
end

if all(size(ans)==1)
    ans = ans{:};
end


function val = getprop(obj,prop)
% get the value of a single property of a single object struct

switch prop
case {'label','callback','format','value','lastvalue',...
       'range','inclusive','integer','editable','visible','position',...
       'radiogroup','userdata','help','hlabel','tooltip'}
    objud = get(obj.h,'userdata');
    val = eval(['objud.' prop]); %getfield(objud,prop);
case 'h'
    val = obj.h;
otherwise
    val = get(obj.h,prop);
end
