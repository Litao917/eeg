function addTs(h,ts,varargin)

% Copyright 2004-2012 The MathWorks, Inc.

import com.mathworks.mde.desk.*;
import com.mathworks.mwswing.*;
import com.mathworks.widgets.desk.*;  % Doesn't appear to be needed

if ~iscell(ts)
    ts = {ts};
end

if isempty(h.Plot) || ~ishandle(h.Plot) 
    viewpanel = tsguis.uitspanel('Parent',h.Figure,'Name', ...
        getString(message('MATLAB:timeseries:tsguis:tsxynode:TimeSeriesXyplot')),...
        'SelectionHighlight','off');
    h.Plot = tsguis.xyplot(viewpanel,1,1);
    h.Plot.Parent = h; %  Install parent
    viewpanel.Plot = h.Plot; % On-the-fly build of property editor needs a plot handle
end

%% If the 3rd arg is not either X or Y act as if it were not specified
if nargin>=3 && (~ischar(varargin{1}) || ~any(strcmpi(varargin{1},{'x','y'})))
    num = 2;
else
    num = nargin;
end
    
%% Add the new time series
if length(ts)==1
    % Case 1: Less than 2 time series added
    if (numel(h.Timeseries1)==0 && numel(h.Timeseries2)==0) || (num>=3 && ...
            strcmpi(varargin{1},'x') && numel(h.Timeseries2)==0) || (num>=3 && ...
            strcmpi(varargin{1},'y') && numel(h.Timeseries1)==0)
        if num>=3 && strcmpi(varargin{1},'y')
            h.Timeseries2 = ts{1};
        else
            h.Timeseries1 = ts{1};
        end
        % Update status text
        set(h.Handles.InitTXT, ...
            'String', getString(message('MATLAB:timeseries:tsguis:tsxynode:TheFollowingTimeSeriesObjectHasBeenLoaded', ts{1}.Name)));        

        % Resize the text by firing the resize callback
        resizefcn = get(ancestor(h.Plot.AxesGrid.Parent,'figure'),'ResizeFcn');
        feval(resizefcn{1},ancestor(h.Plot.AxesGrid.Parent,'figure'),[],resizefcn{2:end});
    %% Case 2: Two timeseries already there - ask which one to replace
    elseif num<=2 && (numel(h.Timeseries1)>0 && numel(h.Timeseries2)>0)
       ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsxynode:ReplaceWhichTimeSeries')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:TimeSeriesTools')), ...
                           ['' h.Timeseries1.Name '' ' '],['' h.Timeseries2.Name '' '  '], ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel')));
       switch ButtonName,
         case ['' h.Timeseries1.Name '' ' '], 
              h.Timeseries1 = ts{1};
         case ['' h.Timeseries2.Name '' '  '],
              h.Timeseries2 = ts{1};
         case getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel'))
              return
       end 
       h.Plot.addTs(h.Timeseries1,h.Timeseries2);
    %% Case 3: Put the time series in the missing spot and show
    else
       if num<=2 
           if numel(h.Timeseries1)==0
               h.Timeseries1 = ts{1};
           else
               h.Timeseries2 = ts{1};
           end
       else
           if strcmpi(varargin{1},'x')
               h.Timeseries1 = ts{1};
           else
               h.Timeseries2 = ts{1};
           end
       end
       % Hide status text
       set(h.Handles.InitTXT,'Visible','off')
       h.Plot.addTs(h.Timeseries1,h.Timeseries2);
    end
else
    if numel(h.Timeseries1)>0 || numel(h.Timeseries2)>0
       ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsxynode:ReplaceTimeSeries')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:TimeSeriesTools')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:OK')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel')), ...
                           getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel')));
       if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:tsxynode:Cancel')))
           return
       end
    end
    h.Timeseries1 = ts{1};
    h.Timeseries2 = ts{2};
    % Hide status text
    set(h.Handles.InitTXT,'Visible','off')
    h.Plot.addTs(h.Timeseries1,h.Timeseries2);    
end

%% Fire tschanged event to announce the change
h.send('tschanged',handle.EventData(h,'tschange'));

%% Refresh
if ~isempty(h.Plot) && ishandle(h.Plot) 
    h.maybeDockFig;
    drawnow % Figure must be fully rendered before plot is set visible.
    h.Plot.Visible = 'on';
    figure(ancestor(h.Plot.AxesGrid.Parent,'Figure'))   
end
h.setDropAdaptor(h.DropAdaptor);

