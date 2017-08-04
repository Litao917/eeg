function [numericData, textData, rawData, customOutput] = xlsreadCOM(file, sheet, range, Excel, customFun)
    % xlsreadCOM is the COM implementation of xlsread.
    %   [NUM,TXT,RAW,CUSTOM]=xlsreadCOM(FILE,SHEET,RANGE,EXCELS,CUSTOM) reads
    %   from the specified SHEET and RANGE.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.

    %   Copyright 1984-2013 The MathWorks, Inc.
    
    
    % OpenExcelWorkbook may throw an exception if, for example, an invalid
    % file format is specified.
    readOnly = true;
    [~, workbookHandle] = openExcelWorkbook(Excel, file, readOnly);
    
    if isequal(sheet,-1)
        % User requests interactive range selection.
        % Set focus to first sheet in Excel workbook.
        activate_sheet(Excel, 1);
        
        % Make Excel interface the active window.
        set(Excel,'Visible',true);
        
        % Bring up message box to prompt user.
        uiwait(warndlg({getString(message('MATLAB:xlsread:DlgSelectDataRegion'));...
            getString(message('MATLAB:xlsread:DlgClickOKToContinueInMATLAB'))},...
            getString(message('MATLAB:xlsread:DialgoDataSelectionDialogue')),'modal'));
        DataRange = get(Excel,'Selection');
        if isempty(DataRange)
            error(message('MATLAB:xlsread:NoRangeSelected'));
        end
        set(Excel,'Visible',false); % remove Excel interface from desktop
    else
        % Activate indicated worksheet.
        activate_sheet(workbookHandle,sheet);
        
        try % importing a data range.
            if isempty(range)
                % Select all cells of active sheet.
                DataRange = workbookHandle.ActiveSheet.UsedRange;
            else
                % The range is specified.
                Excel.Goto(Range(Excel,sprintf('%s',range)));
                DataRange = get(Excel,'Selection');
            end
        catch  %#ok<CTCH> % data range error.
            error(message('MATLAB:xlsread:RangeSelection', range));
        end
    end
    
    %Call the custom function if it was given.  Provide customOutput if it
    %is possible.
    customOutput = {};
    if nargin == 5 && ~isempty(customFun)
        if nargout(customFun) < 2
            DataRange = customFun(DataRange);
        else
            [DataRange, customOutput] = customFun(DataRange);
        end
    end
    
    % get the values in the used regions on the worksheet.
    rawData = DataRange.Value;
    % Ensure that the rawData is always a cell array.  When DataRange.Value
    % returns only a single value it is returned as a primitive type.
    if ~iscell(rawData)
        rawData = {rawData};
    end
    % parse data into numeric and string arrays
    [numericData, textData] = xlsreadSplitNumericAndText(rawData);
end
%--------------------------------------------------------------------------
function activate_sheet(Workbook,Sheet)
    % Activate specified worksheet in workbook.
    
    % Initialize worksheet object
    WorkSheets = Workbook.Worksheets;
    
    % Get name of specified worksheet from workbook
    try
        TargetSheet = get(WorkSheets,'item',Sheet);
    catch  %#ok<CTCH>
        error(message('MATLAB:xlsread:WorksheetNotFound', Sheet));
    end
    
    %Activate silently fails if the sheet is hidden
    set(TargetSheet, 'Visible','xlSheetVisible');
    % activate worksheet
    Activate(TargetSheet);
end