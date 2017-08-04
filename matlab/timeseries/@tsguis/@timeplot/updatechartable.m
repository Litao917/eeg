function updatechartable(view,h,varargin)

% Copyright 2004-2011 The MathWorks, Inc.

%% Updates the characteristic table in response to a ViewChange event.
%% varargin is the unit conversion factor if a unit conversion
%% is in progress.

if isempty(view.waves)
    return % Nothing to do
end

%% Initialize vars
charTab = h.findtab('Characteristics');
charTable = charTab.Handles.CharTable;
newData = repmat({''},[charTable.getRowCount,charTable.getColumnCount]);
newData(:,1) = repmat({false},[size(newData,1) 1]);

%% Update newData cell array with char props
for row=1:charTable.getRowCount
        % Get char vector
        thischar = [];
        for k=1:length(view.waves)
            if ~isempty(view.waves(k).Characteristics)
                ind = strcmp(cellfun(@(x) x, get(view.waves(k).Characteristics,{'Identifier'}),'UniformOutput',false),...
                          charTable.getValueAt(row-1,1));
                if any(ind)
                    thischar = [thischar(:); view.waves(k).Characteristics(ind)];
                end
            end
        end
        
        if ~isempty(thischar)
            if strcmp(thischar(1).Visible,'on') 
                newData{row,1} =  true;
            end
            
            % Find earliest start and latest end among all chars
            thisStartTime = inf;
            thisEndTime = -inf;
            for k=1:length(thischar)
                if nargin>=3 && strcmp(view.AbsoluteTime,'off') % Maybe convert
                    thischar(k).Data.StartTime = thischar(k).Data.StartTime*varargin{1}; %#ok<AGROW>
                    thischar(k).Data.EndTime = thischar(k).Data.EndTime*varargin{1}; %#ok<AGROW>
                end
                if ~isempty(thischar(k).Data.StartTime) && isscalar(thischar(k).Data.StartTime)
                    thisStartTime = min(thisStartTime,thischar(k).Data.StartTime);
                end
                if ~isempty(thischar(k).Data.EndTime) && isscalar(thischar(k).Data.EndTime)
                    thisEndTime = max(thisEndTime,thischar(k).Data.EndTime);
                end
            end 
            
            % Generate start and end string for char table
            if isfinite(thisStartTime) && isfinite(thisEndTime)
                if strcmp(view.AbsoluteTime,'off')
                    newData(row,3:end) = {sprintf('%0.3g',thisStartTime),...
                        sprintf('%0.3g',thisEndTime)};
                else
                    if tsIsDateFormat(view.TimeFormat)
                        startTimeStr = datestr(thisStartTime*...
                            tsunitconv('days',view.TimeUnits)+datenum(view.StartDate),...
                            view.TimeFormat);
                        endTimeStr = datestr(thisEndTime*...
                            tsunitconv('days',view.TimeUnits)+datenum(view.StartDate),...
                            view.TimeFormat);
                    else
                        startTimeStr = datestr(thisStartTime*...
                            tsunitconv('days',view.TimeUnits)+datenum(view.StartDate));
                        endTimeStr = datestr(thisEndTime*...
                            tsunitconv('days',view.TimeUnits)+datenum(view.StartDate));
                    end
                    newData(row,3:end) = {startTimeStr,endTimeStr};               
                end 
            end
        end
end

%% Get the current data
charTableModel = charTable.getModel;
lastData = cell(size(newData));
for row=1:charTable.getModel.getDataVector.size
     lastData(row,:) = cell(charTable.getModel.getDataVector.get(row-1).toArray);
end

%% If the current data differs from the new data update the char table
%% non-recursively
for row=1:size(newData,1)
   for col=1:size(newData,2)
       if col~=2 && ~isequal(newData{row,col},lastData{row,col})
           charTableModel.setValueAtNoCallback(newData{row,col},row-1,col-1);
       end
   end
end