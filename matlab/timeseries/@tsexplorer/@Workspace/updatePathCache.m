function updatePathCache(h,ed,varargin)

% Copyright 2004-2011 The MathWorks, Inc.

%updatePathCache method on root node updates the list containing the names
%with full paths of all the tsnodes at all levels beneath the TSNode,
%Updates the property 'TSPathCache' of @tsviewer.
%
% This method should be called when:
% (1) at the time of initialization of GUI.
% (2) when a timeseries node is added or deleted.
% (3) when the name of any node is changed.
%
% ed: eventdata of type tsexplorer.tstreeevent.
%
% See also: tsexplorer.node.constructNodePath.

% FYI:
% ed.Action info: this is a string specifying the type of operation
%       'all' : Refresh the whole list (default, if unspecified)
%       'add' : A node was added
%               varargin{1}: string for added node with full path
%               varargin{2} (optional): location where new node name must
%               be inserted. By default, a new name is inserted at the
%               bottom of the h.TSPathCache cell array.
%       'remove': A node was deleted
%               varargin{1}: name, with full path, of the deleted node.
%       'rename': A node was renamed
%               varargin{1}: a cell array {old_name,new_name}. old_name is
%               the name of the node before rename operation, and new_name
%               is the name after the rename. Both names must contain the
%               full path.

%   Copyright 2011 The MathWorks, Inc.

if nargin<3 %"all" case is the default
    %refresh the whole cache
    path1 = localGetNodeName(h.TsViewer.TSnode);

    % expand into one cell array and store into
    h.TSPathCache = path1;
elseif strcmpi(ed.Action,'rename')
    v = varargin{1};
    oldname = v{1}; %name with full path!
    newname = v{2};
    h.TSPathCache = strrep(h.TSPathCache,oldname,newname);
elseif strcmpi(ed.Action,'remove')
    deletedNodePath = varargin{1};
    if ~ed.Node.AllowsChildren %this is a leaf node
        Ind = strcmp(deletedNodePath,h.TSPathCache);
        L = length(h.TSPathCache);
        h.TSPathCache = h.TSPathCache(setdiff(1:L,Ind));
    else
        % Delete entry for all children of this node
        % this need not be uniquely determined if there are two container
        % nodes of different types at the same level w.r.t parent. Since
        % this cannot happen in the tstool right now, the following could
        % work:
        %>> Ind = strmatch([deletedNodePath,'/'],h.TSPathCache);
        %
        % However, a safer approach is to rebuild the cache, excluding the
        % node being deleted:
        
        %node being deleted is a MATLAB time series node
        path1 = localUpdateCacheOnDeletion(h.TsViewer.TSnode,ed.Node);

        % expand into one cell array and store into
        h.TSPathCache = path1;
        return;
    end
elseif strcmpi(ed.Action,'add')
    newNodepath = varargin{1}; %string representing the added node path
    L = length(h.TSPathCache);
    if ~ed.Node.AllowsChildren %this is a leaf node
        if nargin>3
            Locn = varargin{2}; %location (integer index) where string newNodepath should be inserted
            if ~(Locn>=1 && Locn<=(L+1))
                error(message('MATLAB:tsexplorer:Workspace:updatePathCache:InvalidInsertionIndex', 1, L + 1));
            end
            h.TSPathCache = {h.TSPathCache{1:Locn-1},newNodepath,h.TSPathCache{Locn+1:end}};
        else
            h.TSPathCache = {h.TSPathCache{:},newNodepath}; %#ok<CCAT>
        end
    else
        %rebuild the cache
        h.updatePathCache;
        return;
    end

    h.TSPathCache = h.TSPathCache(:);
end

%--------------------------------------------------------------------------
function thispath = localGetNodeName(node)
% return immediate children names for the node as a cell array

ownname = node.Label;
thispath = {};
if node.AllowsChildren
    c = node.getChildren;
    for k = 1:length(c)
        childnames = localGetNodeName(c(k));
        %thispath{k} = [ownname,'/',childname{:}];
        for n = 1:length(childnames)
            thispath{end+1} = [ownname,'/',childnames{n}]; %#ok<AGROW>
        end
    end
else
    thispath = {ownname};
end

%--------------------------------------------------------------------------
function thispath = localUpdateCacheOnDeletion(node,delnode)
%delnode: node being deleted
%node: parent node: @tsparentnode

ownname = node.Label;
thispath = {};
if isequal(node,delnode)
    return
elseif node.AllowsChildren
    c = node.getChildren;
    for k = 1:length(c)
        childnames = localUpdateCacheOnDeletion(c(k),delnode);
        if ~isempty(childnames)
            for n = 1:length(childnames)
                thispath{end+1} = [ownname,'/',childnames{n}]; %#ok<AGROW>
            end
        end
    end
else
    thispath = {ownname};
end
