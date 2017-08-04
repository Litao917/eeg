classdef Action < handle & dynamicprops & matlab.ui.internal.toolstrip.base.PeerInterface
    % Action Class
    %
    % Action objects are used in toolstrip components to share common data
    % and common actions in response to events.  
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Action">Action</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Enabled">Enabled</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.Shortcut">Shortcut</a>    
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.addProperty">addProperty</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.addCallbackFcn">addCallbackFcn</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.ActionPerformed">ActionPerformed</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Action.ActionPropertySet">ActionPropertySet</a>    
    %
    % See also matlab.ui.internal.toolstrip.PushButton

    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Description": 
        %
        %   The description of a control, displayed when mouse is hoving over.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       action.Description = 'Submit Button'
        Description
        % Property "Enabled": 
        %
        %   The enabling status of a control.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       action.Enabled = false
        Enabled
        % Property "Shortcut": 
        %
        %   The shortcut key of an action
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       action.Shortcut = 'S'
        Shortcut
    end
    
    %% -----------  User-invisible properties --------------------
    properties (Access = protected)
        Type = 'Action';
    end
    
    properties (Hidden, SetAccess = private)
        % Property "Id": 
        %
        %   The name of an action.  It is a string and the value is
        %   automatically generated . It is read only.
        Id
    end
    
    properties (Access = private)
        Icon_
        QuickAccessIcon_
        Popup_
        DynamicPopupFcn_
        ButtonGroup_
    end
    
    events
        % General event when an action is performed.
        ActionPerformed
        % ActionPropertySet events
        ActionPropertySet
    end
    
    methods
        
        %% Constructor
        function this = Action(varargin)
            % Constructor "Action": 
            %
            %   Create an Action object
            %
            % Example:
            %   action = matlab.ui.internal.toolstrip.base.Action();
            % 
            % This is not a user facing class.
            if nargin == 0
                properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            else
                properties = varargin{1};
            end
            this.createPeer(properties);
            this.Id = char(this.Peer.getId());
            this.setPeerProperty('id', this.Id);
       end
        
       function delete(this)
           this.destroyPeer();
       end
       
       %% Public API: Get/Set
        % Enabled        
        function value = get.Enabled(this)
            % GET function for Enabled property.
            value = this.getPeerProperty('enabled');
        end
        function set.Enabled(this, value)
            % SET function for Enabled property.
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical')
                this.setPeerProperty('enabled',value);
            else
                error(message('MATLAB:toolstrip:control:invalidLogicalProperty', 'Enabled'))
            end
        end
        % Description
        function value = get.Description(this)
            % GET function for Description property.
            value = this.getPeerProperty('description');
        end
        function set.Description(this, value)
            % SET function for Description property.
            if ~matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'Description'))
            end
            this.setPeerProperty('description',value);
        end
        % Shortcut
        function value = get.Shortcut(this)
            % GET function for Shortcut property.
            value = this.getPeerProperty('shortcut');
        end
        function set.Shortcut(this, value)
            % SET function for Shortcut property.
            if ~matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'Shortcut'))
            end
            this.setPeerProperty('shortcut',value);
        end
        
        %% Public API: add dynamic properties
        function addProperty(this, name)
            % Method "addProperty":
            %
            %   "addProperty(action, prop)": adds a dynamic property to the
            %   action object.  The following property names are accepted:
            %       'Text'
            %       'Label'
            %       'PlaceholderText'
            %       'SelectedItem'
            %       'SelectionMode'
            %       'Value'
            %       'Minimum'
            %       'Maximum'
            %       'Steps'
            %       'MinorStepSize'
            %       'MajorStepSize'
            %       'Selected'
            %       'Editable'
            %       'IsFavorite'
            %       'Items'
            %       'SelectedItems'
            %       'Icon'
            %       'QuickAccessIcon'
            %       'Popup'
            %       'ButtonGroup'
            %       'DynamicPopupFcn'
            %
            %   Example:
            %       action = matlab.ui.internal.toolstrip.base.Action();
            %       action.addProperty('Text')
            %       action.addProperty('Icon')
            %       label = matlab.ui.internal.toolstrip.Label(action)
            switch name
                % char
                case 'Text'
                    prop = this.addprop('Text');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getCharProperty(this, 'text');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'text', data);
                case 'Label'
                    prop = this.addprop('Label');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getCharProperty(this, 'label');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'label', data);
                case 'PlaceholderText'
                    prop = this.addprop('PlaceholderText');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getCharProperty(this, 'placeholderText');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'placeholderText', data);
                case 'SelectionMode'
                    prop = this.addprop('SelectionMode');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getCharProperty(this, 'selectionMode');
                    prop.SetMethod = @(this, data) setCharProperty(this, 'selectionMode', data);
                case 'SelectedItem'
                    prop = this.addprop('SelectedItem');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getCharProperty(this, 'selectedItem');
                    prop.SetMethod = @(this, data) setSelectedItemProperty(this, data);
                % double
                case 'Value'
                    prop = this.addprop('Value');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getRealProperty(this, 'value');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'value', data);
                case 'Minimum'
                    prop = this.addprop('Minimum');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getRealProperty(this, 'minimum');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'minimum', data);
                case 'Maximum'
                    prop = this.addprop('Maximum');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getRealProperty(this, 'maximum');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'maximum', data);
                case 'MinorStepSize'
                    prop = this.addprop('MinorStepSize');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getRealProperty(this, 'minorStepSize');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'minorStepSize', data);
                case 'MajorStepSize'
                    prop = this.addprop('MajorStepSize');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getRealProperty(this, 'majorStepSize');
                    prop.SetMethod = @(this, data) setRealProperty(this, 'majorStepSize', data);
                case 'Steps'
                    prop = this.addprop('Steps');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getIntegerProperty(this, 'steps');
                    prop.SetMethod = @(this, data) setIntegerProperty(this, 'steps', data);
                % logical
                case 'Selected'
                    prop = this.addprop('Selected');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getLogicalProperty(this, 'selected');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'selected', data);
                case 'Editable'
                    prop = this.addprop('Editable');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getLogicalProperty(this, 'editable');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'editable', data);
                case 'IsFavorite'
                    prop = this.addprop('IsFavorite');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getLogicalProperty(this, 'isFavorite');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'isFavorite', data);
                case 'IsInQuickAccess'
                    prop = this.addprop('IsInQuickAccess');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getLogicalProperty(this, 'isInQAB');
                    prop.SetMethod = @(this, data) setLogicalProperty(this, 'isInQAB', data);
                % items
                case 'Items'
                    prop = this.addprop('Items');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getItemsProperty(this);
                    prop.SetMethod = @(this, data) setItemsProperty(this, data);
                case 'SelectedItems'
                    prop = this.addprop('SelectedItems');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getSelectedItemsProperty(this);
                    prop.SetMethod = @(this, data) setSelectedItemsProperty(this, data);
                % icon
                case 'Icon'
                    % icon url string is stored in the peer node "icon"
                    prop = this.addprop('Icon');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getIconProperty(this);
                    prop.SetMethod = @(this, data) setIconProperty(this, data);
                % icon
                case 'QuickAccessIcon'
                    % icon url string is stored in the peer node "icon"
                    prop = this.addprop('QuickAccessIcon');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getQuickAccessIconProperty(this);
                    prop.SetMethod = @(this, data) setQuickAccessIconProperty(this, data);
                % popup
                case 'Popup'
                    % popup id is stored in the peer node "popupId"
                    prop = this.addprop('Popup');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getPopupProperty(this);
                    prop.SetMethod = @(this, data) setPopupProperty(this, data);
                % DynamicPopupFcn
                case 'DynamicPopupFcn'
                    % no corresponding peer node property
                    prop = this.addprop('DynamicPopupFcn');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getDynamicPopupFcnProperty(this);
                    prop.SetMethod = @(this, data) setDynamicPopupFcnProperty(this, data);
                % ButtonGroup
                case 'ButtonGroup'
                    prop = this.addprop('ButtonGroup');
                    prop.Dependent = true;
                    prop.GetMethod = @(this) getButtonGroupProperty(this);
                    %prop.SetMethod = @(this, data) setButtonGroupProperty(this, data);
                otherwise
                    error(message('MATLAB:toolstrip:control:invalidActionProperty', name))
            end
        end
        
        function addCallbackFcn(this, name)
            % Method "addCallbackFcn":
            %
            %   "addProperty(action, callbackfcn)": adds a dynamic callback
            %   function to the action object.  The following callback
            %   function names are accepted:
            %       'PushPerformed', used by PushButton, ListItem and SplitButton
            %       'ItemSelected', used by ComboBox and List
            %       'SelectionChanged', used by ToggleButton, CheckBox, RadioButton and ListItemWithCheckBox
            %       'TextChanged', used by TextField and TextArea
            %       'ValueChanged', used by Slider and Spinner
            %
            %   Example:
            %       action = matlab.ui.internal.toolstrip.base.Action();
            %       action.addProperty('Text')
            %       action.addProperty('Icon')
            %       action.addCallbackFcn('PushPerformed')
            %       btn = matlab.ui.internal.toolstrip.PushButton(action)
            if any(strcmp(name,{'PushPerformed','ItemSelected','SelectionChanged','TextChanged','ValueChanged'}))
                private_prop = [name 'Fcn_'];
                public_prop = [name 'Fcn'];
                prop = this.addprop(private_prop);
                prop.Access = 'private';
                prop = this.addprop(public_prop);
                prop.Dependent = true;
                prop.GetMethod = @(this) getCallbackFcn(this, private_prop);
                prop.SetMethod = @(this, data) setCallbackFcn(this, private_prop, data);
            else
                error(message('MATLAB:toolstrip:control:invalidActionCallbackFcn', name))
            end
        end
        
    end
    
    methods (Access = protected)
        
        %% char
        function value = getCharProperty(this, peer_prop)
            value = this.getPeerProperty(peer_prop);
        end
            
        function setCharProperty(this, peer_prop, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', peer_prop))
            end
        end
        
        %% numeric
        function value = getIntegerProperty(this, peer_prop)
            value = this.getPeerProperty(peer_prop);
        end
            
        function setIntegerProperty(this, peer_prop, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer')
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidIntegerProperty', peer_prop))
            end
        end
        
        function value = getRealProperty(this, peer_prop)
            value = this.getPeerProperty(peer_prop);
        end
            
        function setRealProperty(this, peer_prop, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'real')
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidRealProperty', peer_prop))
            end
        end
        
        %% logical
        function value = getLogicalProperty(this, peer_prop)
            value = this.getPeerProperty(peer_prop);
        end
            
        function setLogicalProperty(this, peer_prop, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical')
                this.setPeerProperty(peer_prop, value);
            else
                error(message('MATLAB:toolstrip:control:invalidLogicalProperty', peer_prop))
            end
        end
        
        %% Selection Mode
        function setSelectionModeProperty(this, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                if isempty(strcmpi(value, {'single', 'multiple'}))
                    error(message('MATLAB:toolstrip:control:invalidSelectionMode'))
                else
                    this.setPeerProperty(peer_prop, lower(value));
                end
            else
                error(message('MATLAB:toolstrip:control:invalidSelectionMode'))
            end
        end
        
        %% items
        function value = getItemsProperty(this)
            combined = this.getPeerProperty('items');
            if ~isempty(combined)
                value = [{combined.value}' {combined.label}'];
            end
        end
        
        function setItemsProperty(this, value)
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx1')
                % states only
                selected = false(size(value));
                if isempty(findprop(this,'SelectedItem'))
                    % List
                    for ct=1:length(this.SelectedItems)
                        matched = find(strcmp(this.SelectedItem(ct), value));
                        if ~isempty(matched)
                            selected(matched) = true;
                        end
                    end
                else
                    % ComboBox
                    if any(strcmp(this.SelectedItem, value))
                        selected(strcmp(this.SelectedItem, value)) = true;
                    else
                        selected(1) = true;
                    end
                end
                combined = struct('value',value,'selected',num2cell(selected),'label',value);
            elseif matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx2')
                % states and labels
                selected = false(size(value(:,1)));
                if isempty(findprop(this,'SelectedItem'))
                    % List
                    for ct=1:length(this.SelectedItems)
                        matched = find(strcmp(this.SelectedItem(ct), value(:,1)));
                        if ~isempty(matched)
                            selected(matched) = true;
                        end
                    end
                else
                    % ComboBox
                    if any(strcmp(this.SelectedItem, value(:,1)))
                        selected(strcmp(this.SelectedItem, value(:,1))) = true;
                    else
                        selected(1) = true;
                    end
                end
                combined = struct('value',value(:,1),'selected',num2cell(selected(:,1)),'label',value(:,2));
            else
                error(message('MATLAB:toolstrip:control:invalidItems'))
            end
            this.setPeerProperty('items',combined);
        end
        
        %% icon
        function value = getIconProperty(this)
            value = this.Icon_;
        end
        
        function setIconProperty(this, value)
            if isempty(value)
                this.Icon_ = [];
                this.setPeerProperty('icon','');
                this.setPeerProperty('iconClass','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.Icon_ = value;
                if isCSS(value)
                    iconclass = value.getIconClass();
                    this.setPeerProperty('iconClass',iconclass);
                    this.setPeerProperty('icon','');
                else
                    url = value.getBase64URL();
                    this.setPeerProperty('iconClass','');
                    this.setPeerProperty('icon',url);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIcon'))
            end
        end
        
        %% quick access icon
        function value = getQuickAccessIconProperty(this)
            value = this.QuickAccessIcon_;
        end
        
        function setQuickAccessIconProperty(this, value)
            if isempty(value)
                this.QuickAccessIcon_ = [];
                this.setPeerProperty('quickAccessIcon','');
                this.setPeerProperty('quickAccessIconClass','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.QuickAccessIcon_ = value;
                if isCSS(value)
                    iconclass = value.getIconClass();
                    this.setPeerProperty('quickAccessIconClass',iconclass);
                    this.setPeerProperty('quickAccessIcon','');
                else
                    url = value.getBase64URL();
                    this.setPeerProperty('quickAccessIconClass','');
                    this.setPeerProperty('quickAccessIcon',url);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIcon'))
            end
        end
        
        %% popup
        function value = getPopupProperty(this)
            value = this.Popup_;
        end
        
        function setPopupProperty(this, value)
            if isempty(value)
                this.Popup_ = [];
                this.setPeerProperty('popupId','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.PopupList')
                this.Popup_ = value;
                this.setPeerProperty('popupId',value.getId());
            else
                error(message('MATLAB:toolstrip:control:invalidPopupList'))
            end
        end
        
        %% DynamicPopupFcn
        function value = getDynamicPopupFcnProperty(this)
            value = this.DynamicPopupFcn_;
        end
        
        function setDynamicPopupFcnProperty(this, value)
            if internal.Callback.validate(value)
                this.DynamicPopupFcn_ = value;
                this.setPeerProperty('hasDynamicPopup',~isempty(value));
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', 'DynamicPopupFcn'))
            end
        end
        
        %% ButtonGroup
        function value = getButtonGroupProperty(this)
            value = this.ButtonGroup_;
        end
        
        %% special set methods
        function setSelectedItemProperty(this, value)
            % temporarily block '' as a valid selection
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                if ~isempty(value) && any(strcmp(value, this.Items(:,1)))
                    this.setPeerProperty('selectedItem', value);
                else
                    error(message('MATLAB:toolstrip:control:invalidSelectedItem'))
                end
            else
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'SelectedItem'))
            end
        end
        function value = getSelectedItemsProperty(this)
            javaarray = this.getPeerProperty('selectedItems');
            if isempty(javaarray)
                value = {};
            else
                value = cell(javaarray);
            end
        end
        function setSelectedItemsProperty(this, value)
            % get length
            len = length(value);
            % check for cell array of strings or empty cell
            if matlab.ui.internal.toolstrip.base.Utility.validate(value, 'stringNx1')
                error(message('MATLAB:toolstrip:control:invalidCharProperty', 'SelectedItems'))
            end
            % validate selections
            for ct=1:len
                if ~any(strcmp(value(ct), this.Items(:,1)))
                    error(message('MATLAB:toolstrip:control:invalidSelectedItem'));
                end
            end
            % create java array
            if len == 0
                javaarray = '';
            else
                javaarray = javaArray('java.lang.String',len);
                for ct = 1:len
                    javaarray(ct) = java.lang.String(value{ct});
                end
            end
            this.setPeerProperty('selectedItems', javaarray);
        end
        
        %% callback property
        function value = getCallbackFcn(this, name)
            value = this.(name);
        end
        
        function value = setCallbackFcn(this, name, value)
            if internal.Callback.validate(value)
                this.(name) = value;
            else
                error(message('MATLAB:toolstrip:general:invalidFunctionHandle', name))
            end
        end
        
        %% peer model event callbacks
        function PropertySetCallback(this,src,data) %#ok<*INUSL>
            originator = data.getOriginator();
            if ~(isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS'))
                % get event data
                eventdata = matlab.ui.internal.toolstrip.base.Utility.processPropertySetData(data);
                % Execute callback functions
                switch eventdata.EventData.Property
                    case 'Selected'
                        if ~isempty(findprop(this,'SelectionChangedFcn'))
                            internal.Callback.execute(this.SelectionChangedFcn, this, eventdata);
                        end
                    case 'SelectedItem'
                        if ~isempty(findprop(this,'ItemSelectedFcn'))
                            internal.Callback.execute(this.ItemSelectedFcn, this, eventdata);
                        end
                    case 'SelectedItems'
                        if ~isempty(findprop(this,'ItemSelectedFcn'))
                            internal.Callback.execute(this.ItemSelectedFcn, this, eventdata);
                        end
                    case 'Text'
                        if ~isempty(findprop(this,'TextChangedFcn'))
                            internal.Callback.execute(this.TextChangedFcn, this, eventdata);
                        end
                end
                this.notify('ActionPropertySet', eventdata);
            end
        end
        
        function PeerEventCallback(this,src,data)
            % get event data
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            % execute attached callback functions
            switch eventdata.EventData.EventType
                case {'ButtonPushed', 'ItemPushed'}
                    if ~isempty(findprop(this,'PushPerformedFcn'))
                        internal.Callback.execute(this.PushPerformedFcn, this, eventdata);
                    end
                case 'ValueChanged'
                    if ~isempty(findprop(this,'ValueChangedFcn'))
                        internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
                    end
            end
            this.notify('ActionPerformed', eventdata);
        end
        
    end
    
    methods (Hidden)
        
        function setPrivateProperty(this, name, value)
            switch name
                case 'Icon'
                    % icon object is stored in action property "Icon_"
                    this.Icon_ = value;
                case 'ButtonGroup'
                    % ButtonGroup object is stored in action property "ButtonGroup_"
                    this.ButtonGroup_ = value;
            end
        end
        
        function peer = getPeer(this)
            peer = this.Peer;
        end
        
    end
    
    methods (Hidden, Static)

        function properties = getDefaultActionProperties()
            properties.enabled = true;
            properties.description = '';
            properties.shortcut = '';
        end

    end
    
end

