function res = createScribeContextMenu(hThis,hFig) %#ok<INUSL>
% Given a figure, check for context-menu entries specific to that shape-type and
% figure. If no context-menu has been defined, then create one. It should
% be noted that we are only returning entries to be merged into a larger
% context-menu at a later point in time.

% The context-menu entries will be uniquely identified by a tag based on the shape
% type. Tags should be of the form "package.class.uicontextmenu.propertyname" and will
% have their visibility set to off.

%   Copyright 2006-2011 The MathWorks, Inc.

hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
hMenu = hMode.UIContextMenu;

res = findall(hMenu,'Type','uimenu','-regexp','Tag','scribe.doublearrow.uicontextmenu*');
if ~isempty(res)
    res = res(end:-1:1);
    return;
end

% Create the context menu entries.
res = [];

% Line color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
% Line width:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth', getString(message('MATLAB:uistring:scribemenu:LineWidth')));
% Line style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle', getString(message('MATLAB:uistring:scribemenu:LineStyle')));
% Head style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadStyle',getString(message('MATLAB:uistring:scribemenu:HeadStyle')),'HeadStyle', getString(message('MATLAB:uistring:scribemenu:HeadStyle')));
% Head size:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'HeadSize',getString(message('MATLAB:uistring:scribemenu:HeadSize')),'HeadSize', getString(message('MATLAB:uistring:scribemenu:HeadSize')));


% Set the tag of the menu items for future access
menuSpecificTags = {'Color','LineWidth','LineStyle','HeadStyle','HeadSize'};
assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
for i=1:length(res)
    set(res(i),'Tag',['scribe.doublearrow.uicontextmenu' '.' menuSpecificTags{i}]);
end

% reparent the menus.
set(res,'Visible','off','Parent',hMenu);