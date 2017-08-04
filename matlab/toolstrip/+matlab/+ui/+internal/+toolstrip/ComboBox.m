classdef ComboBox < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected
    % Combo Box
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ComboBox.ComboBox">ComboBox</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.Items">Items</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ComboBox.SelectedIndex">SelectedIndex</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ComboBox.SelectedItem">SelectedItem</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected.ItemSelected">ItemSelectedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.addItem">addItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.removeItem">removeItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.replaceAllItems">replaceAllItems</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ComboBox.ItemSelected">ItemSelected</a>            
    %
    % See also matlab.ui.internal.toolstrip.List
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon button pressed in the view.
        ItemSelected
    end
    
    properties (Dependent, Access = public)
        % Property "SelectedIndex":
        %
        %   The index of the selected item
        %   It is an integer and the default value is 0 (unselected).
        %   It is writable.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.CombokBox({'item1','item2','item3'})
        %       combo.SelectedIndex % returns 0
        %       combo.SelectedIndex = 2 % select 'item2'
        SelectedIndex
        % Property "SelectedItem":
        %
        %   The selected item representing a state
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.CombokBox({'item1','item2','item3'})
        %       combo.SelectedItem % returns ''
        %       combo.SelectedItem = 'item2 % select 'item2'
        SelectedItem
    end
    
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ComboBox(varargin)
            % Constructor "ComboBox": 
            %
            %   Create a combobox.
            %
            %   Example:
            %       states = {'One';'Two';'Three'};
            %       items = {'One' 'Label1';'Two' 'Label2';'Three' 'Label3'};
            %       cmb = matlab.ui.internal.toolstrip.ComboBox;
            %       cmb = matlab.ui.internal.toolstrip.ComboBox(states);
            %       cmb = matlab.ui.internal.toolstrip.ComboBox(items);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ComboBox', varargin{:});
            % default selected item
            this.SelectedIndex = 1;
        end
        
        %% Public API: Get/Set
        % SelectedItem
        function value = get.SelectedItem(this)
            % GET function for SelectedItem property.
            value = this.Action.SelectedItem;
        end
        function set.SelectedItem(this, value)
            % SET function for SelectedItem property.
            this.Action.SelectedItem = value;
        end
        % SelectedIndex
        function value = get.SelectedIndex(this)
            % GET function for SelectedIndex property.
            if isempty(this.SelectedItem)
                value = 0;
            else
                value = find(strcmp(this.SelectedItem, this.Items(:,1)));
            end
        end
        function set.SelectedIndex(this, value)
            % SET function for SelectedIndex property.
            % temporarily block 0 as a valid selection
            if ~(matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value >= 1 && value <= size(this.Items,1))
                error(message('MATLAB:toolstrip:control:invalidSelectedIndex'))
            end
            this.SelectedItem = this.Items{value,1};
%             if value == 0
%                 this.SelectedItem = '';
%             else
%                 this.SelectedItem = this.Items{value,1};
%             end
        end
        
    end
    
    % ----------------------------------------------------------------------------
    % Hidden public methods
    methods (Access = protected)
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties.items = {};
            properties.selectedItem = '';
        end
        
        function rules = getInputArgumentRules(this)
            rules.peerproperties.values = struct('type','stringNx1','isAction',true);
            rules.peerproperties.items = struct('type','stringNx2','isAction',true);            
            rules.input0 = false;
            rules.input1 = {{'values'};{'items'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Items');
            this.Action.addProperty('SelectedItem');
            this.Action.addCallbackFcn('ItemSelected');
        end
        
        function ActionPropertySetCallback(this, src, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'SelectedItem')
                this.notify('ItemSelected',eventdata);   
            end
        end
        
        function result = checkAction(this, control)
            result = isa(control, 'matlab.ui.internal.toolstrip.ComboBox') || isa(control, 'matlab.ui.internal.toolstrip.List');
        end
        
    end
    
end
