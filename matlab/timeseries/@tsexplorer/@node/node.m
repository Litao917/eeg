function this = node(varargin)
% NODE Constructor for @node class
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name
%
% Should not be used by clients. Instead subclass @node and write your own
% constructor. 

% Copyright 2004-2012 The MathWorks, Inc.

% Create class instance
this = tsexplorer.node;
%this.generic_listeners;

% Check input arguments
if nargin == 0 
  this.Label = getString(message('MATLAB:tsexplorer:node:node:NewChildNode'));
elseif nargin == 1
  this.Label = varargin{1};
elseif nargin == 2
  this.Label = this.createDefaultName( varargin{1}, varargin{2} );
else
  error(message('MATLAB:tsexplorer:node:node:noNodeName'))
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
