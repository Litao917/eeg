function varargout = tstool(varargin)
%TSTOOL Opens the Time Series Tools GUI.
% 
% V = TSTOOL returns the handle to the tsviewer.
% V = TSTOOL(OBJ) imports the object OBJ into the GUI. OBJ may be a
% timeseries or tscollection.


% If the GUI is already open, a handle to the viewer may be obtained by
% typing: 
%       V = tsguis.tsviewer 
% since the viewer object is a singleton.

% Copyright 2004-2013 The MathWorks, Inc.

%% Explorer GUI and UDD root node handles

error(message('MATLAB:timeseries:TstoolRemove'));

% Check for valid platform for Java Swing
if ~usejava('Swing')
  error(message('MATLAB:tstool:nojava'));
end
    
% Check for a valid viewer
TSVIEWER = tsguis.tsviewer;
wb = [];
if isempty(TSVIEWER.TreeManager) || ~ishandle(TSVIEWER.TreeManager) || ...
        isempty(TSVIEWER.TreeManager.Figure) || ~ishghandle(TSVIEWER.TreeManager.Figure)
        % Build the viewer
        wb = waitbar(0, ...
            getString(message('MATLAB:timeseries:InitializingTimeSeriesTools')),...
            'Name', ...
            getString(message('MATLAB:timeseries:TimeSeriesTools')));
        TSVIEWER.open(wb);
        % Select time series parent node
        TSVIEWER.TreeManager.reset;
        if nargin==0
            TSVIEWER.TreeManager.Tree.setSelectedNode(TSVIEWER.TreeManager.Root.down.getTreeNodeInterface);
        end
        drawnow; % Force the node to show selected
        TSVIEWER.TreeManager.Tree.repaint
end

%% Add the new time series
if nargin>0
    v = varargin{1};
    Varname = inputname(1);
    try
        if nargin>1 && ischar(varargin{2}) && strcmpi(varargin{2},'replace') %"replace" option has been specified
            msg = localCreateNewChild(TSVIEWER,v,Varname,'replace');
        else
            msg = localCreateNewChild(TSVIEWER,v,Varname);
        end
    catch me
        msg = me.message;
    end
    if ~isempty(msg)
        errordlg(getString(message('MATLAB:timeseries:InvalidInputArguments',msg)),...
            getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal');
        if ~isempty(wb)
          close(wb)
        end
%         if ishandle(TSVIEWER.TreeManager)
%             delete(TSVIEWER.TreeManager);
%         end
        return
    end
end

%% Show the tstool
if strcmp(TSVIEWER.TreeManager.Visible,'off')
    drawnow;
    set(TSVIEWER.TreeManager,'visible','on')
    % Force a resize on mac 10.5.5 to for work around in g504433  
    if ismac
        tempSize = get(TSVIEWER.TreeManager.Figure,'Position');
        tempSize = tempSize*1.01;
        set(TSVIEWER.TreeManager.Figure,'Position',tempSize);
    end    
end

% Update the path cache in the tree-manager root object:
TSVIEWER.TreeManager.Root.updatePathCache;

% If needed close the waitbar
if ~isempty(wb)
    close(wb)
end

% Lang workaround for returned persistent variables
if nargout==1
   varargout{1} = TSVIEWER;
end

% Bring the viewer to the front
figure(TSVIEWER.TreeManager.Figure);

%--------------------------------------------------------------------------
function  msg = localCreateNewChild(T,v,Varname,varargin)
% add a child based on a parent class

msg  = '';
   
if T.TSnode.isLegalChild(v)
    % varargin is not passed because "replace" is allowed only on Simulink
    % data objects.
    T.TSnode.createChild(v,Varname); 
else
    if iscell(v)
        msg = getString(message('MATLAB:timeseries:InvalidCellArray'));
    else
        msg = getString(message('MATLAB:timeseries:UnknownObjectType', 'timeseries', 'tscollection'));
    end
end
