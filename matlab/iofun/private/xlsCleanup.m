function xlsCleanup(Excel, filePath)
    % xlsCleanup helps clean up after the xlsread COM implementation.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.
        
    %   Copyright 1984-2012 The MathWorks, Inc.

    % Suppress all exceptions
    try                                                                        %#ok<TRYNC> No catch block
        %Turn off dialog boxes as we close the file and quit Excel.
        Excel.DisplayAlerts = 0; 
        % Explicitly close the file just in case.  The Excel API expects just the
        % filename and not the path.  This is safe because Excel also does not
        % allow opening two files with the same name in different folders at the
        % same time.
        [~, name, ext] = fileparts(filePath);
        fileName = [name ext];
        Excel.Workbooks.Item(fileName).Close(false);
    end
    Excel.Quit;
    Excel.delete;
end
