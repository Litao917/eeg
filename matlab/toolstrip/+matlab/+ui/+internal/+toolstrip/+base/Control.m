classdef (Abstract) Control < matlab.ui.internal.toolstrip.base.Component & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic
    % Base class for MCOS toolstrip controls.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% -----------  User-invisible properties --------------------
    properties (GetAccess = protected, SetAccess = protected)
        % Action object
        Action
        % ActionListener
        ActionPerformedListener
        ActionPropertySetListener
    end
    
    %% ----------- User-visible properties --------------------------
    properties (Dependent, Access = public)
        % Property "Description": 
        %
        %   The description of a control, displayed when mouse is hoving over.
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button('Submit')
        %       btn.Description = 'Submit Button'
        Description
        % Property "Enabled": 
        %
        %   The enabling status of a control.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       btn = matlab.ui.internal.toolstrip.Button('Submit')
        %       btn.Enabled = false
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
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Control(type, varargin)
            % set type
            this.Type = type;
            % process action and widget properties
            widget_properties = this.getDefaultWidgetProperties();
            if nargin == 2 && isa(varargin{1},'matlab.ui.internal.toolstrip.base.Action')
                this.Action = varargin{1};
            else
                action_properties = this.getDefaultActionProperties();
                % process custom action and widget properties
                rules = this.getInputArgumentRules();
                [action_properties, widget_properties] = matlab.ui.internal.toolstrip.base.Utility.updateProperties(rules, action_properties, widget_properties, varargin{:}); 
                % special handling of Icon property
                hasIconObj = isfield(action_properties,'iconobj');
                if hasIconObj
                    Icon = action_properties.iconobj;
                    action_properties = rmfield(action_properties, 'iconobj');
                end
                % special handling of ButtonGroup property
                hasButtonGroupObj = isfield(action_properties,'groupobj');
                if hasButtonGroupObj
                    ButtonGroup = action_properties.groupobj;
                    action_properties = rmfield(action_properties, 'groupobj');
                end
                % create action object with all the peer node properties
                this.Action = matlab.ui.internal.toolstrip.base.Action(action_properties);
                % special handling of Icon property
                if isfield(action_properties, 'icon') && hasIconObj
                    this.Action.setPrivateProperty('Icon', Icon);
                end
                % special handling of ButtonGroup property
                if isfield(action_properties, 'buttonGroupName') && hasButtonGroupObj
                    this.Action.setPrivateProperty('ButtonGroup', ButtonGroup);
                end
                % add dynamic properties to the Action object
                this.addActionProperties();
            end
            % create widget peer node
            widget_properties.actionId = this.Action.Id;
            this.createPeer(widget_properties);
            % add listener to peer node events
            this.addListeners();
        end
        
        %% Public API: Get/Set
        % Enabled        
        function value = get.Enabled(this)
            % GET function for Enabled property.
            value = this.Action.Enabled;
        end
        function set.Enabled(this, value)
            % SET function for Enabled property.
            this.Action.Enabled = value;
        end
        % Description
        function value = get.Description(this)
            % GET function for Description property.
            value = this.Action.Description;
        end
        function set.Description(this, value)
            % SET function for Description property.
            this.Action.Description = value;
        end
        % Shortcut
        function value = get.Shortcut(this)
            % GET function for Shortcut property.
            value = this.Action.Shortcut;
        end
        function set.Shortcut(this, value)
            % SET function for Shortcut property.
            this.Action.Shortcut = value;
        end
        
        %% Sharing action
        function shareWith(this, controls)
            % Method "shareWith":
            %
            %   shareWith(control1, control2): share properties and
            %   callbacks of "control1" with "control2".  "control1" and
            %   "control2" must have compatible types.
            action = this.getAction();
            for ct=1:length(controls)
                if this.checkAction(controls(ct))
                    controls(ct).setAction(action);
                else
                    error(message('MATLAB:toolstrip:control:invalidShareWith'));
                end
            end
        end
        
    end
    
    % ----------------------------------------------------------------------------
    methods (Abstract, Access = protected)
        prop = getDefaultActionProperties(this)
        addActionProperties(this)
    end

    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)

        function properties = getDefaultWidgetProperties(this)
            % usually overload by sub-classes
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Component(this);
            properties = getDefaultMnemonicProperties(this, properties);
        end
        
        function addListeners(this)
            this.ActionPerformedListener = addlistener(this.Action, 'ActionPerformed', @(event, data) ActionPerformedCallback(this, event, data));
            this.ActionPropertySetListener = addlistener(this.Action, 'ActionPropertySet', @(event, data) ActionPropertySetCallback(this, event, data));
        end
        
        function removeListeners(this)
            delete(this.ActionPerformedListener);
            delete(this.ActionPropertySetListener);
        end
        
        function ActionPerformedCallback(this, event, data)
            %display('action performed in an action object by the client.')
        end
        
        function ActionPropertySetCallback(this, event, data)
            %display('property set in an action object by the client.')
        end
        
        function action = getAction(this)
            % Method "getAction":
            %
            %   action = getAction(control): return the action object
            %   associated with this control.
            action = this.Action;
        end
        
        function action = setAction(this, action)
            % Method "setAction":
            %
            %   setAction(control, action): set the action object
            %   associated with this control.
            this.setPeerProperty('actionId', action.Id);
            this.Action = action;
            this.removeListeners();
            this.addListeners();
        end
        
        function result = checkAction(this, control)
            result = false;
        end
        
        function rules = getInputArgumentRules(this)
            rules = struct;
        end
        
    end
    
end