classdef Gallery < matlab.ui.internal.toolstrip.base.Container
    % Gallery
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.Gallery">Gallery</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.MaxColumnCount">MaxColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.MinColumnCount">MinColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.Popup">Popup</a>   
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % Note: the children of a Gallery object refer to the gallery items
    % displayed in the main gallery strip in the toolstrip.  Items in the
    % gallery popup do not count because they are considered as the
    % descendents of the gallery popup.
    %
    % See also matlab.ui.internal.toolstrip.GalleryPopup
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, SetAccess = private)
        % Property "MaxColumnCount": 
        %
        %   The maximum number of columns that can be used in the gallery
        %   display. The default value is 10 columns.  The property is
        %   read-only.  Custom value must be provided during construction.
        %
        MaxColumnCount
        % Property "MinColumnCount": 
        %
        %   The minimum number of columns that can be used in the gallery
        %   display.  The default value is 1 column.  The property is
        %   read-only.  Custom value must be provided during construction.
        %
        MinColumnCount
        % Property "Popup": 
        %
        %   A GalleryPopup object that represents the gallery popup
        %   displayed under the gallery.  The property is read-only.  You
        %   must specify the GalleryPopup object in the constructor.
        %
        Popup
    end
    
    properties (Access = private)
        Popup_
        RefreshListenerFromAPI
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Gallery(varargin)
            % Constructor "Gallery": 
            %
            %   Creates a gallery.
            %
            %   Examples:
            %
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('Item1');
            %       item2 = matlab.ui.internal.toolstrip.GalleryItem('Item2');
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
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup, 'MaxColumnCount', 12, 'MinColumnCount', 3);
            %
            %   Note that: after a gallery object is constructed, you
            %   cannot switch to another gallery popup.
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('Gallery', varargin{:});
            % refresh
            this.refresh;
            % add listener to refresh when popup is changed
            this.RefreshListenerFromAPI = addlistener(this.Popup,'RefreshGallery',@(src, event) refresh(this));
        end
        
        %% Public API: Get/Set
        function value = get.Popup(this)
            % GET function for Popup property.
            value = this.Popup_;
        end
        
        function value = get.MaxColumnCount(this)
            % GET function for MaxColumnCount property.
            value = this.getPeerProperty('maxColumnCount');
        end
        
        function value = get.MinColumnCount(this)
            % GET function for MinColumnCount property.
            value = this.getPeerProperty('minColumnCount');
        end
        
    end
    
    methods (Hidden)
            
        %% Public API: add and remove
        function add(this, item, varargin)
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem')
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(item), class(this)));
            end
        end
        
        function remove(this, item)
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem')
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(item), class(this)));
            end
        end
        
    end
    
    methods (Access = protected)
        
        function properties = getDefaultWidgetProperties(this)
            properties = getDefaultWidgetProperties@matlab.ui.internal.toolstrip.base.Container(this);
            properties.galleryPopupId = '';
            properties.maxColumnCount = 10;
            properties.minColumnCount = 1;
            % internal
            properties.galleryItemRowCount = 1;
            properties.galleryItemTextLineCount = 2;
            properties.galleryItemWidth = 80;
        end
        
        function widget_properties = getCustomWidgetProperties(this, widget_properties, varargin)
            %  popup
            if nargin==2
                error(message('MATLAB:toolstrip:container:invalidGalleryPopupInput'));
            end
            popup = varargin{1};
            if isa(popup, 'matlab.ui.internal.toolstrip.GalleryPopup')
                this.Popup_ = popup;
            else
                error(message('MATLAB:toolstrip:container:invalidGalleryPopupInput'));
            end
            % set popup id
            widget_properties.galleryPopupId = popup.getId();
            widget_properties.galleryItemRowCount = popup.GalleryItemRowCount;
            widget_properties.galleryItemTextLineCount = popup.GalleryItemTextLineCount;
            widget_properties.galleryItemWidth = popup.GalleryItemWidth;
            % set optional properties
            ni = nargin-3;
            if rem(ni,2)~=0,
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'maxColumnCount','minColumnCount'};
            for ct=1:2:ni
                prop = varargin{ct+1};
                value = varargin{ct+2};
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(prop,PublicProps);
                switch name
                    case 'maxColumnCount'
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidMaxColumnCount'))
                        end
                    case 'minColumnCount'
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidMinColumnCount'))
                        end
                end
            end
        end
    
        function refresh(this)
            % get sorted actions from popup
            allactions = this.Popup.getSortedActions();
            % get number of items
            len = min(this.MaxColumnCount, length(allactions));
            % remove old items
            for k = length(this.Children):-1:1
                this.remove(this.Children(k));
            end
            % add new items
            for ct = 1:len
                item = matlab.ui.internal.toolstrip.GalleryItem(allactions(ct));
                this.add(item);
            end
        end
        
    end
    
end
