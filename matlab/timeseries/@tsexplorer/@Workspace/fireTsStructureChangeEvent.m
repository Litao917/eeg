function fireTsStructureChangeEvent(h,eventData,varargin)
% method to update path cache and send tsstructure change event in response
% to actions such as rename, add or delete node.
%
% Varargins to be supplied depend upon eventData.Action:
% eventData.Action : string specifying the type of operation
%       'all'    : Refresh the whole list (default, if unspecified)
%                  (no additional inputs required)
%       'add'    : A node was added
%                  varargin{1}: string for added node with full path
%                  varargin{2} (optional): location where new node name must
%                  be inserted. By default, a new name is inserted at the
%                  bottom of the h.TSPathCache cell array.
%       'remove' : A node was deleted
%                  varargin{1}: name, with full path, of the deleted node.
%       'rename' : A node was renamed
%                  varargin{1}: a cell array {old_name,new_name}. old_name is
%                  the name of the node before rename operation, and new_name
%                  is the name after the rename. Both names must contain the
%                  full path.
% if Varargins are not supplied, the cache is rebuilt ("all") option

%   Copyright 2005-2011 The MathWorks, Inc.

if nargin<2 || ~isa(eventData,'tsexplorer.tstreeevent')
    warning(message('MATLAB:tsexplorer:Workspace:fireTsStructureChangeEvent:invEventData'));
    return
end

if isempty(h.TSPathCache)
    h.updatePathCache('all'); %create a first cache
end

% first update the cache
h.updatePathCache(eventData,varargin{:});

%next, send the tsstructure event
h.send('tsstructurechange',eventData);
