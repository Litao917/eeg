function edit(view,h)

% Copyright 2004-2011 The MathWorks, Inc.
               

h.Listeners = handle.listener(view,view.findprop('TimeUnits'),'PropertyPreSet',...
                   {@localUpdateCharUnits view h});
               
%% Initialize prop editor
h.initialize(view)

%% Add panels
h.axespanel(view,'Y');
charlist = {getString(message('MATLAB:timeseries:tsguis:timeplot:Mean')),'tsguis.tsMeanData','tsguis.tsMeanView';...
            getString(message('MATLAB:timeseries:tsguis:timeplot:STD')),'tsguis.tsMeanData','tsguis.tsStdView';...
            getString(message('MATLAB:timeseries:tsguis:timeplot:Median')),'tsguis.tsMeanData','tsguis.tsMedianView'};
s = struct('charlist',{charlist},...
    'additionalDataProps',{{'Starttime','Endtime'}},'additionalDataPropDefaults',...
    {{'',''}},'additionalHeadings', ...
    {{getString(message('MATLAB:timeseries:tsguis:timeplot:StartTime')), ...
    getString(message('MATLAB:timeseries:tsguis:timeplot:EndTime'))}});
h.charpanel(view,s,@localParseTime);
view.timepnl(h);


function localUpdateCharUnits(es,ed,h,thispropedit)

%% Callback for changes in the plot time units which will update the
%% Start and End Times on the @timeplot char panel
updatechartable(h,thispropedit,tsunitconv(ed.NewValue,h.TimeUnits))

function outTime = localParseTime(h,thisTime)

%% Custom parser for processing absolute time/dates entered into the
%% char panel as start and end times

if strcmp(h.AbsoluteTime,'off')
    outTime = eval(thisTime,'[]');
    return
else % Convert abs data to rel time
    try
        outTime = tsunitconv(h.TimeUnits,'days')*...
            (datenum(thisTime,h.TimeFormat)-datenum(h.StartDate));
    catch
        try
            outTime = tsunitconv(h.TimeUnits,'days')*...
                (datenum(thisTime)-datenum(h.StartDate));
        catch
            outTime = []; % Empty signified error
        end
    end
end

