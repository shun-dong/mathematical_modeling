function [h, varargout] = FigureHandle(h)
if ishandle(h)
    while ~isempty(h) & ~strcmp(get(h,'Type'),'figure')
        h = get(h,'Parent');
    end
else
    h = [];
end
if nargout>1 & ~isempty(h)
    varargout{1} = guidata(h);
end
% --------------------------------------------------------------------
