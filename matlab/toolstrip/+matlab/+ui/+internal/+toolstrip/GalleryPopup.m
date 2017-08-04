classdef GalleryPopup < matlab.ui.internal.toolstrip.base.Container
    % Gallery Popup
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryPopup">GalleryPopup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.DisplayState">DisplayState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.FavoritesEnabled">FavoritesEnabled</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemRowCount">GalleryItemRowCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemTextLineCount">GalleryItemTextLineCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemWidth">GalleryItemWidth</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.move">move</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.loadState">loadState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.saveState">saveState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.GalleryCategory, matlab.ui.internal.toolstrip.GalleryItem 
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, SetAccess = private)
        % Property "GalleryItemRowCount": 
        %
        %   The number of rows that can be used in the gallery and gallery
        %   popup display. The default value is 1 and the valid values are
        %   1, 2 and 3.  The property is read-only.  Custom value must be
        %   provided during construction.
        %
        GalleryItemRowCount
        % Property "GalleryItemTextLineCount": 
        %
        %   The number of text lines that can be used in the gallery and
        %   gallery popup display. The default value is 2 and the valid
        %   values are 0, 1 and 2.  The property is read-only.  Custom
        %   value must be provided during construction.
        %
        GalleryItemTextLineCount
        % Property "GalleryItemWidth": 
        %
        %   The width of any gallery item displayed in the gallery and
        %   gallery popup. The default value is 80 pixels.  The property is
        %   read-only.  Custom value must be provided during construction
        %   and it is in pixels.
        %
        GalleryItemWidth
        % Property "FavoritesEnabled": 
        %
        %   Gallery popup by default does not provide a Favorites category.
        %   It can only be enabled during construction.  The property is
        %   read-only.
        %
        FavoritesEnabled
    end
    
    % ----------------------------------------------------------------------------
    properties (Dependent)
        % Property "DisplayState": 
        %
        %   Gallery popup can be displayed in one of the two states:
        %   "icon_view" and "list_view".  Use this property to change the
        %   display state.
        %
        DisplayState
    end
    
    properties (Access = private)
        Favorites_
    end
    
    events
        RefreshGallery
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryPopup(varargin)
            % Constructor "GalleryPopup": 
            %
            %   Creates a gallery popup.
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
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup('GalleryItemRowCount', 2, 'GalleryItemTextLineCount', 0, 'GalleryItemWidth', 100);
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('GalleryPopup', varargin{:});
        end
        
        %% Public API: Get/Set
        function value = get.GalleryItemWidth(this)
            % GET function for ColumnWidth property.
            value = this.getPeerProperty('galleryItemWidth');
        end
        
        function value = get.GalleryItemRowCount(this)
            % GET function for Popup property.
            value = this.getPeerProperty('galleryItemRowCount');
        end
        
        function value = get.GalleryItemTextLineCount(this)
            % GET function for Items property.
            value = this.getPeerProperty('galleryItemTextLineCount');
        end
        
        %% Public API: Get and Set
        function value = get.FavoritesEnabled(this)
            % GET function for Items property.
            value = this.getPeerProperty('favoritesEnabled');
        end
        
        function value = get.DisplayState(this)
            % GET function for DisplayState property.
            value = this.getPeerProperty('displayState');
        end
        
        function set.DisplayState(this, value)
            % SET function for DisplayState property.
            if ~matlab.ui.internal.toolstrip.base.Utility.validate(value, 'galleryDisplayState')
                error(message('MATLAB:toolstrip:container:invalidGalleryDisplayState'))
            end
            this.setPeerProperty('displayState',lower(value));
        end
        
        %% Public API: add, move and remove
        function add(this, category, varargin)
            % Method "add":
            %
            %   "add(popup, category)": add a category at the end of the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       popup.add(category)
            %
            %   "add(popup, category, index)": insert a category to popup at a specific location.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2, 1) % insert "open" before "new"
            %
            if isa(category, 'matlab.ui.internal.toolstrip.GalleryCategory')
                add@matlab.ui.internal.toolstrip.base.Container(this, category, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(category), class(this)));
            end
            % refresh gallery
            this.notify('RefreshGallery');
        end
        
        function move(this, category, varargin)
            % Method "move":
            %
            %   "move(popup, category, index)": move a category to a specific location.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.move(category2, 1) % move "open" before "new"
            
            move_private(this, category, varargin{:});
            % refresh gallery
            this.notify('RefreshGallery');
        end
        
        function remove(this, category)
            % Method "remove":
            %
            %   "remove(popup, category)": remove a category.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.remove(category1) % remove "new"
            
            if isa(category, 'matlab.ui.internal.toolstrip.GalleryCategory')
                if this.isChild(category)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, category);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(category), class(this)));
            end
            % refresh gallery
            this.notify('RefreshGallery');
        end
        
        function state = saveState(this)
            % Method "saveState":
            %
            %   "state = saveState(popup)": save the current popup state.
            %
            %   "state" is a structure with the following fields:
            %       "FavoriteItems": a nx1 cell array of strings for favorite item Tags
            %       "Items": a mx1 cell array of strings for item tags
            %       "Categories": a kx1 cell array of strings for category tags
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       state = popup.saveState()
            
            favorite_tags = {};
            if this.FavoritesEnabled
                favorites = this.getFavorites();
                for ct = 1:length(favorites.Children)
                    item = favorites.Children(ct);
                    favorite_tags = [favorite_tags; item.Tag];
                end
            end
            item_tags = {};
            category_tags = {};
            for i = 1:length(this.Children)
                cat = this.Children(i);
                for j = 1:length(cat.Children)
                    item = cat.Children(j);
                    item_tags = [item_tags; item.Tag];
                end
                category_tags = [category_tags; cat.Tag];
            end
            state = struct();
            state.FavoriteItems = favorite_tags;
            state.Items = item_tags;
            state.Categories = category_tags;
        end
        
        function loadState(this, state)
            % Method "loadState":
            %
            %   "loadState(popup, state)": load saved popup state.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.loadState(state) % state was previously saved by the saveState method.
            
            % Protect existing favorites from new items
            if this.FavoritesEnabled
                favorites = this.getFavorites();
                for ct = length(favorites.Children):-1:1
                    item = favorites.Children(ct);
                    if any(strcmp(item.Tag, state.Items))
                        item.removeFromFavorites_private();
                    end
                end
            end
            % add custom favorites
            for ct = 1:length(state.FavoriteItems)
                tag = state.FavoriteItems{ct};
                found = false;
                for i = 1:length(this.Children)
                    cat = this.Children(i);
                    for j = 1:length(cat.Children)
                        item = cat.Children(j);
                        found = strcmp(tag, item.Tag);
                        if found
                            item.addToFavorites_private();
                            break;
                        end
                    end
                    if found
                        break;
                    end
                end
            end
            % re-order category
            for ct = 1:length(state.Categories)
                tag = state.Categories{ct};
                for i = 1:length(this.Children)
                    cat = this.Children(i);
                    found = strcmp(tag, cat.Tag);
                    if found
                        this.move_private(cat, ct);
                        break;
                    end
                end
            end
            % refresh gallery
            this.notify('RefreshGallery');
        end
        
        %% Overload "delete" method
        function delete(this)
            % In addition, delete favorites category due to dual reference
            if isvalid(this.Favorites_)
                delete(this.Favorites_);
            end
        end
        
    end
    
    %%
    methods (Access = {?matlab.ui.internal.toolstrip.GalleryItem, ?matlab.ui.internal.toolstrip.GalleryCategory, ?matlab.ui.internal.toolstrip.Gallery, ?mwhtmlguitest.mwhtmlguitestTestCase})
        
        function value = getFavorites(this)
            % GET function for Items property.
            value = this.Favorites_;
        end
        
        function allactions = getSortedActions(this)
            allactions1 = [];
            allactions2 = [];
            % collect actions in favorites (its order does not change programmatically)
            if this.FavoritesEnabled
                favorites = this.getFavorites();
                for ct = 1:length(favorites.Children)
                    allactions1 = [allactions1; favorites.Children(ct).getItemAction()]; %#ok<*AGROW>
                end
            end
            % collect actions in other categories
            for i = 1:length(this.Children)
                cat = this.Children(i);
                for j = 1:length(cat.Children)
                    item = cat.Children(j);
                    action = item.getItemAction();
                    if ~this.FavoritesEnabled || ~action.IsFavorite
                        allactions2 = [allactions2; action];
                    end
                end
            end
            % together
            allactions = [allactions1; allactions2];
        end
        
    end

    %%
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.favCategoryId = '';
            properties.displayState = 'icon_view';
            properties.favoritesEnabled = false;
            properties.galleryItemRowCount = 1;
            properties.galleryItemTextLineCount = 2;
            properties.galleryItemWidth = 80;
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            % create favorite
            this.Favorites_ = matlab.ui.internal.toolstrip.impl.GalleryFavoriteCategory(this);
            widget_properties.favCategoryId = this.Favorites_.getId();
            % set optional properties
            ni = nargin-2;
            if rem(ni,2)~=0,
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'displayState','favoritesEnabled','galleryItemRowCount','galleryItemTextLineCount','galleryItemWidth'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'displayState'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'galleryDisplayState');
                        if ok
                            widget_properties.(name) = lower(value);
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryDisplayState'))
                        end
                    case 'favoritesEnabled'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidFavoritesEnabled'))
                        end
                    case 'galleryItemRowCount'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && any(value == [1 2 3]);
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemRowCount'))
                        end
                    case 'galleryItemTextLineCount'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && any(value == [0 1 2]);
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemTextLineCount'))
                        end
                    case 'galleryItemWidth'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'width');
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemWidth'))
                        end
                end
            end
        end
        
        function move_private(this, category, index)
            % Method "move":
            %
            %   "move(popup, category, index)": move a category to a specific location.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.move(category2, 1) % move "open" before "new"
            if isa(category, 'matlab.ui.internal.toolstrip.GalleryCategory')
                if this.isChild(category)
                    % move component in MCOS object
                    tree_move(this, category.Index, index);
                    % move component in Peer Model
                    moveToTarget(category, this, index);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectMove', class(category), class(this)));
            end
        end
        
    end
    
end
