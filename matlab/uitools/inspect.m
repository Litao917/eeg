function [argout] = inspect(varargin)
%INSPECT Open the inspector and inspect object properties
%
%   INSPECT (h) edits all properties of the given object whose handle is h,
%   using a property-sheet-like interface.
%   INSPECT ([h1, h2]) edits both objects h1 and h2; any number of objects
%   can be edited this way.  If you edit two or more objects of different
%   types, the inspector might not be able to show any properties in common.
%   INSPECT with no argument launches a blank inspector window.
%
%   Note that "INSPECT h" edits the string 'h', not the object whose
%   handle is h.

%   Copyright 1984-2011 The MathWorks, Inc.

% error out if there is insufficient java support on this platform
error(javachk('jvm', getString(message('MATLAB:uitools:inspector:ThePropertyInspector'))));

import com.mathworks.mlservices.*;
nin = nargin;
vargin = varargin;
doPushToFront = true;
doAddDestroyListener = false;

%add selection listener but only in HG2 because Property Inspector gets
%selection events in scribeaxes.m in HG1
persistent selectionListener;

% 
if isempty(selectionListener)
    plotmgr = feval(graph2dhelper('getplotmanager'));
    selectionListener = handle.listener(plotmgr,'PlotSelectionChange',@localChangedSelectedObjects);
end


if nargin==1
    if ischar(vargin{1})
        switch(vargin{1})
            case '-close'
                MLInspectorServices.closeWindow;
                return; 
            case '-isopen'
                argout = MLInspectorServices.isInspectorOpen;
                return;
        end
    end

elseif nargin>=2
    if ischar(vargin{1})

        switch(vargin{1})

            % For debugging
            % Remove this syntax entirely in 11 A release
            case 'newinspector'
                warning(message('MATLAB:uitools:inspector:InvalidSyntax'));
                return

            % For debugging
            % Remove this syntax entirely after 7B release
            case 'newtreetable'
                warning(message('MATLAB:uitools:inspector:InvalidTreeTableSyntax'));
                return
                
            % For debugging
            case 'desktopclient'
                if strcmp(varargin{2},'on')
                    com.mathworks.mde.inspector.Inspector.setDesktopClient(true);
                elseif strcmp(varargin{2},'off')
                    com.mathworks.mde.inspector.Inspector.setDesktopClient(false);
                end
                return
                
            % For debugging
            case 'autoupdate'
                if strcmp(varargin{2},'on')
                    com.mathworks.mde.inspector.Inspector.setAutoUpdate(true);
                elseif strcmp(varargin{2},'off')
                    com.mathworks.mde.inspector.Inspector.setAutoUpdate(false);
                end
                return
                
            % Called by the inspector Java code
            case '-getInspectorPropertyGrouping'
                obj = varargin{2};
                argout = localGetInspectorPropertyGrouping(obj);
                return;
            
            % Called by the inspector Java code    
            case '-hasHelp'
                obj = varargin{2};
                argout = localHasHelp(obj);
                return;
                
            % Called by the inspector Java code    
            case '-showHelp'
                if length(varargin)>=3
                   obj = varargin{2};
                   propname = varargin{3};
                   localShowHelp(obj,propname);
                end
                return;
                
        end % Switch
        
    elseif ischar(vargin{2})
        switch(vargin{2})
            case '-ifopen'
                if (MLInspectorServices.isInspectorOpen)
                    % prune off string
                    nin = 1;
                    doPushToFront = false;
                else
                    return;
                end
        end
    end
end

switch nin

    case 0
        % Show the inspector.
        MLInspectorServices.invoke;

    case 1
        obj = vargin{1};
        
        
        % inspect([])
        if isempty(obj)
            hdl = []; 
        
        % inspect(java.lang.String)    
        elseif all(isjava(obj))
            hdl = [];
            
        % inspect(gcf)
        elseif all(ishghandle(obj)) || (all(isa(obj, 'handle') && all(isobject(obj)) && all(isvalid(obj))) ...
            || all(ishandle(obj)))

            % Check that the input handles are valid, ignore output for now.
            graphicsversion(obj,'handlegraphics');

            if isobject(obj) && ~all(arrayfun(@(x) isa(x, 'JavaVisible'),obj))
                error(message('MATLAB:uitools:inspector:invalidobject'));
            end
            
            hdl = obj;
            
        else
            error(message('MATLAB:uitools:inspector:invalidinput'));
        end
        
        if ~isempty(hdl)
            len = builtin('length',hdl);
            if len == 1
                 if len == 1 && ~isa(obj, 'handle')
                    % obj has value semantics so do not make a copy that was
                    % made from hdl = obj(...)
                    obj = requestJavaAdapter(obj);
                else
                    obj = requestJavaAdapter(hdl);
                end
                if ~localIsUDDObject(obj)
                   doAddDestroyListener = true;
                end
                MLInspectorServices.inspectObject(obj,doPushToFront);
            else
                obj = requestJavaAdapter(hdl);
                if ~localIsUDDObject(obj)
                    doAddDestroyListener = true;
                end
                MLInspectorServices.inspectObjectArray(obj,doPushToFront);
            end
            
            if doAddDestroyListener
                % Listen to when the object gets deleted and remove
                % from inspector. A persistent variable is used since
                % the inspector is a singleton. If we do go away from
                % a singleton then this will have to be stored elsewhere.
                persistent deleteListener; %#ok
                hobj = handle(hdl);
                deleteListener = handle.listener(hobj, 'ObjectBeingDestroyed', ...
                    {@localObjectRemoved, obj, MLInspectorServices.getRegistry});
            end

        else
            % g512786 This is necessary because inrepreter does not
            % convert empty MCOS objects to null and this call would error
            % out. It worked fine for UDD objects because interpreter
            % converted them to null in this case. Pass in [] only for
            % MATLAB objects as returned by isobject(). For all other
            % objects including Java objects use obj reference.
            if isobject(obj)
                MLInspectorServices.inspectObject([],doPushToFront);
            else
                MLInspectorServices.inspectObject(obj,doPushToFront);
            end
        end

    otherwise
        % bug -- need to make java adapters for multiple arguments
        MLInspectorServices.inspectObjectArray(vargin,doPushToFront);
        

end



function localChangedSelectedObjects(~,eventData)

inspect(eventData.SelectedObjects, '-ifopen');

%----------------------------------------------------%
function localObjectRemoved(hSrc, event, obj, objRegistry) %#ok
% Used by original MWT Inspector implementation

objRegistry.setSelected({obj}, 0);

%----------------------------------------------------%
function bool = localIsUDDObject(h)
% Returns true if the input handles can be represented as a
% UDDObject in Java. We need to know this in order to determine
% whether or not we can add listeners on the Java side or the
% m-code side.
% 
% Example:
%    handle(0)                 Returns true 
%    handle(java.awt.Button)   Returns false

import com.mathworks.mlservices.*;
bool = false;
if isscalar(h)
   bool = MLInspectorServices.isUDDObjectInJava(h);
elseif isvector(h)
   bool = MLInspectorServices.isUDDObjectArrayInJava(h);  
end

%----------------------------------------------------%
function jhash = localGetInspectorPropertyGrouping(obj)

jhash = java.util.HashMap;

% For now, don't group multiple objects
if iscell(obj)
    obj = obj{1};
end

% Cast to a handle
if ~ishandle(obj)
    return
end
obj = handle(obj);
 
% Get grouping for this object
info = inspectGetGroupingHelper(obj);

% Convert to a hashtable
for n = 1:length(info)
   group_name = info{n}{1};
   prop_names = info{n}{2};
   for m = 1:length(prop_names);
      jhash.put(prop_names{m},group_name);
   end
end

%----------------------------------------------------%
function b = localHasHelp(hObj)
% Returns true if this instance has a property reference page

% For now, don't group multiple objects
if iscell(hObj)
    hObj = hObj{1};
end

% Defensive, remove try/catch after topic map API is stable 
try
    classname = localGetClassName(hObj);
    map = com.mathworks.mlwidgets.help.TopicMapLocator.getMapPath(classname);
    b = java.lang.Boolean(~isempty(map));
catch %#ok<CTCH>
    b = java.lang.Boolean(false);
end

%----------------------------------------------------%
function localShowHelp(hObj,propname)
% Displays help for the supplied instance and property

% For now, don't group multiple objects
if iscell(hObj)
    hObj = hObj{1};
end

if ishandle(hObj) && ischar(propname)
    classname = localGetClassName(hObj);
    helpview(['mapkey:',classname],propname,'CSHelpWindow');
end

%----------------------------------------------------%
function classname = localGetClassName(hObj)
% Returns the full absolute class name for a supplied instance

classname = [];
if ishandle(hObj)
    hObj = handle(hObj);
    if ~isobject(hObj)
        hCls = classhandle(hObj);
        hPk = get(hCls,'Package');
        classname = [get(hPk,'Name'), '.',get(hCls,'Name')];
    else
        classname=class(hObj);
    end
end

    
