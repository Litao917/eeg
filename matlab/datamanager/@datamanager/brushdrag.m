function brushdrag(es,ed)

% Brush mode WindowMouseMotion callback

%  Copyright 2007-2010 The MathWorks, Inc.

fig = double(es);

% Hittest needs current point units to be the figure units when the motion
% callback is triggered from a mode
if ~graphicsversion(fig,'handlegraphics')
    propName = 'Point';
    curr_units = ed.(propName);
else
    propName = 'CurrentPoint';
    curr_units = hgconvertunits(fig,[0 0 ed.(propName)],...
        'pixels',get(fig,'Units'),fig);
    curr_units = curr_units(3:4);
end
set(fig,'CurrentPoint',curr_units);

% Get the hit axes
axall = localHittest(fig,ed,'axes');

% Restrict hit axes to those with 'HandleVisibility','on'
if ~isempty(axall)
   axall = findobj(axall,'flat','type','axes','HandleVisibility','on');
end
% Get objects
brushmode = getuimode(fig,'Exploration.Brushing');
selectionObject = brushmode.ModeStateData.SelectionObject;
if isempty(selectionObject) || isempty(selectionObject.ScribeStartPoint) ...
        || length(selectionObject.ScribeStartPoint)<2
    if ~isempty(axall) 
        setptr(fig,'crosshair');
    else
        setptr(fig,'arrow');
    end
    return
end
ax = selectionObject.Axes;

% If the start axes disagrees with the initial axes quick return
if ~isempty(axall) && ~any(axall==ax)
    setptr(fig,'arrow');
    return
end
setptr(fig,'crosshair');
brushIndex = brushmode.ModeStateData.brushIndex;

% Prevent excessive event traffic
t = brushmode.ModeStateData.time;
if ~isempty(t) && now-t<0.5e-006
    return;
end

% Get current workspace for the initiator of the brush. The number "5" 
% reflects the stack depth of the calling workspace.
[mfile,fcnname] = datamanager.getWorkspace(5);

% Draw 3d cross-section for 3d plots
if ~selectionObject.Axes2D && graphicsversion(fig,'handlegraphics')
    % Draw the ROI and get the ROI dimensions
    crossX = brushmode.ModeStateData.SelectionObject.draw(ed);
    datamanager.brushPrism(ax,brushmode.ModeStateData.brushObjects,...
        crossX,brushmode.ModeStateData.lastRegion,...
        brushIndex,brushmode.ModeStateData.color,mfile,fcnname);
    brushmode.ModeStateData.lastRegion = crossX;
else
    % Draw the ROI and get the ROI polygon/ROI dimensions
    region = brushmode.ModeStateData.SelectionObject.draw(ed);
    
    % Brush points inside the ROI
    datamanager.brushRectangle(ax,brushmode.ModeStateData.brushObjects,...
          [],region,brushmode.ModeStateData.lastRegion,...
          brushIndex,brushmode.ModeStateData.color,mfile,fcnname);
    brushmode.ModeStateData.lastRegion = region;
    
    % Brush data in the companion axes for plotyy
    if ~isempty(brushmode.ModeStateData.plotYYModeStateData)
        axYY = brushmode.ModeStateData.plotYYModeStateData.currentAxes;
        % If not using MCOS graphics the region must be converted to the
        % data units of the second axes. Otherwise, the region is in figure
        % units, so no conversion is needed.
        if graphicsversion(fig,'handlegraphics')
            pixRect = localConvertToPixels(ax,region);                
            rectPosYY = localConvertFromPixels(axYY,pixRect);
        else
            rectPosYY = region;
        end
        datamanager.brushRectangle(axYY,brushmode.ModeStateData.plotYYModeStateData.brushObjects,...
          [],rectPosYY,brushmode.ModeStateData.plotYYModeStateData.lastRegion,...
          brushIndex,brushmode.ModeStateData.color,mfile,fcnname);
         brushmode.ModeStateData.plotYYModeStateData.lastRegion = rectPosYY;
    end


end

brushmode.ModeStateData.time = now;

         

function pixRect = localConvertToPixels(hAx,rect)

% Get normalized position in axes
axLimsX = get(hAx,'xlim');
axLimsY = get(hAx,'ylim');
rect(1:2) = rect(1:2)-[axLimsX(1) axLimsY(1)];
rect(3:4) = rect(3:4)./([diff(axLimsX) diff(axLimsY)]);
rect(1:2) = rect(1:2)./([diff(axLimsX) diff(axLimsY)]);
fig = ancestor(hAx,'figure');
axesPos = hgconvertunits(fig,get(hAx,'position'),get(hAx,'Units'),'Pixels',fig);
rect(1) = rect(1)*axesPos(3)+axesPos(1);
rect(2) = rect(2)*axesPos(4)+axesPos(2);
rect(3) = rect(3)*axesPos(3);
rect(4) = rect(4)*axesPos(4);
pixRect = rect;

function axesRect = localConvertFromPixels(hAx,rect)
fig = ancestor(hAx,'figure');
axLimsX = get(hAx,'xlim');
axLimsY = get(hAx,'ylim');
axesPos = hgconvertunits(fig,get(hAx,'position'),get(hAx,'Units'),'Pixels',fig);
rect(1) = (rect(1)-axesPos(1))/axesPos(3);
rect(2) = (rect(2)-axesPos(2))/axesPos(4);
rect(3) = rect(3)/axesPos(3);
rect(4) = rect(4)/axesPos(4);

rect(1:2) = rect(1:2).*[diff(axLimsX) diff(axLimsY)]+[axLimsX(1) axLimsY(1)];
rect(3:4) = rect(3:4).*([diff(axLimsX) diff(axLimsY)]);
axesRect = rect;

function obj = localHittest(hFig,evd,varargin)
if ~graphicsversion(hFig,'handlegraphics')
    obj = plotedit([{'hittestHGUsingMATLABClasses',hFig,evd},varargin(:)]);
else
    obj = double(hittest(hFig,varargin{:}));
    % Ignore objects whose 'hittest' property is 'off'
    obj = obj(arrayfun(@(x)(strcmpi(get(x,'HitTest'),'on')),obj));
end