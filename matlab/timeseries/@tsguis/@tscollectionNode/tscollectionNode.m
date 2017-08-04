function this = tscollectionNode(varargin)
% tscollectionNode (for tscollection objects) constructor
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name
%

%   Author(s): Rajiv Singh
%   Copyright 2005-2011 The MathWorks, Inc.

% Create class instance
this = tsguis.tscollectionNode;
this.HelpFile = 'ts_collection_cpanel';

% Check input arguments
if nargin == 0 
  this.Label = getString(message('MATLAB:timeseries:tsguis:tscollectionNode:NewChildNode'));
elseif nargin == 1
  %this.Label = varargin{1};
  set(this,'Label',get(varargin{1},'Name'),'Tscollection',varargin{1})
elseif nargin == 2
  this.Label = this.createDefaultName( varargin{1}, varargin{2} );
else
  error(message('MATLAB:tsguis:tscollectionNode:tscollectionNode:noNode'))
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab','timeseries', ...
                          'arrayviewicon.gif');

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
