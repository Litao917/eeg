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

res = findall(hMenu,'Type','uimenu','-regexp','Tag','scribe.scriberect.uicontextmenu*');
if ~isempty(res)
    res = res(end:-1:1);
    return;
end

% Create the context menu entries.
res = [];
% Edge color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color',getString(message('MATLAB:uistring:scribemenu:ColorDotDotDot')),'Color',getString(message('MATLAB:uistring:scribemenu:Color')));
% Face color:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'Color',getString(message('MATLAB:uistring:scribemenu:FaceColorDotDotDot')),'FaceColor',getString(message('MATLAB:uistring:scribemenu:FaceColor')));
% Line width:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineWidth',getString(message('MATLAB:uistring:scribemenu:LineWidth')),'LineWidth', getString(message('MATLAB:uistring:scribemenu:LineWidth')));
% Line style:
res(end+1) = graph2dhelper('createScribeUIMenuEntry',hFig,'LineStyle',getString(message('MATLAB:uistring:scribemenu:LineStyle')),'LineStyle', getString(message('MATLAB:uistring:scribemenu:LineStyle')));

% Set the tag of the menu items for future access
menuSpecificTags = {'Color','FaceColor','LineWidth','LineStyle'};
assert(length(res)==length(menuSpecificTags),'Number of menus and menu tags should be the same');
for i=1:length(res)
    set(res(i),'Tag',['scribe.scriberect.uicontextmenu' '.' menuSpecificTags{i}]);
end

% reparent the menus.
set(res,'Visible','off','Parent',hMenu);