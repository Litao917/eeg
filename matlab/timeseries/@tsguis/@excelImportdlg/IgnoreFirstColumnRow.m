function flag=IgnoreFirstColumnRow(h)
% CHECKTIMEFORMAT implement first column/row time vector smart detection
% return true if the first n cells contain time (either absolute or
% relative).

% Author: Rong Chen 
% Revised: 
% Copyright 2004-2012 The MathWorks, Inc.

flag=0;
if ~isempty(h.Handles.tsTable)
    % data is organized by column
    if get(h.Handles.COMBdataSample,'Value')==1
        % get active sheet
        tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
        % get column index
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        tmpColNumber=h.findcolumnnumber(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check
        tmpEndRow=min(size(tmpSheet,1),h.IOData.checkLimit);
        for i=1:tmpEndRow
            TimePoint=cell2mat(tmpSheet(i,tmpColNumber));
            if ischar(TimePoint)
                if isempty(TimePoint)
                    flag=flag+1;
                else
                    try
                        dummy=datestr(TimePoint);
                        break;
                    catch
                        % not an absolute date/time format, move to the second row
                        flag=flag+1;
                    end
                end
            else
                break;
            end
        end
    % data is organized by row
    else
        % get active sheet
        tmpSheet=h.IOData.rawdata.(genvarname(h.IOData.DES{get(h.Handles.COMBdataSheet,'Value')}));
        % get row index
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        tmpRowNumber=str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        % check
        tmpEndColumn=min(size(tmpSheet,2),h.IOData.checkLimit);
        for i=1:tmpEndColumn
            TimePoint=cell2mat(tmpSheet(tmpRowNumber,i));
            if ischar(TimePoint)
                if isempty(TimePoint)
                    flag=flag+1;
                else
                    try
                        dummy=datestr(TimePoint);
                        break;
                    catch
                        % not an absolute date/time format, move to the second row
                        flag=flag+1;
                    end
                end
            else
                break;
            end
        end
    end
end
    