function GraphVariables = GraphGetGraphVariables()
% Returns a list of all variables in base workspace, which are of the type 'Graph'
%
% Receives:
%   none
%
% Returns:
%   
%
% See Also:
%   GraphLoad, GraphGIUBrowseGraph, GraphGIUSelectGraph
%
% Example:
%   Graph = ObjectCreateDataSeries(Data);
%   
% Created:
%   
%   Lev Muchnik    28/07/2005, lev@topspin.co.il, +972-54-4326496
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error(nargchk(0,0,nargin));
error(nargoutchk(0,1,nargout));

Variables = evalin('base','who');
SelectedIndeces = [];
for i = 1 : numel(Variables)
    if ObjectIsType(evalin('base',Variables{i}),'Graph')
        SelectedIndeces(end+1) = i;
    end   
end
GraphVariables = cell(numel(SelectedIndeces) ,1);
for i = 1 : numel(SelectedIndeces) 
    GraphVariables{i} = Variables{SelectedIndeces(i)};
end