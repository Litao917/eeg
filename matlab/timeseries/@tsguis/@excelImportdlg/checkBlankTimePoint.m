function [SelectedIndex,flag] = checkBlankTimePoint(h,timeValue,option)
%

%  Copyright 1986-2011 The MathWorks, Inc.

SelectedIndex = 1:length(timeValue);
flag=true;
if iscell(timeValue)
    nanI = cellfun(@(x) isnumeric(x) && isnan(x),timeValue);
    emptyI = cellfun('isempty',timeValue);
    if sum(nanI)>0 || sum(emptyI)>0
        ButtonBlank=questdlg(getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:TimeVectorBlankTimePoints')), ...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:TimeSeriesTools')), getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove')), ...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Abort')),...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove')));
        drawnow;
        switch ButtonBlank
            case getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove'))
                ; %#ok<*NOSEM>
            case getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Abort'))                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        timeValue(nanI) = {''};
        SelectedIndex=~cellfun('isempty',timeValue);
        flag=true;
    end
elseif isnumeric(timeValue)
    if sum(isnan(timeValue))>0
        ButtonBlank=questdlg(getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:TimeVectorBlankTimePoints')), ...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:TimeSeriesTools')), getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove')), ...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Abort')),...
        getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove')));
        drawnow;
        switch ButtonBlank
            case getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Remove'))
                ;
            case getString(message('MATLAB:tsguis:excelImportdlg:checkBlankTimePoint:Abort'))                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        SelectedIndex=~isnan(timeValue);
        flag=true;
    end
elseif ischar(timeValue) && isvector(timeValue)
    SelectedIndex=1;
end
