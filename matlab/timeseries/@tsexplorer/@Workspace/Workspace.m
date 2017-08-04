function this = Workspace(varargin)
% WORKSPACE Constructor for @Workspace object

% Copyright 2004-2012 The MathWorks, Inc.

% Create class instance
this = tsexplorer.Workspace;
this.generic_listeners;

% Check input arguments
if nargin >= 1
  this.Label = varargin{1};
else
  this.Label = getString(message('MATLAB:tsexplorer:Workspace:Workspace:Workspace'));
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab', 'timeseries', ...
                          'folder.gif');
% this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
% this.Status    = 'Default explorer node.';

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
