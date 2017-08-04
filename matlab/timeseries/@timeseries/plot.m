function varargout = plot(h,varargin)
%PLOT  Plot time series data
%
%   PLOT(TS) plot the timeseries data against its time using either
%   zero-order-hold or linear interpolation. If the interpolation behavior
%   of the timeseries data is 'zoh', a stair plot is generated, otherwise a
%   regular plot is created.
%
%   Timeseries events, if present, are marked in the plot using a red
%   circular marker.  
%
%   PLOT accepts the modifiers used by MATLAB's PLOT utility for numerical
%   arrays. These modifiers can be specified as auxiliary inputs for
%   modifying the appearance of the plot.
%
%   Examples:
%   plot(ts,'-r*') plots using a regular line with color red and marker '*'.
%   plot(ts,'ko','MarkerSize',3) uses black circular markers of size 3 to
%   render the plot.
%
%   See also PLOT, TIMESERIES, TIMESERIES/ADDEVENT
%

%   Copyright 2005-2013 The MathWorks, Inc.

if numel(h)~=1
    error(message('MATLAB:timeseries:plot:noarray'));
end

% Define variables
if isempty(h)
   error(message('MATLAB:timeseries:plot:emptyplot'))
end
dataContent = h.Data;
if ~isnumeric(dataContent) && ~islogical(dataContent)
    error(message('MATLAB:timeseries:plot:nonnumeric'));
end

if ~h.IsTimeFirst
    dataContent = h.Data;
    n = ndims(dataContent);
    if h.TimeInfo.Length>1
        dataContent = permute(dataContent,[n 1:n-1]);
        dataContent = dataContent(:,:);
    else
        dataContent = reshape(dataContent,[1 numel(dataContent)]);
    end        
end
Time = h.Time;
Data = squeeze(dataContent);
if isempty(Time) || isempty(Data)
    return
end

% 2d data only
if (~isnumeric(Data) && ~islogical(Data)) || ~ismatrix(Data)
    error(message('MATLAB:timeseries:plot:invaliddata'))
end

% Check for a specified axes
ax = [];
if nargin>=3
    paramNameI = find(cellfun('isclass',varargin(1:end-1),'char'));
    if ~isempty(paramNameI)
        for k=1:length(paramNameI)
            if strcmpi(varargin{paramNameI(k)},'parent')
                if ishandle(varargin{paramNameI(k)+1}) && ...
                        strcmpi(get(varargin{paramNameI(k)+1},'Type'),'axes')
                    ax = varargin{paramNameI(k)+1};
                end
                break;
            end
        end
    end
end
    

% Get current figure/axes
if isempty(ax)    
    f = gcf;
    if strcmp(get(f,'NextPlot'),'add')
        if isempty(get(f,'CurrentAxes'))
            set(f,'DefaultTextInterpreter','none');
            ax = axes('parent',f);        
        else
            ax = get(f,'CurrentAxes');
        end
    else
        set(f,'nextplot','replace','DefaultTextInterpreter','none');
        ax = axes('parent',f);
    end
 else
    f = ancestor(ax,'figure');
end

timeOffset = getappdata(ax,'timeOffset');
absTimeFlag = ~isempty(h.TimeInfo.StartDate) && ...
    (~strcmpi(get(ax,'NextPlot'),'add') || ~isempty(timeOffset));

% Enable the plot to show dates if this timeseries has an absolute time
% vector and if hold is on, all previous plotted timeseries had absolute 
% time vectors.
if absTimeFlag
    % If a new absolute time series is being superimposed on an existing
    % absolute time series, the new numeric time vector must be computed
    % relative the previous time vector start date.
    if isappdata(ax,'timeOffset') && strcmp(get(f,'NextPlot'),'add')
        timeOffset = getappdata(ax,'timeOffset');
        Time = tsunitconv('days',h.TimeInfo.Units)*Time+datenum(h.TimeInfo.StartDate)-...
            timeOffset;
    else
        timeOffset = datenum(h.TimeInfo.StartDate);
        Time = tsunitconv('days',h.TimeInfo.Units)*Time;
    end
    setappdata(ax,'timeOffset',timeOffset);
% If this timeseries does not have absolute times then clear the timeOffset
% appdata and set the xticklabelmode to auto to clear previous date labels.
elseif isappdata(ax,'timeOffset')
    rmappdata(ax,'timeOffset');
    set(ax,'xticklabelmode','auto');
end

% Cache the appdata when using MCOS objects since it will be overwritten by
% the newplot reset until G634046 is fixed.
if feature('HGUsingMATLABClasses')
    appdata = getappdata(ax);
end

% Show stairs when interp method is zoh  
if strcmpi(h.getinterpmethod,'zoh') && length(Time)>1 %stairs for single time sample errors out
    In = 'zoh';
    p = stairs(ax,Time,Data,varargin{:});
else
    In = 'linear';
    p = plot(ax,Time,Data,varargin{:});
end

% Restore the appdata cache when using MCOS objects since it will be 
% overwritten by the newplot reset until G634046 is fixed.
if feature('HGUsingMATLABClasses') && ~isempty(appdata)
    appdatafields = fieldnames(appdata);
    for k=1:length(appdatafields)
        setappdata(ax,appdatafields{k},appdata.(appdatafields{k}));
    end
end
        
% If possible, set the data sources for linked plots
tsInVarName = inputname(1);
if ~isempty(tsInVarName)
    for k=1:length(p)
        set(p(k),'XDataSource',[tsInVarName '.Time'],'YDataSource',...
            getcolumn([tsInVarName '.Data'],k,'expression','caller'));
    end
end

% Add a listener to update the datetick labels (modeled on @timeplot
% updatelims). Note datetick cannot be used because it does not take into
% account the length of the data labels.
if absTimeFlag && strcmp('auto',get(ax,'XTickMode')) && strcmp('auto',get(ax,'XTickLabelMode'))
    dateFormat = h.TimeInfo.Format;
    if isempty(dateFormat)
        formatStr = 'dd-mmm-yyyy HH:MM:SS';
    else
        formatStr = dateFormat;
    end
    
    if feature('HGUsingMATLABClasses')
        createXDateRuler(ax,timeOffset,formatStr);
    else
        % If this is the first absolute time plot, listeners need to be added
        % to update the xticklabels.
        if ~strcmpi(get(ax,'NextPlot'),'add')
            localUpdateXticks(ax,formatStr,timeOffset);
            if isempty(getappdata(ax,'DateResizeListener')) || ...
                     ~ishandle(getappdata(ax,'DateResizeListener'))
                delete(getappdata(ax,'DateResizeListener'));
            end
            % Figure resize listener ensures that dateticks do not get visually
            % compressed.
            setappdata(ax,'DateResizeListener',...
                handle.listener(handle(ancestor(ax,'figure')),'ResizeEvent',...
                    @(es,ed) localUpdateXticks(ax,formatStr,timeOffset)));
            % LimitsListener ensures that changing the time vector for linked
            % plots resets the data ticks (g482390)
            setappdata(ax,'LimitsListener',...
                handle.listener(handle(ax),findprop(handle(ax),'XLim'),...
                'PropertyPostSet',@(es,ed) localUpdateXticks(ax,formatStr,timeOffset)));
        end
    end
elseif feature('HGUsingMATLABClasses')
     resetXRuler(ax);
elseif ~isempty(getappdata(ax,'DateResizeListener')) && ...
        ishandle(getappdata(ax,'DateResizeListener'))
        delete(getappdata(ax,'DateResizeListener'));
        rmappdata(ax,'DateResizeListener')
end

% Add listeners to XTickLabelMode and XTickMode to reset the XRuler
% when transitioning back to XTickLabelMode, XTickMode auto
if absTimeFlag && feature('HGUsingMATLABClasses')
    if ~isprop(ax,'TickModeListeners')
        tickModeListenersProp = addprop(ax,'TickModeListeners');
        tickModeListenersProp.Transient = true;
        tickModeListenersProp.Hidden = true;
    end
    ax.TickModeListeners = [...
        event.proplistener(ax,ax.findprop('XTickLabelMode'),'PostSet',@(e,d) localUpdatedateRuler(ax));...
        event.proplistener(ax,ax.findprop('XTickMode'),'PostSet',@(e,d) localUpdatedateRuler(ax))];
end

% Disable resizing when printing to avoid differences between the 
% print fonts size and the axes font size from compressing the 
% XTickLabels 
if ~feature('HGUsingMATLABClasses')
    printBehavior = getappdata(ax,'PrintBehavior');
    if isempty(printBehavior)
        printBehavior = hggetbehavior(ax,'Print');
        printBehavior.Serialize = false;
        printBehavior.PrePrintCallback = {@localEnableResize 'off'};
        printBehavior.PostPrintCallback = {@localEnableResize 'on'};
        setappdata(ax,'PrintBehavior',printBehavior);
    end
end

% Add xlabel, if one has not been specified
existingXLabelStr = get(get(ax,'xlabel'),'String');
if isempty(existingXLabelStr)
    if ~absTimeFlag
        stringTime = getString(message('MATLAB:timeseries:plot:Time'));
        xlabel(ax,sprintf('%s (%s)', stringTime, h.TimeInfo.Units));
    elseif ~feature('HGUsingMatlabClasses') % Xlabel does not show for custom ruler
        xlabel(ax, getString(message('MATLAB:timeseries:plot:Time')));
    end
else
    xlabel(ax,' ');
end

% Add y label if one has not be specified
dataUnits = h.DataInfo.Units; 
if isempty(dataUnits)
    ystr = h.Name;
    if isempty(ystr)
        ystr = 'data';
    end
else
    ystr = sprintf('%s (%s)',h.Name,dataUnits);
end
existingYLabelStr = get(get(ax,'ylabel'),'String');
if isempty(existingYLabelStr)
    ylabel(ax,ystr);
else
    ylabel(ax,' ');
end

% Add a title if one has not be specified
existingTitle = get(get(ax,'title'),'String');
if isempty(existingTitle)
    strTimeSeriesPlot = getString(message('MATLAB:timeseries:plot:TimeSeriesPlot'));
    title(ax,sprintf('%s:%s', strTimeSeriesPlot, h.Name))
else
    title(ax,' ')
end
    
% Annotate events
ev = [];
evnames = {};
E = h.Events;
if ~isempty(E)
    for k = 1:length(E)
        evtime = [];
        
        if absTimeFlag && ~isempty(E(k).StartDate)
            evtime = E(k).Time*tsunitconv('days',E(k).Units)+...
                datenum(E(k).StartDate)-datenum(h.TimeInfo.StartDate);
        elseif ~absTimeFlag && isempty(E(k).StartDate)
            evtime = E(k).Time*tsunitconv(h.TimeInfo.Units,E(k).Units);
        end
        if ~isempty(evtime) && evtime>=Time(1) && evtime<=Time(end)
              ev(end+1) = evtime; %#ok<AGROW>
              evnames{end+1} = E(k).Name; %#ok<AGROW>
        end        
    end
    if ~isempty(ev)
        cachedNextPlot = get(ax,'NextPlot');
        set(ax,'NextPlot','add');
        Inp = h.DataInfo.Interpolation;
        try % Object Data arrays (e.g.fi) may not support interpolation
             evdata = Inp.interpolate(Time,Data,ev,[],~h.hasduplicatetimes);
        catch %#ok<CTCH>
             evdata = Inp.interpolate(Time,double(Data),ev,[],~h.hasduplicatetimes);
        end
        if isscalar(ev)
            ev = repmat(ev,size(evdata'));
        end
        evMarkers = plot(ax,ev,evdata,'ro',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r');
        p = [p;evMarkers];
        for k=1:numel(evMarkers)
            bh = hggetbehavior(evMarkers(k),'datacursor');
            bh.UpdateFcn = @eventtipfcn;
            hasbehavior(double(evMarkers(k)),'legend',false)
            setappdata(evMarkers(k),'EventNames',evnames);
            setappdata(evMarkers(k),'EventTimes',ev);
            setappdata(evMarkers(k),'EventDataTipCache',bh);
        end       
        set(ax,'NextPlot',cachedNextPlot);      
    end
end

if nargout>0
    varargout{1} = p;
end

function localUpdateXticks(ax,formatStr,timeOffset)

% Figure resize callback which modifies the default ticks to datestrs when
% the time vector is absolute

fig = ancestor(ax,'figure');
container = ancestor(ax,'uicontainer');
if isempty(container)
    container = fig;
end

figpos = hgconvertunits(fig,get(container,'Position'),get(container,'Units'),'pixels',container);

% Use the first axes to estimate the number of date labels which will fit  
axpos = hgconvertunits(fig,get(ax,'Position'),get(ax,'Units'),'normalized',container);
pixelsize = figpos.*axpos;
Hfontsize = get(ax,'FontSize')/1.5; 
labelwidth = (length(formatStr)+2)*Hfontsize;
% Round up number of labels since the end positions extend half way beyond
% the axes
numlabels = max(1,ceil(pixelsize(3)/labelwidth));

% Create time vector of datestrs
xlims = get(ax,'xlim');
% Round the tForLabels to the nearest second so that the labels generated  
% by datestr (below) generate an exact match between the label and tForLabels 
tForLabels = unique(round(1440*60*(linspace(xlims(1),xlims(2),numlabels)+timeOffset))/(1440*60));
try
    tstr = datestr(tForLabels,formatStr);
catch %#ok<CTCH> % Deal with invalid Date formats   
    labelwidth = (length('dd-mmm-yyyy HH:MM:SS')+2)*Hfontsize;
    numlabels = max(1,ceil(pixelsize(3)/labelwidth));
    tForLabels = linspace(xlims(1)+timeOffset,xlims(2)+timeOffset,numlabels);
    tstr = datestr(tForLabels,'dd-mmm-yyyy HH:MM:SS');
end

% Overwrite the xticks with the new labels
if strcmpi(get(ax(end),'xtickmode'),'auto') || ...
   ~isappdata(ax(end),'tsplotxticklabel') || ~isappdata(ax(end),'tsplotxtick') || ...
   (isequal(getappdata(ax(end),'tsplotxticklabel') ,get(ax(end),'xticklabel')) && ...
   isequal(getappdata(ax(end),'tsplotxtick') ,get(ax(end),'xtick')))
        xticks = tForLabels-timeOffset;
        set(ax(end),'xticklabel',tstr,'xtick',xticks);
        setappdata(ax(end),'tsplotxticklabel',tstr);
        setappdata(ax(end),'tsplotxtick',xticks);
end

function output_txt = eventtipfcn(obj,event_obj) %#ok<INUSL>
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
evnames = getappdata(event_obj.Target,'EventNames');
evtimes = getappdata(event_obj.Target,'EventTimes');
[~,ind] = min(abs(evtimes-pos(1)));
strEvent=[getString(message('MATLAB:timeseries:plot:Event')) ':'];
strTime=[getString(message('MATLAB:timeseries:plot:Time')) ':'];
output_txt = {[strEvent ' ' evnames{ind(1)}],[strTime,' ',num2str(evtimes(ind(1)))]};

function localEnableResize(es,ed,state) %#ok<INUSL,INUSL>

L = getappdata(es,'DateResizeListener');
if ~isempty(L) && ishandle(L)
    L.enabled = state;
end

function localUpdatedateRuler(ax)

timeOffset = getappdata(ax,'timeOffset');
formatStr = 'dd-mmm-yyyy HH:MM:SS';
if strcmp('auto',ax.XTickMode) && strcmp('auto',ax.XTickLabelMode) && ...
        ~isa(ax.XRuler,'tsdata.DateRuler')
    createXDateRuler(ax,timeOffset,formatStr); % Revert to DateRuler
elseif (~strcmp('auto',ax.XTickMode) || ~strcmp('auto',ax.XTickLabelMode)) && ...
        isa(ax.XRuler,'tsdata.DateRuler')
    currentTickLabelMode = ax.XTickLabelMode;
    currentTickMode = ax.XTickMode;
    resetXRuler(ax); % Revert to numeric ruler
    ax.XTickLabelMode = currentTickLabelMode;
    ax.XTickMode = currentTickMode;
end
