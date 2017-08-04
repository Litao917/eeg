function [SelectedIndex,flag]=checkBlankTimePoint(h,timeValue,option)

% Copyright 2004-2012 The MathWorks, Inc.

SelectedIndex=[1:length(timeValue)];
flag=true;
if iscell(timeValue)
    if sum(cellfun('isempty',timeValue))>0 || sum(isnan(cell2mat(timeValue(cellfun('isclass',timeValue,'double')))))>0
        ButtonBlank = questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeVectorContainsBlankTimePoints')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')),...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove')));
        drawnow;
        switch ButtonBlank
            case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove'))
                ;
            case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort'))                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        tmpIndex=find(cellfun('isclass',timeValue,'double')==1);
        tmpIndex=tmpIndex(isnan(cell2mat(timeValue(tmpIndex))));
        timeValue(tmpIndex)={''};
        SelectedIndex=~cellfun('isempty',timeValue);
        flag=true;
    end
elseif isnumeric(timeValue)
    if sum(isnan(timeValue))>0
        ButtonBlank=questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeVectorContainsBlankTimePoints')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')),...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove')));
        drawnow;
        switch ButtonBlank
            case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Remove'))
                ;
            case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort'))                    
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

