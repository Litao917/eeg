function name = utExportTS(this,ts,filefullname,IsNewFile,SheetNames,bar,barmove)

%  Copyright 2004-2012 The MathWorks, Inc.

% create general info section
[data, name]=localGeneralInfo(IsNewFile,SheetNames,ts);

% write general info section
comWarnString = '';
comWarnState = warning('off','MATLAB:xlswrite:NoCOMServer');
try
    xlswrite(filefullname,data,name,'A1:B13');            
catch me %#ok<NASGU>
    comWarnString = getString(message('MATLAB:tsguis:allExportdlg:utExportTS:CouldNotWriteTimeseriesHeaderInfo'));               
end
if ishandle(bar)
   waitbar(barmove,bar);
end
% create data and time block
try
    block = [ts.getAbsTime num2cell(ts.data)];
catch me %#ok<NASGU>
    time = localCheckRelativeTime(ts);
    if iscell(time)
        block = [time num2cell(ts.data)];
    else
        block = [time ts.data];
    end
end
% Write data and time block
try
    range = strcat('A14:',[this.findcolumnletter(size(block,2)) num2str(size(block,1)+13)]);
    xlswrite(filefullname,block,name,range);
catch me
    name = localWriteFailure(bar,me.message);
    warning(comWarnState);
    return                
end
% if a new excel file, remove the default sheet
if IsNewFile
    utRemoveSheet123(this,filefullname,bar);
end

% Warn if write partly failed
[swarn,warnid] = lastwarn;
if strcmp(warnid,'MATLAB:xlswrite:NoCOMServer')
    strXLSWRITEReturnedWarning = getString(message('MATLAB:tsguis:allExportdlg:utExportTS:XLSWRITEReturnedWarning'));
    comWarnString = [comWarnString sprintf('%s: ',strXLSWRITEReturnedWarning) swarn];
end
if ~isempty(comWarnString)
    warndlg(comWarnString,getString(message('MATLAB:tsguis:allExportdlg:utExportTS:TimeSeriesTools')), 'modal');
end
warning(comWarnState);

function [data, name]=localGeneralInfo(IsNewFile,SheetNames,ts)

%1. generate time series meta information
data=cell(10,2);
data(1,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:TimeSeriesObjectName'))};
data(1,2)={ts.name};
data(2,1)={''};
data(2,2)={''};
data(3,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:TimeVectorCharacteristics'))};
data(3,2)={''};
data(4,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:Length'))};
data(4,2)={num2str(length(ts.time))};
% Time vector characteristics
if ~isempty(ts.timeInfo.Startdate)
    if tsIsDateFormat(ts.timeInfo.Format)
        data(5,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:StartDate'))};
        strStartTime=sprintf('%s',datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.Start+...
            datenum(ts.timeInfo.Startdate),ts.timeInfo.Format));
        data(5,2)={strStartTime};
        data(6,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:EndDate'))};
        strEndTime=sprintf('%s',datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.End+...
            datenum(ts.timeInfo.Startdate),ts.timeInfo.Format));   
        data(6,2)={strEndTime};
        data(7,1)={''};
        data(7,2)={''};
    else
        data(5,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:StartDate'))};
        strStartTime=sprintf('%s',datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.Start+...
            datenum(ts.timeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));
        data(5,2)={strStartTime};
        data(6,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:EndDate'))};
        strEndTime=sprintf('%s',datestr(tsunitconv('days',ts.timeInfo.Units)*ts.timeInfo.End+...
            datenum(ts.timeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));   
        data(6,2)={strEndTime};
        data(7,1)={''};
        data(7,2)={''};
    end
else
    data(5,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:StartTime'))};
    strStartTime=sprintf('%s  %s',num2str(ts.timeInfo.start),ts.timeInfo.units);
    data(5,2)={strStartTime};
    data(6,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:EndTime'))};
    strEndTime=sprintf('%s  %s',num2str(ts.timeInfo.end),ts.timeInfo.units);
    data(6,2)={strEndTime};
    if ~isempty(ts.timeInfo.Startdate)
        data(7,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:ReferenceStartDate'))};
        data(7,2)={ts.timeInfo.Startdate};
    else
        data(7,1)={''};
        data(7,2)={''};
    end
end    
data(8,1)={''};
data(8,2)={''};
data(9,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:DataCharacteristics'))};
data(9,2)={''};
data(10,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:InterpolationMethod'))};
data(10,2)={ts.DataInfo.Interpolation.Name};
data(11,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:SampleSize'))};
data(11,2)={num2str(getdatasamplesize(ts))};
data(12,1)={''};
data(12,2)={''};
data(13,1)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:Time'))};
data(13,2)={getString(message('MATLAB:tsguis:allExportdlg:utExportTS:Data'))};

%2 generate sheet name
name = ts.name;
i=1;
if ~IsNewFile
    while ismember(name,SheetNames) 
        name = [ts.name num2str(i)];
        i=i+1;
    end
end


function val = localWriteFailure(bar,errmsg)
strErrorWritingToExcelWorkbook = getString(message('MATLAB:tsguis:allExportdlg:utExportTS:ErrorWritingToExcelWorkbook'));
errordlg(sprintf('%s :\n\n%s',strErrorWritingToExcelWorkbook,errmsg),getString(message('MATLAB:tsguis:allExportdlg:utExportTS:TimeSeriesTools')),'modal');
delete(bar);
val = [];


function timeout=localCheckRelativeTime(ts)
DateVector=datevec(now);
DateVector=repmat(DateVector,length(ts.time),1);
a=floor(ts.time/3600);
DateVector(:,4)=a;
b=floor((ts.time-a*3600)/60);
DateVector(:,5)=b;
c=ts.time-a*3600-b*60;
DateVector(:,6)=c;
if strcmp(ts.timeinfo.format,'HH:MM:SS')
    timeout=mat2cell(datestr(DateVector,13),ones(length(ts.time),1));
elseif strcmp(ts.timeinfo.format,'HH:MM:SS PM')
    timeout=mat2cell(datestr(DateVector,14),ones(length(ts.time),1));
elseif strcmp(ts.timeinfo.format,'HH:MM')
    timeout=mat2cell(datestr(DateVector,15),ones(length(ts.time),1));
elseif strcmp(ts.timeinfo.format,'HH:MM PM')
    timeout=mat2cell(datestr(DateVector,16),ones(length(ts.time),1));
else
    timeout=ts.time;
end
        


