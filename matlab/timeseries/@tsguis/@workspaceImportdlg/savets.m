function flag=savets(h)
% SAVETS imports the selected time and data into tstool

% this method is used to create one or more timeseries objects based on the
% user selections in the data import dialog.  If the time vector is in
% absolute date/time format, it will be automatically converted into proper
% MATLAB-supported date/time format.

% Author: Rong Chen 
%  Copyright 2004-2012 The MathWorks, Inc.

% -------------------------------------------------------------------------
% pre-save check
% -------------------------------------------------------------------------
if isempty(h.IOData.SelectedRows) || isempty(h.IOData.SelectedColumns)
    errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:NoDataBlockHasBeenSelected')),...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
    flag=false;
    return;
end
ButtonSameName=[];
if ~isempty(h.IOData.SelectedVariableInfo)
    dataOriginal=evalin('base',h.IOData.SelectedVariableInfo.varname);
else
    flag=false;
    return;
end
if get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleNEW
    % create a new timeseries object
    % get the timeseries object name from the edit box
    UserInputName=strtrim(get(h.Parent.Handles.EDTsingleNEW,'String'));
%     if ~isvarname(UserInputName)
%         errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeIsNotAValidName')),...
%             getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
%         flag=false;
%         return
%     end
    set(h.Parent.Handles.EDTsingleNEW,'String',UserInputName);
    % check if there exists a time series object with the same name
    tsgui = tstool;
    G = tsgui.TSnode.getChildren;
    alltsobjects = {};
    for k = 1:length(G)
        if strcmp(class(G(k)),'tsguis.tsnode')
            alltsobjects{end+1} = G(k).Timeseries; %#ok<AGROW>
        end
    end
    %alltsobjects = get(tsgui.Tsnode.getChildren,{'Timeseries'});
    if ~isempty(alltsobjects)
        for i=1:length(alltsobjects)
            if strcmp({alltsobjects{i}.Name},UserInputName)
                ButtonSameName = questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ATimeSeriesObjectAlreadyExists')), ...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace')), ...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')), ...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace')));
                drawnow;
                switch ButtonSameName
                    case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace'))
                        % delete the old time series object in tstool
                    case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort'))                    
                        flag=false;
                        return;
                end
            end                            
        end
    end
elseif get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleINSERT
    % import into an existing timeseries object with name given
    % in the combo box
    % get the name
    str=get(h.Parent.Handles.COMBsingleINSERT,'String');
    UserInputName=str{get(h.Parent.Handles.COMBsingleINSERT,'Value')};
    if isempty(UserInputName)
        errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:NoExistingTimeSeriesIsSelected')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
        flag=false;
        return
    end
else
    if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
        % use strings in a row or column as timeseries names
        try
            UserInputName=str2double(strtrim(get(h.Parent.Handles.EDTmultipleNEW,'String')));
        catch me %#ok<NASGU>
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheRowIndexShouldBeAnInteger')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            return
        end
    else
        % use the given name + suffix as timeseries names
        UserInputName=strtrim(get(h.Parent.Handles.EDTmultipleNEW,'String'));
%         if ~isvarname(UserInputName)
%             errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:VariableNameShouldBeValid')),...
%                 getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
%             flag=false;
%             return
%         end
    end
end
EnumTimeUnits={'weeks', 'days', 'hours', 'minutes','seconds', 'milliseconds', 'microseconds', 'nanoseconds'};

if strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86')
    h.Handles.bar=waitbar(10/100, ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ImportingTimeSeriesObjectsPleaseWait')));
else
    h.Handles.bar=waitbar(10/100, ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ImportingTimeSeriesObjectsPleaseWait')), ...
        'WindowStyle','modal');
end
% -------------------------------------------------------------------------
% get time vector and remove blank points
% -------------------------------------------------------------------------
ind=get(h.Handles.COMBtimeSource,'Value');
if ind==1
    % from the same workspace variable
    % default
    SelectedRows=h.IOData.SelectedRows; %#ok<NASGU>
    SelectedColumns=h.IOData.SelectedColumns; %#ok<NASGU>
    % check blank time points, remove them if required, and get 'time' and
    % 'timeFormat'
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        ColStrValue=str2double(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        timeValue=dataOriginal(h.IOData.SelectedRows,ColStrValue);
        [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'column');
        if ~flag
            delete(h.Handles.bar);
            return;
        end
        SelectedRows=h.IOData.SelectedRows(SelectedIndex);
        SelectedColumns=h.IOData.SelectedColumns(h.IOData.SelectedColumns~=get(h.Handles.COMBtimeIndex,'Value'));            
        time=timeValue(SelectedIndex); %#ok<NASGU>
        h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'column',tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        % replace the stored time format with the selected time format
        % timeFormat=h.IOData.formatcell.columnIsAbsTime
        [time, timeFormat]=getTimeColumn(h,SelectedRows);
        if timeFormat>=0
            timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeSheetFormat,'Value'));
            %time=datestr(time,timeFormat);
            %time=mat2cell(time,ones(1,size(time,1)),size(time,2));
        end
    else
        % time vector is stored as a row
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        RowStrValue=str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        timeValue=dataOriginal(RowStrValue,h.IOData.SelectedColumns);
        [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'row');
        if ~flag
            delete(h.Handles.bar);
            return;
        end
        SelectedColumns=h.IOData.SelectedColumns(SelectedIndex);
        SelectedRows=h.IOData.SelectedRows(h.IOData.SelectedRows~=get(h.Handles.COMBtimeIndex,'Value'));            
        time=timeValue(SelectedIndex); %#ok<NASGU>
        h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'row',tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        % replace the stored time format with the selected time format
        % timeFormat=h.IOData.formatcell.rowIsAbsTime;
        [time,timeFormat]=h.getTimeRow(h.IOData.SelectedColumns);
        if timeFormat>=0
            timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeSheetFormat,'Value'));
            % time=datestr(time,timeFormat);
            % time=mat2cell(time,ones(1,size(time,1)),size(time,2));
        end
    end
    if isempty(time) 
        % errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:InvalidTimePoints')),...
        % getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')));
        flag=false;
        delete(h.Handles.bar);
        return;
    end
    % time pretreatment
%     if timeFormat>=0
%         if timeFormat==13 || timeFormat==14 || timeFormat==15 || timeFormat==16
%             [year,month,day,hour,minute,second]=datevec(time);
%             time=hour*3600+minute*60+second;
%         end
%     end
elseif ind==2
    % manual time vector
    SelectedRows=h.IOData.SelectedRows;
    SelectedColumns=h.IOData.SelectedColumns;
    if get(h.Handles.COMBuseFormat,'Value')==1
        % absolute date/time format
        % check start time
        try
            MatlabFormat=h.IOData.formatcell.matlabFormatString{get(h.Handles.COMBtimeManualFormat,'Value')};
            startTime=datestr(datenum(get(h.Handles.EDTtimeManualStart,'String')),MatlabFormat);
        catch me %#ok<NASGU>
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheStartTimeMustBeADateString')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check interval
        try
            interval=eval(get(h.Handles.EDTtimeManualInterval,'String'));
        catch me %#ok<NASGU>
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeIntervalMustBeANumericValue')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            delete(h.Handles.bar);
            flag=false;
            return
        end
        if isnan(interval)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeIntervalMustBeANumericValue')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check number of sample
        samples=str2double(get(h.Handles.EDTtimeManualEnd,'String'));
        if samples==0 || isnan(samples)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheLengthOfTimeSeriesIsZero')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        time=localGetAbsTimeArray(h,startTime,interval,samples,MatlabFormat);
        timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeManualFormat,'Value'));
    else
        % relative time
        % check start time
        startTime=str2double(get(h.Handles.EDTtimeManualStart,'String'));
        if isnan(startTime)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheStartTimeMustBeANumericValue')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check interval
        try
            interval=eval(get(h.Handles.EDTtimeManualInterval,'String'));
        catch me %#ok<NASGU>
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeIntervalMustBeANumericValue')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            delete(h.Handles.bar);
            flag=false;
            return
        end
        if isnan(interval)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeIntervalMustBeADoubleValue')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check number of sample
        samples=str2double(get(h.Handles.EDTtimeManualEnd,'String'));
        if samples==0 || isnan(samples)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheLengthOfTimeSeriesIsZero')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        time=(startTime:interval:startTime+interval*(samples-1));
        timeFormat=-1;
    end
elseif ind==3
    % time vector from a workspace variable
    if ~isempty(h.IOData.timeFromWorkspace)
        timeValue=h.IOData.timeFromWorkspace;
        timeFormat=h.IOData.timeFormatFromWorkspace;
        time=timeValue; %#ok<NASGU>
        SelectedRows=h.IOData.SelectedRows;
        SelectedColumns=h.IOData.SelectedColumns;
        if get(h.Handles.COMBdataSample,'Value')==1
            if length(timeValue)~=length(h.IOData.SelectedRows)
                % a sample is a row
                errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheLengthOfDataBlockIsNotCompatible')),...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
            [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'column');
            if ~flag
                delete(h.Handles.bar);
                return;
            end
            SelectedRows=h.IOData.SelectedRows(SelectedIndex);
            time=timeValue(SelectedIndex);
            % SelectedColumns=h.IOData.SelectedColumns(find(h.IOData.SelectedColumns~=get(h.Handles.COMBtimeIndex,'Value')));            
        else
            if length(timeValue)~=length(h.IOData.SelectedColumns)
                % a sample is a row
                errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheLengthOfDataBlockIsNotCompatible')),...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
            [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'row');
            if ~flag
                delete(h.Handles.bar);
                return;
            end
            SelectedColumns=h.IOData.SelectedColumns(SelectedIndex);
            time=timeValue(SelectedIndex);
            % SelectedRows=h.IOData.SelectedRows(find(h.IOData.SelectedRows~=get(h.Handles.COMBtimeIndex,'Value')));            
        end            
        if isempty(time)
            errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:InvalidTimesSelectedSelectAgain')),...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
            flag=false;
            delete(h.Handles.bar);
            return;
        end
        % time pretreatment
        if timeFormat>=0
            if timeFormat==13 || timeFormat==14 || timeFormat==15 || timeFormat==16
                [~,~,~,hour,minute,second]=datevec(time);
                time=hour*3600+minute*60+second;
            end
        end
    else
        flag=false;
        delete(h.Handles.bar);
        return;
    end
end
if ishandle(h.Handles.bar)      
   waitbar(40/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% get data block
% -------------------------------------------------------------------------
if iscell(dataOriginal)
    try
        data=cell2mat(dataOriginal(SelectedRows,SelectedColumns));
    catch me %#ok<NASGU>
        errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:DataMustContainNumericValuesOnly')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),...
            'modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
    if ~isnumeric(data) && ~islogical(data)
        errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:DataMustContainNumericValuesOnly')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
elseif isnumeric(dataOriginal) || islogical(dataOriginal)
    data=dataOriginal(SelectedRows,SelectedColumns);
else
    errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:DataMustContainNumericValuesOnly')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
    flag=false;
    delete(h.Handles.bar);
    return
end
if isempty(data)
    errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectedDataBlockIsEmpty')),...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
    flag=false;
    delete(h.Handles.bar);
    return
end
if ishandle(h.Handles.bar)      
   waitbar(70/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% sort based on time if it is relative time
% -------------------------------------------------------------------------
if isvector(time) && size(time,2)>1
    time = time';
end
if ~iscell(time)
    [time, sortindex]=sort(time);
    if get(h.Handles.COMBdataSample,'Value')==1
        % in the excel sheet, a sample is a row
        data=data(sortindex,:);
    else
        % in the excel sheet, a sample is a column
        data=data(:,sortindex);
    end
else
    try
    % get abs time in [year mon day hour min sec] format and sort them
        [~, sortindex] = sortrows(round(datevec(time,timeFormat)));
    catch me %#ok<NASGU>
        errordlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:VariableContainsTimeStringsWithAnInvalidFormatSpecifyA')),...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
        flag = false;
        delete(h.Handles.bar);
        return
    end
    if get(h.Handles.COMBdataSample,'Value')==1
        % in the excel sheet, a sample is a row
        time=time(sortindex,:);
        data=data(sortindex,:);
    else
        % in the excel sheet, a sample is a column
        time=time(sortindex,:);
        data=data(:,sortindex);
    end
end

% -------------------------------------------------------------------------
% check duplicated time points
% -------------------------------------------------------------------------
[~,~,tmp3]=unique(time);
index=diff(tmp3);
if sum(index==0)>0
    % duplicated time points exist
    ButtonDuplicated = questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheTimeVectorContainsDuplicatedTimePoints')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectTheLast')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectTheAverage')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')), ...
        getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectTheAverage')));
    drawnow;
    switch ButtonDuplicated
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectTheLast'))
            time=time([true;~(index==0)]);
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                data=data([~(index==0);true],:);
            else
                % in the excel sheet, a sample is a column
                data=data(:,[~(index==0);true]);
            end
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:SelectTheAverage'))
            time=time([true;~(index==0)]);
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                k=1;
                for i=1:length(index)
                    if index(i)==0
                        data(i+1,:)=(data(i,:)*k+data(i+1,:))/(k+1);
                        k=k+1;
                    else
                        k=1;
                    end
                end
                data=data([~(index==0);true],:);
            else
                % in the excel sheet, a sample is a column
                k=1;
                for i=1:length(index)
                    if index(i)==0
                        data(:,i+1)=(data(:,i)*k+data(:,i+1))/(k+1);
                        k=k+1;
                    else
                        k=1;
                    end
                end
                data=data(:,[~(index==0);true]);
            end
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort'))
            flag=false;
            delete(h.Handles.bar);
            return
    end
end
if ishandle(h.Handles.bar)      
    waitbar(80/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% create/update time series object(s)
% -------------------------------------------------------------------------
if get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleNEW
    % create timeseries object
    try
        if ~strcmp(ButtonSameName,getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace')))
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                ts=tsdata.timeseries(data,time,'Name',UserInputName,'IsTimeFirst',true);
            else
                % in the excel sheet, a sample is a column
                ts=tsdata.timeseries(data',time,'Name',UserInputName,'IsTimeFirst',true);
            end
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
            tstool(ts);
        else
            tsgui = tstool;
            ts = tsgui.Tsnode.getChildren('Label',UserInputName).Timeseries;
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                ts.init(data,time,'Name',UserInputName,'IsTimeFirst',true);
            else
                % in the excel sheet, a sample is a column
                ts.init(data',time,'Name',UserInputName,'IsTimeFirst',true);
            end
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
        end
    catch me
        errordlg(sprintf('%s\n\n%s',getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ErrorInCreatingTimeSeriesObject')),me.message),...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
elseif get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleINSERT
    % get the timeseries object from the gui
    tsgui = tstool;
    ts = tsgui.Tsnode.getChildren('Label',UserInputName).Timeseries;
    % check if the two time vectors are the same: if they are the same
    % then insert data, if they are not the same size, abort the
    % operation, if they have the same size but not the same value, ask
    % user which time vector to choose
    try
        tsTime=ts.getAbsTime;
    catch %#ok<CTCH>
        tsTime=ts.time;
    end
    if length(tsTime)==length(time)
        % time vector has the same size, now compare values
        if isequal(tsTime,time)
            % same time vector
            ButtonName = getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheOldTimeVector'));
        else
            % two time vectors have different values
            ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheNewTimeVectorHasADifferentLength')), ...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheOldTimeVector')), ...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheNewTimeVector')), ...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')), ...
                getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheOldTimeVector')));
        end
    else
        % time vector has different sizes
        ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TheNewTimeVectorIsDifferentFromTheOld')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort')), ...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace')));
    end
    drawnow;
    
    % create timeseries object
    switch ButtonName,
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheOldTimeVector'))
            %
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:UseTheNewTimeVector'))
            tmpdata=ts.data;
            [time, tmpIndex]=sort(time);
            if get(h.Handles.COMBdataSample,'Value')==2
                data=data(:,tmpIndex);
            else
                data=data(tmpIndex,:);
            end
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            ts.init(tmpdata,time);
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Replace'))
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            ts.init(data,time);
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
            flag=true;
            delete(h.Handles.bar);
            return
        case getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:Abort'))
            flag=false;
            delete(h.Handles.bar);
            return;
    end
    if ts.IsTimeFirst
        % in the existing timeseries, a sample is a row
        if get(h.Handles.COMBdataSample,'Value')==2
            % in the excel sheet, a sample is a column
            ts.data=[ts.data data'];
        else
            % in the excel sheet, a sample is a row
            ts.data=[ts.data data];
        end
    else
        % in the existing timeseries, a sample is a column
        if get(h.Handles.COMBdataSample,'Value')==2
            % in the excel sheet, a sample is a column
            data=reshape(data,[size(data,1) 1 size(data,2)]);
            ts.data=cat(1,ts.data,data);
        else
            % in the excel sheet, a sample is a row
            data=data';
            data=reshape(data,[size(data,1) 1 size(data,2)]);
            ts.data=cat(1,ts.data,data);
        end
    end
else
    failed_count=0;
    % multiple timeseries
    if get(h.Handles.COMBdataSample,'Value')==2
        % a sample is a column
        for i=1:length(SelectedRows)
            % save timeseries
            try
                if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
                    % use a row or column as timeseries name
                    tmpName=dataOriginal(i,UserInputName);
                    if iscell(tmpName)
                        tmpName=cell2mat(tmpName);
                    end
                    if ~ischar(tmpName) %|| ~isvarname(tmpName)
                        failed_count=failed_count+1;
                        continue;
                    end
                else
                    tmpName=strcat(UserInputName,num2str(i));
                end
                if get(h.Handles.COMBdataSample,'Value')==2
                    % a sample is a column, use gridfirst=false
                    ts=tsdata.timeseries(data(i,:),time,'Name',tmpName,'IsTimeFirst',false);
                else
                    % a sample is a row, use gridfirst=true
                    ts=tsdata.timeseries(data(i,:),time,'Name',tmpName,'IsTimeFirst',true);
                end
                if timeFormat>=0
                    if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                    else
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                    end
                elseif timeFormat==-1
                    if ind == 1
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                    elseif ind ==2
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                    elseif ind ==3
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                    end
                end
                tstool(ts);
            catch me
                errordlg(sprintf('%s\n\n%s',getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ErrorInCreatingTimeSeriesObject')),me.message),...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
        end
    else
        % a sample is a row
        for j=1:length(SelectedColumns)
            % for each measurement
            % get data
            try
                if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
                    % use a row or column as timeseries name
                    tmpName=dataOriginal(UserInputName,j);
                    if iscell(tmpName)
                        tmpName=cell2mat(tmpName);
                    end
                    if ~ischar(tmpName) %|| ~isvarname(tmpName)
                        failed_count=failed_count+1;
                        continue;
                    end
                else
                    % use the given name + suffix as the timeseries name
                    tmpName=strcat(UserInputName,num2str(j));
                end
                if get(h.Handles.COMBdataSample,'Value')==2
                    % a sample is a column, use gridfirst=false
                    ts=tsdata.timeseries(data(:,j),time,'Name',tmpName,'IsTimeFirst',false);
                else
                    % a sample is a row, use gridfirst=true
                    ts=tsdata.timeseries(data(:,j),time,'Name',tmpName,'IsTimeFirst',true);
                end
                if timeFormat>=0
                    if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                    else
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                    end
                elseif timeFormat==-1
                    if ind == 1
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                    elseif ind ==2
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                    elseif ind ==3
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                    end
                end
                tstool(ts);
            catch me
                errordlg(sprintf('%s\n\n%s',getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:ErrorInCreatingTimeSeriesObject')),me.message),...
                    getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
        end
    end
    if failed_count>0
        msgbox(getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:NotAllDataWasImported')),...
            getString(message('MATLAB:timeseries:tsguis:workspaceImportdlg:TimeSeriesTools')),'modal');
    end
end
if ishandle(h.Handles.bar)      
   waitbar(100/100,h.Handles.bar);
end
%populate combobox with current timeseries objects in the base workspace
tsgui = tstool;
%alltsobjects = get(tsgui.Tsnode.getChildren,{'Timeseries'});
G = tsgui.TSnode.getChildren;
alltsobjects = {};
for k = 1:length(G)
    if strcmp(class(G(k)),'tsguis.tsnode')
        alltsobjects{end+1} = G(k).Timeseries; %#ok<AGROW>
    end
end
if ~isempty(alltsobjects)
    strCell={};
    for i=1:length(alltsobjects)
        strCell=[strCell;{alltsobjects{i}.Name}]; %#ok<AGROW>
    end
else
    strCell={''};
end
set(h.Parent.Handles.COMBsingleINSERT,'String',strCell,'Value',1);
flag=true;

delete(h.Handles.bar);

function array=localGetAbsTimeArray(h,startTime,interval,samples,MatlabFormat)
% format 4, 5, 6, 
startValue=datevec(startTime,MatlabFormat);
switch h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeManualFormat,'Value'))
    case {0 13 14 21} 
        %'dd-mmm-yyyy HH:MM:SS' 'HH:MM:SS' 'HH:MM:SS PM' 'mmm.dd,yyyy HH:MM:SS'
%         endValue=startValue;
%         endValue(6)=endValue(6)+min(1,interval)*(samples-1);
%         allDateNum = datenum(startValue):min(1,interval)/86400:datenum(endValue);
%         array=datestr(allDateNum);
%         array=mat2cell(array,ones(1,size(array,1)),size(array,2));
        startValue=datenum(startValue);
        endValue=startValue+max(1,interval)*(samples-1)/86400;
        array=datestr(startValue:max(1,interval)/86400:endValue);
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
    case {1 2 6 22 23}
        endValue=startValue;
        endValue(3)=endValue(3)+interval*(samples-1);
        array=datestr(datenum(startValue):interval:datenum(endValue));
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
    case {15 16}
        endValue=startValue;
        endValue(5)=endValue(5)+interval*(samples-1);
        array=datestr(datenum(startValue):interval/1440:datenum(endValue));
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
end
