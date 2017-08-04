classdef Utility < handle
    % Base class for managing MCOS toolstrip component hierarchy.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods (Static)
        
        %% Matches property name against public property list.
        function PropName = matchProperty(InputStr,PublicProps)
            % Matches property name against public property list.
            %
            %   PROPERTY = MATCHPROPERTY(STR,PROPLIST,CL) performs a
            %   case-insensitive, partial matching of the string STR name
            %   against the list of properties PROPLIST for the class CL.
            %   If there is a unique match, PROPERTY contains the full name
            %   of the matching property. Otherwise, command fails.
            imatch = find(strncmpi(InputStr,PublicProps,length(InputStr)));
            
            % Get matching property name
            switch length(imatch)
                case 0
                    % No hit
                    error(message('MATLAB:toolstrip:general:unrecognizedProperty'))
                case 1
                    % Single hit
                    PropName = PublicProps{imatch};
                otherwise
                    % Multiple hits. Take shortest match provided it is contained
                    % in all other matches (Xlim and XlimMode as matches is OK, but
                    % InputName and InputGroup is ambiguous)
                    [minlength,imin] = min(cellfun(@length,PublicProps(imatch)));
                    PropName = PublicProps{imatch(imin)};
                    if ~all(strncmpi(PropName,PublicProps(imatch),minlength)),
                        error(message('MATLAB:toolstrip:general:ambiguousProperty',InputStr))
                    end
            end
        end
        
        %% Convert MATLAB data type to java data type when using peer model api
        function java_value = convertFromMatlabToJava(value)
            if ischar(value)
                java_value = convertStringToJava(value);
            elseif islogical(value)
                java_value = convertLogicalToJava(value);
            elseif isnumeric(value)
                java_value = convertNumericToJava(value);
            elseif iscell(value)
                ok = cellfun('isclass',value,'char');
                if all(ok(:))
                    java_value = convertCellStringToJava(value);
                else
                    error(message('MATLAB:toolstrip:general:invalidCellArray'));
                end
            elseif isstruct(value)
                java_value = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(value);
            else
                error(message('MATLAB:toolstrip:general:invalidDataType'));
            end
        end
        
        function hashmap = convertFromStructureToHashmap(structure)
            % convert structure (array) into hash map (array)
            if isempty(structure)
                % empty structure to empty arraylist
                hashmap = java.util.ArrayList();
            elseif isscalar(structure)
                % structure to hashmap
                hashmap = convertStructToHashmap_Scalar(structure);
            elseif isvector(structure)
                % structure array to hashmap array
                len = length(structure);
                hashmap = javaArray('java.util.HashMap',len);
                for ct=1:len
                    hashmap(ct) = convertStructToHashmap_Scalar(structure(ct));
                end
            else
                error(message('MATLAB:toolstrip:general:invalidArray'));
            end
        end
        
        %% Convert Java data type to MATLAB data type when using peer model api
        function value = convertFromJavaToMatlab(java_value)
            if isjava(java_value)
                classname = char(java_value.getClass().getCanonicalName());
                if ~isempty(strfind(classname,'java.util.ArrayList'))
                    % empty array list
                    value = {};
                elseif ~isempty(strfind(classname,'java.util.HashMap'))
                    % hash map
                    value = matlab.ui.internal.toolstrip.base.Utility.convertFromHashmapToStructure(java_value);
                    if isempty(value)
                        value = {};
                    end
                elseif ~isempty(strfind(classname,'java.lang.Double'))
                    for ct=1:length(java_value)
                        value(ct,1) = java_value(ct).doubleValue();
                    end
                elseif ~isempty(strfind(classname,'java.lang.Boolean'))
                    for ct=1:length(java_value)
                        value(ct,1) = java_value(ct).booleanValue();
                    end
                elseif ~isempty(strfind(classname,'java.lang.String'))
                    for ct=1:length(java_value)
                        value{ct,1} = char(java_value(ct));
                    end
                else
                    value = {};
                end
            else
                % already in matlab format
                value = java_value;
            end
        end
        
        function structure = convertFromHashmapToStructure(hashmap)
            % convert java hash map to structure
            if isempty(hashmap)
                % empty hashmap to empty struct
                structure = struct([]);
            else
                isarray = strfind(char(hashmap.getClass().getCanonicalName()),'[]');
                if isempty(isarray)
                    % hashmap to structure
                    structure = convertHashmapToStructure_Scalar(hashmap);
                elseif length(isarray)==1
                    % hashmap array to structure array
                    len = length(hashmap);
                    for ct=1:len 
                        structure(ct) = convertHashmapToStructure_Scalar(hashmap(ct));
                    end
                else
                    error(message('MATLAB:toolstrip:general:invalidArray'));
                end
            end
        end
        
        %% Process peer node property set data from the client side
        function eventdata = processPropertySetData(peerdata)
            % get event data
            hashmap = peerdata.getData();
            structure = matlab.ui.internal.toolstrip.base.Utility.convertFromHashmapToStructure(hashmap);
            % get property name
            structure.Property = getPropertyfromKey(structure.key);
            structure = rmfield(structure,'key');
            structure.NewValue = structure.newValue;
            structure = rmfield(structure,'newValue');
            structure.OldValue = structure.oldValue;
            structure = rmfield(structure,'oldValue');
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(structure);
        end
        
        %% Process peer node event data from the client side
        function eventdata = processPeerEventData(peerdata)
            % get event data
            hashmap = peerdata.getData();
            structure = matlab.ui.internal.toolstrip.base.Utility.convertFromHashmapToStructure(hashmap);
            % get event type and remove the "eventType" field
            structure.EventType = getEventfromKey(structure.eventType);
            structure = rmfield(structure,'eventType');
            % process additional data if it exists
            if isfield(structure, 'text')
                structure.Text = structure.text;
                structure = rmfield(structure,'text');
            end
            if isfield(structure, 'value')
                structure.Value = structure.value;
                structure = rmfield(structure,'value');
            end
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(structure);
        end

        %% Process property values during construction
        function [action_properties, widget_properties] = updateProperties(syntax, action_properties, widget_properties, varargin)
            ni = nargin-3;
            ni_str = num2str(ni);
            input = ['input' ni_str];
            if isfield(syntax, input) && ~isempty(syntax.(input))
                if ni==0
                    if syntax.(input)
                        return
                    else
                        error(message('MATLAB:toolstrip:general:invalidConstructorSyntax', ni_str));
                    end
                end
                data = varargin;
                rules = syntax.(input);
                properties = syntax.peerproperties;
                for ct=1:length(rules)
                    peerprop = rules{ct};
                    type = cell(ni,1);
                    matched = false(ni,1);
                    for i=1:ni
                        type{i} = properties.(peerprop{i}).type;
                        if strcmp(type{i}, 'iconobj')
                            [matched(i), iconstring] = validateIcon(data{i});
                        elseif strcmp(type{i}, 'groupobj')
                            [matched(i), groupstring] = validateButtonGroup(data{i});
                        else
                            matched(i) = matlab.ui.internal.toolstrip.base.Utility.validate(data{i}, type{i});
                        end
                    end
                    if all(matched)
                        for i=1:ni
                            if strcmp(type{i}, 'iconobj')
                                if properties.(peerprop{i}).isAction
                                    if isempty(iconstring)
                                        % empty icon
                                        action_properties.('iconClass') = '';
                                        action_properties.(peerprop{i}) = '';
                                    elseif strcmp(iconstring(1:3), 'url')
                                        % custom icon
                                        action_properties.('iconClass') = '';
                                        action_properties.(peerprop{i}) = iconstring;
                                    else
                                        % standard icon
                                        action_properties.('iconClass') = iconstring;
                                        action_properties.(peerprop{i}) = '';
                                    end
                                    action_properties.iconobj = data{i};
                                else
                                    widget_properties.(peerprop{i}) = iconstring;
                                    widget_properties.iconobj = data{i};
                                end
                            elseif strcmp(type{i}, 'groupobj')
                                if properties.(peerprop{i}).isAction
                                    action_properties.(peerprop{i}) = groupstring;
                                    action_properties.groupobj = data{i};
                                else
                                    widget_properties.(peerprop{i}) = groupstring;
                                    widget_properties.groupobj = data{i};
                                end
                            elseif strcmp(type{i}, 'stringNx1')
                                structure = struct('value',data{i},'label',data{i});
                                if properties.(peerprop{i}).isAction
                                    action_properties.items = structure;
                                else
                                    widget_properties.items = structure;
                                end
                            elseif strcmp(type{i}, 'stringNx2')
                                items = data{i}(:,1);
                                labels = data{i}(:,2);
                                structure = struct('value',items,'label',labels);
                                if properties.(peerprop{i}).isAction
                                    action_properties.items = structure;
                                else
                                    widget_properties.items = structure;
                                end
                            else
                                if properties.(peerprop{i}).isAction
                                    action_properties.(peerprop{i}) = data{i};
                                else
                                    widget_properties.(peerprop{i}) = data{i};
                                end
                            end
                        end
                        return
                    else
                        continue
                    end
                end
                error(message('MATLAB:toolstrip:general:invalidConstructorInputs'));
            else
                error(message('MATLAB:toolstrip:general:invalidConstructorSyntax', ni_str));
            end
        end
        
        %% Execute callback function handle
        function value = executeCallback(callback, src, event)
            % EXECUTE Evaluates a callback data type
            %
            % EXECUTE(CALLBACK, SRC) evaluates the given CALLBACK data type
            % from the given SRC.  [] will be used for EVENT.
            %
            % EXECUTE(CALLBACK, SRC, EVENT) evaluates the given CALLBACK
            % data type from the given SRC with the given EVENT.
            %
            % * If CALLBACK is a string, then it will be evaluated in the
            %   base work space.  SRC and EVENT will not be passed in.
            %
            % * If CALLBACK is a function handle, then it will be evaluated
            %   by passing SRC and EVENT to the function handle.
            %
            % * If CALLBACK is a cell array, then it will be evaluated by
            %   passing in SRC, EVENT, and any additional arguments
            %   specified in the cell array.
            %
            %  Example: Using execute() to dispatch a callback
            %
            %    function triggerMyCallback(obj)
            %
            %       % Get the inputs ready
            %       callback = obj.MyCallbackProperty;
            %       src = obj;
            %       event = MyEventData;
            %
            %       % Kick off the callback
            %       Callback.execute(callback, src, event);
            %
            %    end
            
            narginchk(2, 3)
            
            % event is [] when not specified
            if nargin == 2
                event = [];
            end
            
            if ischar(callback)
                
                % Eval the string to execute it.
                value = evalin('base', callback);
               
            elseif isa(callback, 'function_handle')
                
                % Call the function directly.
                value = feval(callback, src, event);
                
            elseif iscell(callback)
                
                % First element is the function handle or function string
                funcHandle = callback{1};
                
                % Remaining elements in the cell array are user specified
                % the first element, which was the function handle.
                args = {src event};
                args = [args callback(2:end)];
                
                % Invoke the callback function passing any extra arguments
                % along with the call.
                value = feval(funcHandle, args{:});
                
            end
            
        end
        
        %% Validate properties
        function matched = validate(data, type)
            switch type
                case 'string'
                    matched = ischar(data);
                case 'logical'
                    matched = islogical(data);
                case 'stringNx1'
                    matched = iscell(data) && (isempty(data) || (size(data,2)==1 && all(cellfun('isclass',data,'char'))));
                case 'stringNx2'
                    matched = iscell(data) && (isempty(data) || (size(data,2)==2 && all(cellfun('isclass',data(:),'char'))));
                case 'real'
                    matched = ~isempty(data) && isnumeric(data) && isreal(data) && isscalar(data) && isfinite(data);
                case 'integer'
                    matched = ~isempty(data) && isnumeric(data) && isreal(data) && isscalar(data) && isfinite(data) && round(data)==data;
                case 'selection_mode'
                    matched = ischar(data) && any(strcmpi(data,{'single', 'multiple'}));
                case 'maxHeight' 
                    matched = ~isempty(data) && isnumeric(data) && isreal(data) && isscalar(data) && isfinite(data) && round(data)==data && data>0;
                case 'width' 
                    matched = ~isempty(data) && isnumeric(data) && isreal(data) && isscalar(data) && isfinite(data) && round(data)==data && data>0;
                case 'collapse_priority'
                    matched = ~isempty(data) && isnumeric(data) && isreal(data) && isscalar(data) && isfinite(data) && round(data)==data && data>=0;
                case 'horizontalAlignment'
                    matched = ischar(data) && any(strcmpi(data,{'left', 'right', 'center'}));
                case 'display_state'
                    matched = ischar(data) && any(strcmpi(data,{'expanded', 'collapsed', 'expanded_on_top'}));
                case 'galleryDisplayState'
                    matched = ischar(data) && any(strcmpi(data,{'icon_view', 'list_view'}));
            end
        end

        %% Connector utilities
        function [isConnectorOn, portNumber] = startConnector()
            % check connector status
            isConnectorOn = connector('status');
            if isConnectorOn
                % get connector information
                info = getappdata(0, 'MATLAB_CONNECTOR_STARTUP_CONFIG');
                if info.suppressDocRoot
                    % if connector is already on with default root, return port number
                    portNumber = info.port;
                else
                    % if default root ("/toolbox") is not used, error out 
                    error(message('MATLAB:toolstrip:general:connectorError1'));
                end
            else
                % get an arbitrary port number
                ss = java.net.ServerSocket(0);
                portNumber = ss.getLocalPort();
                ss.close;
                % start connector
                isConnectorOn = connector('localhostonly','port',portNumber); 
                % assert if failed
                assert(isConnectorOn, message('MATLAB:toolstrip:general:connectorError2'));
            end
        end

        function isConnectorOn = stopConnector()
            % check connector status
            isConnectorOn = connector('status');            
            if isConnectorOn
                % off
                isConnectorOn = connector('off');
            end
        end
        
    end
    
end

function [matched,  iconstring] = validateIcon(Icon)
    matched = isa(Icon,'matlab.ui.internal.toolstrip.Icon');
    if matched
        if isCSS(Icon)
            iconstring = Icon.getIconClass();
        else
            iconstring = Icon.getBase64URL();
        end
    else
        iconstring = '';
    end
end

function [matched,  groupstring] = validateButtonGroup(ButtonGroup)
    matched = isa(ButtonGroup,'matlab.ui.internal.toolstrip.ButtonGroup');
    if matched
        groupstring = ButtonGroup.Id;
    else
        groupstring = '';
    end
end

function java_value = convertStringToJava(value)
    %% convert string (char array) into a java String
    if isempty(value)
        java_value = java.lang.String('');
    else
        java_value = java.lang.String(value(:)');
    end
end

function java_value = convertLogicalToJava(value)
    %% convert logical array into java array of Boolean
    if isscalar(value)
        java_value = java.lang.Boolean(value);
    elseif isvector(value)
        len = length(value);
        java_value = javaArray('java.lang.Boolean',len);
        for i=1:len
            java_value(i) = java.lang.Boolean(value(i));
        end
    elseif ismatrix(value)
        [m, n] = size(value);
        java_value = javaArray('java.lang.Boolean',m,n);
        for i=1:m
            for j=1:n
                java_value(i,j) = java.lang.Boolean(value(i,j));
            end
        end
    else
        error(message('MATLAB:toolstrip:general:invalidArray'));
    end
end

function java_value = convertNumericToJava(value)
    %% convert numeric array into java array of Double
    if isempty(value)
        java_value = java.util.ArrayList();
    elseif isscalar(value)
        java_value = java.lang.Double(value);
    elseif isvector(value)
        len = length(value);
        java_value = javaArray('java.lang.Double',len);
        for i=1:len
            java_value(i) = java.lang.Double(value(i));
        end
    elseif ismatrix(value)
        [m, n] = size(value);
        java_value = javaArray('java.lang.Double',m,n);
        for i=1:m
            for j=1:n
                java_value(i,j) = java.lang.Double(value(i,j));
            end
        end
    else
        error(message('MATLAB:toolstrip:general:invalidArray'));
    end
end

function java_value = convertCellStringToJava(value)
    %% convert cell array of strings to java array of Strings)
    if isempty(value)
        java_value = java.util.ArrayList();
    elseif isvector(value)
        len = length(value);
        java_value = javaArray('java.lang.String',len);
        for i=1:len
            java_value(i) = java.lang.String(value{i});
        end
    elseif ismatrix(value)
        [m, n] = size(value);
        java_value = javaArray('java.lang.String',m,n);
        for i=1:m
            for j=1:n
                java_value(i,j) = java.lang.String(value{i,j});
            end
        end
    else
        error(message('MATLAB:toolstrip:general:invalidArray'));
    end
end

function hash = convertStructToHashmap_Scalar(structure)
    %% convert structure to hashmap
    hash = java.util.HashMap();    
    names = fieldnames(structure);
    for ct=1:length(names)
        property = names{ct};
        value = matlab.ui.internal.toolstrip.base.Utility.convertFromMatlabToJava(structure.(property));
        hash.put(property, value);
    end
end

function structure = convertHashmapToStructure_Scalar(hashmap)
    %% convert hash map to structure
    structure = struct;
    keyNamesJavaArray = hashmap.keySet.toArray();
    for idx = 1:hashmap.size();
        % Get name from the key set
        propertyStringName = keyNamesJavaArray(idx);
        % Use key name to get value out
        propertyValue = hashmap.get(propertyStringName);
        % Stuff into struct
        structure.(char(propertyStringName)) = propertyValue;
    end
end

function prop = getPropertyfromKey(key)
    % convert property name from JS format to MATLAB format.  If there is
    % no match, use the original format.
    switch key
        case 'text'
            prop = 'Text';
        case 'selectedItem'
            prop = 'SelectedItem';
        case 'selectedItems'
            prop = 'SelectedItems';
        case 'value'
            prop = 'Value';
        case 'selected'
            prop = 'Selected';
        otherwise
            prop = key;
    end
end

function event = getEventfromKey(key)
    % convert event type from JS format to MATLAB format.  If there is no
    % match, use the original format.
    switch key
        case 'buttonPushed'
            event = 'ButtonPushed';
        case 'itemPushed'
            event = 'ItemPushed';
        case 'dropDownPerformed'
            event = 'DropDownPerformed';
        case 'textCancelled'
            event = 'TextCancelled';
        case 'focusGained'
            event = 'FocusGained';
        case 'focusLost'
            event = 'FocusLost';
        case 'typing'
            event = 'Typing';
        case 'valueChanged'
            event = 'ValueChanged';
        case 'valueChanging'
            event = 'ValueChanging';
        case 'onOpen'
            event = 'PopupListOpened';
        case 'onClose'
            event = 'PopupListClosed';
        case 'categoryMoved'
            event = 'CategoryMoved';
        case 'itemMoved'
            event = 'ItemMoved';
        case 'favButtonPushed'
            event = 'FavoriteButtonPushed';
        case 'refresh'
            event = 'Refresh';
        otherwise
            event = key;
    end
end

