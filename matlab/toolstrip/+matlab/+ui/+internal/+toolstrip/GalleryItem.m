classdef GalleryItem < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsFavorite ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed
    % Gallery Item
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.GalleryItem">GalleryItem</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsFavorite.IsFavorite">IsFavorite</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed.ItemPushedFcn">ItemPushedFcn</a>                
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.addToFavorites">addToFavorites</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.removeFromFavorites">removeFromFavorites</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItem.ItemPushed">ItemPushed</a>        
    %
    % Note: You cannot use standard Icon in a gallery item.
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.DropDownButton, matlab.ui.internal.toolstrip.SplitButton
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    events
        % Event sent upon list item pressed in the view.
        ItemPushed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryItem(varargin)
            % Constructor "GalleryItem": 
            %
            %   Creates a gallery item.
            %
            %   Examples:
            %
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('Item1');
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('Item2');
            %       item3 = matlab.ui.internal.toolstrip.GalleryItem('Item3');
            %       item4 = matlab.ui.internal.toolstrip.GalleryItem('Item4');
            %
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('My Category 2');
            %       category2.add(item3);
            %       category2.add(item4);
            %
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup;
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup);
            %

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('GalleryItem', varargin{:});
        end
        
        function addToFavorites(this)
            % Method "addToFavorites":
            %
            %   "addToFavorites(item)": add this item at the end of the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item.addToFavorites()
            
            % update favorites category
            popup = this.addToFavorites_private();
            % refresh gallery
            popup.notify('RefreshGallery');
        end
        
        function removeFromFavorites(this)
            % Method "removeFromFavorites":
            %
            %   "removeFromFavorites(item)": remove this item from the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item.addToFavorites()
            %       item.removeFromFavorites()
            
            % update favorites category
            popup = this.removeFromFavorites_private();
            % refresh gallery
            popup.notify('RefreshGallery');
        end
        
    end
    
    methods (Access = protected)

        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Control(this);
            properties = this.getDefaultTextOverrideProperties(properties);
            properties = this.getDefaultIconOverrideProperties(properties);
            properties = this.getDefaultDescriptionOverrideProperties(properties);
            properties.displayState = 'icon_view';
        end
        
        function properties = getDefaultActionProperties(this)
            properties = matlab.ui.internal.toolstrip.base.Action.getDefaultActionProperties();
            properties = this.getDefaultTextProperties(properties);
            properties = this.getDefaultIconProperties(properties);   
            properties = this.getDefaultIsFavoriteProperties(properties);   
        end
        
        function rules = getInputArgumentRules(this) %#ok<*MANU>
            rules.peerproperties.text = struct('type','string','isAction',true);
            rules.peerproperties.icon = struct('type','iconobj','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'text'};{'icon'}};
            rules.input2 = {{'text';'icon'}};
        end
        
        function addActionProperties(this)
            % add dynamic action properies
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('IsFavorite');
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function ActionPerformedCallback(this, ~, ~)
            this.notify('ItemPushed');
        end
        
        function PeerEventCallback(this,~,data)
            % client side event
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'FavoriteButtonPushed')
                % it does not trigger RefreshGalleryFromAPI event
                action = this.getAction();
                if action.IsFavorite
                    popup = this.removeFromFavorites_private();
                else
                    popup = this.addToFavorites_private();
                end
                % refresh gallery
                popup.notify('RefreshGallery');
            end
        end
        
        function result = checkAction(this, control) %#ok<*INUSL>
            result = isa(control, 'matlab.ui.internal.toolstrip.GalleryItem');
        end
        
    end
    
    methods (Hidden, Access = {?matlab.ui.internal.toolstrip.Gallery, ?matlab.ui.internal.toolstrip.GalleryPopup})
        
        function action = getItemAction(this)
            action = this.getAction();
        end
        
        function popup = addToFavorites_private(this)
            cat = this.Parent;
            if isempty(cat)
                error(message('MATLAB:toolstrip:control:failToAddToFavorites1'));
            end
            popup = cat.Parent;
            if isempty(popup)
                error(message('MATLAB:toolstrip:control:failToAddToFavorites1'));
            end
            if ~popup.FavoritesEnabled
                error(message('MATLAB:toolstrip:control:failToAddToFavorites2'));
            end
            action = this.getAction();
            if action.IsFavorite
                return
            else
                % create new item and add it to Favorites
                item = matlab.ui.internal.toolstrip.GalleryItem(action);
                item.Tag = this.Tag;
                favorites = popup.getFavorites();
                favorites.add(item);
                action.IsFavorite = true;
            end
        end
        
        function popup = removeFromFavorites_private(this)
            cat = this.Parent;
            if isempty(cat)
                error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites1'));
            end
            if isa(cat,'matlab.ui.internal.toolstrip.impl.GalleryFavoriteCategory')
                % path from UI
                favorites = cat;
                popup = favorites.Popup;
            else
                popup = cat.Parent;
                if isempty(popup)
                    error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites1'));
                elseif ~popup.FavoritesEnabled
                    error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites2'));
                else
                    favorites = popup.getFavorites();
                end
            end
            action = this.getAction();
            if action.IsFavorite
                for ct=1:length(favorites.Children)
                    item = favorites.get(ct);
                    if item.getAction()==action
                        favorites.remove(item);
                        break
                    end
                end
                action.IsFavorite = false;                    
            else
                return
            end
        end
        
    end
    
end

