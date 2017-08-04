function this = tsnode(varargin)
% NODE Constructor for @node class
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name
%
% Should not be used by clients. Instead subclass @node and write your own
% constructor. 

% Copyright 2004-2011 The MathWorks, Inc.

% Create class instance
this = tsguis.tsnode;
this.HelpFile = 'ts_cpanel';
                     
% Check input arguments
if nargin == 0 
  this.Label = getString(message('MATLAB:timeseries:tsguis:tsnode:TimeSeriesNode'));
elseif nargin == 1
  set(this,'Label',get(varargin{1}, 'Name'),'Timeseries',varargin{1})
else
  error(message('MATLAB:tsguis:tsnode:tsnode:noNode'))
end

this.AllowsChildren = false;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab', 'timeseries', ...
                           'data.gif');
% this.IsRoot    = true;
% this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
% this.Status    = 'Default explorer node.';

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;

%% Add event listeners
%this.event_listeners;