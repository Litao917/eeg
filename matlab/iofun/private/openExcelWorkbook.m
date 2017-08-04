function [format, workbook] = openExcelWorkbook(Excel, filename, readOnly)
    % Opens an Excel Workbook and checks for the correct format.
    %   Copyright 1984-2012 The MathWorks, Inc.
    
    Excel.DisplayAlerts = 0;
    
    function WorkbookActivateHandler(varargin)
        workbook = varargin{3};
    end

    % It is necessary to wait for the workbook to actually be opened, as
    % the call to Open with an output argument is asynchronous. Using a
    % handler ensures that the handler is called before the call to Open
    % returns, thus ensuring that the interface is the right interface.
    registerevent(Excel,{'WorkbookActivate', @WorkbookActivateHandler});
    Excel.workbooks.Open(filename, 0, readOnly);
    format =  waitForValidWorkbook(workbook);
    if strcmpi(format, 'xlCurrentPlatformText')
       throwAsCaller(MException(message('MATLAB:xlsread:FileFormat', filename)));
    end
end

function format = waitForValidWorkbook(ExcelWorkbook)
    % After the event is complete, it may take time to have the workbook be ready.
    % When it is not ready, errors will occur in getting the values of any properties,
    % such as format.
    format = [];
    for i = 1:500
        try
            format = ExcelWorkbook.FileFormat;
            break;
        catch exception %#ok<NASGU>
            pause(0.01);
        end
    end
    % If we still have no format, try one last time, and let the error
    % propagate.
    if isempty(format)
        format = ExcelWorkbook.FileFormat;
    end
end
