classdef GalleryCategory < matlab.ui.internal.toolstrip.base.Container & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title
    % Gallery Category
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryCategory.GalleryCategory">GalleryCategory</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title">Title</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryCategory.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryCategory.remove">remove</a>
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
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryCategory(varargin)
            % Constructor "GalleryCategory": 
            %
            %   Creates a gallery category.
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
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup();
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('GalleryCategory',varargin{:});
        end
        
        %% Public API: add and remove
        function add(this, item, varargin)
            % Method "add":
            %
            %   "add(category, item)": add an item at the end of the category.
            %   Example:
            %       category = matlab.ui.internal.toolstrip.GalleryCategory('foo')
            %       item = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       category.add(item)
            %
            %   "add(category, item, index)": insert an item at a specified location in the category.
            %   Example:
            %       category = matlab.ui.internal.toolstrip.GalleryCategory('foo')
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item2 = matlab.ui.internal.toolstrip.GalleryItem('open')
            %       category.add(item1)
            %       category.add(item2, 1) % insert "open" before "new"
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem')
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(item), class(this)));
            end
            % refresh gallery
            popup = this.Parent;
            if ~isempty(popup) && isvalid(popup)
                popup.notify('RefreshGallery');
            end
        end
        
        function remove(this, item)
            % Method "remove":
            %
            %   "remove(category, item)": remove an item from the category.
            %   Example:
            %       category = matlab.ui.internal.toolstrip.GalleryCategory('foo')
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item2 = matlab.ui.internal.toolstrip.GalleryItem('open')
            %       category.add(item1)
            %       category.add(item2)
            %       category.remove(item1) % remove "open"
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem')
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(item), class(this)));
            end
            % refresh gallery
            popup = this.Parent;
            if ~isempty(popup) && isvalid(popup)
                popup.notify('RefreshGallery');
            end
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties = this.getDefaultTitleProperties(properties);
            properties.displayState = 'icon_view';
        end
        
        function rules = getInputArgumentRules(this)
            rules = getInputArgumentRules@matlab.ui.internal.toolstrip.base.Container(this);
            rules.peerproperties.title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'title'}};
        end
        
        function PeerEventCallback(this,~,data)
            % client side event
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'CategoryMoved')
                % it does not trigger RefreshGalleryFromAPI event
                this.Parent.move(this, 1);
                % refresh gallery
                this.Parent.notify('RefreshGallery');
            end
        end
        
    end
    
end
