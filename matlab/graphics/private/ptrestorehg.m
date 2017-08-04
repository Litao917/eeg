function ptrestorehg( pt, h )
%FORMAT Method that restores a Figure after formatting it for output.
%   Input of PrintTemplate object and a Figure to modify.
%   Figure has numerous properties restore to previous values modified
%   to account for template settings.

%   Copyright 1984-2012 The MathWorks, Inc.

if pt.DebugMode
    disp(sprintf(getString(message('MATLAB:uistring:ptrestorehg:RestoringFigure', num2str(double(h))))))
    pt
end

if pt.VersionNumber > 1
    hgdata = pt.v2hgdata;
    % Get all the text and lines
    allAxes = hgdata.AllAxes;
    allText = hgdata.AllText;
    allPrimitiveText = hgdata.AllPrimitiveText;
    allLine = hgdata.AllLine;
    allColor = hgdata.AllColor;
    allMarker = hgdata.AllMarker;
    allEdge = hgdata.AllEdge;
    allLineObj = hgdata.AllLineObj;
    allCData = hgdata.AllCData;
    isvalidaxes = ishandle(allAxes);
    isvalidtext = ishandle(allText);
    isvalidprimitivetext = ishandle(allPrimitiveText);
    isvalidline = ishandle(allLine);
    isvalidlineobj = ishandle(allLineObj);
    isvalidcolor = ishandle(allColor);
    isvalidmarker = ishandle(allMarker);
    isvalidedge= ishandle(allEdge);
    isvalidcdata = ishandle(allCData);
    allAxes = allAxes(isvalidaxes);
    allText = allText(isvalidtext);
    allPrimitiveText = allPrimitiveText(isvalidprimitivetext);
    allLine = allLine(isvalidline);
    allColor = allColor(isvalidcolor);
    allMarker = allMarker(isvalidmarker);
    allEdge = allEdge(isvalidedge);
    allLineObj = allLineObj(isvalidlineobj);
    allCData = allCData(isvalidcdata);

    if ~isempty(allPrimitiveText)
        if isfield(hgdata, 'PrimitiveTextBackgroundColor')
            set(allPrimitiveText, {'BackgroundColor'}, hgdata.PrimitiveTextBackgroundColor(isvalidprimitivetext));
        end
    end


    if ~isempty(allText)
        if isfield(hgdata, 'fontname')
            set(allText, {'FontName'}, hgdata.fontname(isvalidtext));
        end
        if isfield(hgdata, 'fontsize')
            set(allText, {'FontSize'}, hgdata.fontsize(isvalidtext));
        end
        if isfield(hgdata, 'fontweight')
            set(allText, {'FontWeight'}, hgdata.fontweight(isvalidtext));
        end
        if isfield(hgdata, 'fontangle')
            set(allText, {'FontAngle'}, hgdata.fontangle(isvalidtext));
        end
        if isfield(hgdata, 'fontcolor')
            set(allText, {'Color'}, hgdata.fontcolor(isvalidtext));
        end
    end
    
    if ~isempty(allLineObj)
        if isfield(hgdata, 'linewidth')
            set(allLineObj, {'LineWidth'}, hgdata.linewidth(isvalidlineobj));
        end
    end

    if ~isempty(allLine)
        if isfield(hgdata, 'linestyle')
            set(allLine, {'LineStyle'}, hgdata.linestyle(isvalidline));
        end
        if isfield(hgdata, 'linecolor')
            set(allLine, {'Color'}, hgdata.linecolor(isvalidline));
        end
    end

    % Restore the colormap of the figure and other colors
    if isfield(hgdata, 'colormap')    
        set(h, 'Colormap', hgdata.colormap);
    end
    if isfield(hgdata, 'Color')    
        LocalSetValues(allColor, {'Color'}, hgdata.Color(isvalidcolor));
    end
    if isfield(hgdata, 'XColor')    
        LocalSetValues(allAxes, {'XColor'}, hgdata.XColor(isvalidaxes));
    end
    if isfield(hgdata, 'YColor')    
        LocalSetValues(allAxes, {'YColor'}, hgdata.YColor(isvalidaxes));
    end
    if isfield(hgdata, 'ZColor')    
        LocalSetValues(allAxes, {'ZColor'}, hgdata.ZColor(isvalidaxes));
    end
    if isfield(hgdata, 'MarkerEdgeColor')    
        set(allMarker, {'MarkerEdgeColor'}, hgdata.MarkerEdgeColor(isvalidmarker));
    end
    if isfield(hgdata, 'MarkerFaceColor')    
        set(allMarker, {'MarkerFaceColor'}, hgdata.MarkerFaceColor(isvalidmarker));
    end
    if isfield(hgdata, 'EdgeColor')    
        set(allEdge, {'EdgeColor'}, hgdata.EdgeColor(isvalidedge));
    end
    if isfield(hgdata, 'FaceColor')    
        set(allEdge, {'FaceColor'}, hgdata.FaceColor(isvalidedge));
    end
    if isfield(hgdata, 'CData')    
        set(allCData, {'CData'}, hgdata.CData(isvalidcdata));
    end 

    % Restore BKColor
    if isfield(hgdata, 'BkColor')
	set(h, 'Color', hgdata.BkColor);
    end
end

% Output Axes with same tick MARKS as on screen
if pt.AxesFreezeTicks
    LocalSetValues( pt.tickState.handles, {'XTickMode','YTickMode','ZTickMode'}, pt.tickState.values )
    pt.tickState = {};
end

% Output Axes with same tick LIMITS as on screen
if pt.AxesFreezeLimits
    LocalSetValues( pt.limState.handles, {'XLimMode','YLimMode','ZLimMode'}, pt.limState.values )
    pt.limState = {};
end

% LocalWords:  fontname fontsize fontweight fontangle fontcolor linewidth
% LocalWords:  linestyle linecolor XColor YColor ZColor YTick ZTick

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetValues(inArray, props, values)
% Checks to make sure a property exists before trying to set it
for i=1:length(inArray)
    for j=1:length(props)
        if isprop(inArray(i), props{j})
            set(inArray(i), props{j}, values{i});
        end
    end
end
