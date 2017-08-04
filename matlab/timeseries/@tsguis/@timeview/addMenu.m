function addMenu(h, tplot, menutype)

% Copyright 2004-2012 The MathWorks, Inc.

%% Get the right label and callback
if strcmp(menutype,'delete')
    propval = {'Label', ...
        getString(message('MATLAB:timeseries:tsguis:timeview:ReplaceWithNaNs')), ...
        'Callback',...
        @(es,ed) delselection(tplot)};
elseif strcmp(menutype,'remove')
    propval = {'Label', ...
        getString(message('MATLAB:timeseries:tsguis:timeview:RemoveObservations')), ...
        'Callback',...
        @(es,ed) rmselection(tplot)};
elseif strcmp(menutype,'keep')
    propval = {'Label', ...
        getString(message('MATLAB:timeseries:tsguis:timeview:KeepObservations')), ...
        'Callback',...
        @(es,ed) rmselection(tplot,'complement')};
elseif strcmp(menutype,'newevent')
    propval = {'Label',...
        getString(message('MATLAB:timeseries:tsguis:timeview:AddNewEvent')), ...
        'Callback', ...
        {@localAddEvent h tplot},'Separator','on'};    
else
    return
end

%% Install uimenu on to selected curve's context menu    
if isempty(h.Menu.(menutype))
    for k=1:numel(h.SelectionCurves)
        h.Menus.(menutype) = [h.Menus.(menutype); uimenu(propval{:},...
            'Parent',get(h.SelectionCurves(k),'Uicontextmenu'))];
    end
    
    %% Install uimenu on time selection rectangle   
    
    if strcmp(menutype,'remove') || strcmp(menutype,'delete') || ...
            strcmp(menutype,'keep')
        for k=1:numel(h.SelectionCurves)
              h.Menus.(menutype) = [h.Menus.(menutype); uimenu(propval{:},...
                  'Parent',get(h.SelectionPatch(k),'Uicontextmenu'))]; 
        end
    end
end

function localAddEvent(eventSrc,~,view,tplot)

%% Create a new event
ind = find(cell2mat(get(tplot.waves,{'View'}))==view);
pos = get(get(eventSrc,'Parent'),'Userdata');
if strcmp(tplot.AbsoluteTime,'on')
    e = tsnewevent(datestr(pos(1,1)*tsunitconv('days',tplot.TimeUnits)+ ...
         datenum(tplot.StartDate)));
else
    e = tsnewevent(pos(1,1));
end


%% Add it to the selected time series
if ~isempty(e)
    % Convert the plot time unit to the timeseries time units
    thists = tplot.waves(ind).DataSrc.Timeseries;
    refdate = thists.TimeInfo.StartDate;
    if ~isempty(refdate)
        e.Time = (e.Time-datenum(refdate))*...
            tsunitconv(tplot.waves(ind).DataSrc.Timeseries.TimeInfo.Units,...
            'days');
    else
        e.Time = e.Time*tsunitconv(thists.TimeInfo.Units,tplot.TimeUnits);
    end
       
    % Create transaction
    T = tsguis.transaction;
    T.ObjectsCell = [T.ObjectsCell, {thists}];
    recorder = tsguis.recorder;

    % Update the list of events
    thists.addevent(e);
    
    % Record action
    if strcmp(recorder.Recording,'on')
        T.addbuffer(['%% ', getString(message('MATLAB:timeseries:tsguis:timeview:AddANewEvent'))]);
        T.addbuffer(tsParseBufferStr(e.Name,'e = tsdata.event(''#'',',e.Time,');'));
        T.addbuffer([genvarname(thists.Name) ' = addevent(', genvarname(thists.Name) ',e);'],thists);     
    end

    % Store transaction
    T.commit;
    recorder.pushundo(T);

    thists.send('datachange')
end

%% Popup the data selection mode since the event data tip will not select
%% properly in data selection mode
tplot.setselectmode('None')