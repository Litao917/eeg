function str = getDatatipText(this,dataCursor)

% Specify datatip string

% Copyright 2003-2011 The MathWorks, Inc.

N_DIGITS = 3;
is_horz = strcmpi(get(this,'Horizontal'),'on');

pos = get(dataCursor,'Position');
if is_horz
    % Cursor location is flipped with respect to our xdata and ydata
    cursorX = pos(2);
    cursorY = pos(1);
else
    cursorX = pos(1);
    cursorY = pos(2);
end

matching_X_values = find(this.XData == cursorX);
if isscalar(matching_X_values) && this.YData(matching_X_values) == cursorY
    ind = matching_X_values;
else
    ind = get(dataCursor,'DataIndex');
end

is_stacked = strcmpi(get(this,'BarLayout'),'stacked');
if is_horz
    str = [createStackedString('X', cursorY, is_stacked, N_DIGITS), ...
        createSegmentString('X', this.ydata(ind), is_stacked, N_DIGITS), ...
        createValueString('Y', this.xdata(ind), N_DIGITS) ...
        ];
else
    str = [createValueString('X', this.xdata(ind), N_DIGITS), ...
        createStackedString('Y', cursorY, is_stacked, N_DIGITS), ...
        createSegmentString('Y', this.ydata(ind), is_stacked, N_DIGITS) ...
        ];
end


function cell_str = createValueString(axisName, value, N_DIGITS)
% Create a basic string for the tip.
cell_str = {[axisName ' = ',num2str(value,N_DIGITS)]};

function cell_str = createStackedString(axisName, value, isStacked, N_DIGITS)
% Create a string for a stacked value, if stacking is enabled.
if isStacked
    cell_str = createValueString(axisName, value, N_DIGITS);
    cell_str = [cell_str{1}, ' (Stacked)'];
else
    cell_str = {};
end

function cell_str = createSegmentString(axisName, value, isStacked, N_DIGITS)
% Create a string for a segment value, and label it as a segment value is
% stacking is enabled.
cell_str = createValueString(axisName, value, N_DIGITS);
if isStacked
    cell_str = [cell_str{1},' (Segment)'];
end
