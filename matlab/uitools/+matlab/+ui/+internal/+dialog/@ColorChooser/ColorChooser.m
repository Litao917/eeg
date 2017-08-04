classdef ColorChooser < matlab.ui.internal.dialog.Dialog
% This function is undocumented and will change in a future release

%   Copyright 2008-2010 The MathWorks, Inc.
    properties
        InitialColor = [];
        Title = '';
    end
    
    properties(SetAccess='private',GetAccess='public')
        SelectedColor;
    end
    
    properties(SetAccess='public',GetAccess='public',Dependent=true)
        Red = [];
        Green = [];
        Blue = [];
    end
    
    methods
        function obj = set.InitialColor(obj, v)
            %We are not going to allow values like [true false false]
            %as valid colors
            if ~isnumeric(v)
                error(message('MATLAB:UiColorChooser:InvalidColorType'));
            end
            %if multidimensional or column wise vector is given, extract color values
            obj.InitialColor = convert(obj,v);
        end

        function out = get.Red(obj)
           out = obj.InitialColor(1);
        end
        function obj = set.Red(obj, v)
           obj.InitialColor(1) = v;
        end
        
        function out = get.Green(obj)
           out = obj.InitialColor(2);
        end
        function obj = set.Green(obj, v)
           obj.InitialColor(2) = v;
        end
        
        function out = get.Blue(obj)
           out = obj.InitialColor(3);
        end
        function obj = set.Blue(obj, v)
           obj.InitialColor(3) = v;
        end
        function obj = set.Title(obj,v)
            if ~ischar(v) 
                    error(message('MATLAB:UiColorChooser:InvalidTitle'));
            end
            if ~isempty(v)
                    obj.Title = v;
            end
        end
        
    end
    
    methods
        function obj = ColorChooser(varargin)
            initialize(obj);
            if rem(length(varargin), 2) ~= 0
                error(message('MATLAB:UiColorChooser:UnpairedParamsValues'));
            end

            for i = 1:2:length(varargin)

                if ~ischar(varargin{i})
                    error (message('MATLAB:UiColorChooser:IllegalParameterType', i));
                end

                fieldname = varargin{i};
                if isValidFieldName(obj,fieldname)
                    obj.(fieldname) = varargin{i+1};
                else
                    error(message('MATLAB:UiColorChooser:IllegalParameter', varargin{ i }));
                end
            end
            createPeer(obj);
        end
        
        function bool = isValidFieldName(obj,v)
            switch v
                case {'Red','Green','Blue','InitialColor','Title'}
                    bool = true;
                otherwise
                    bool = false;
            end
        end
        
        function initialize(obj)
            obj.InitialColor = [1 1 1];
            obj.Title = getString(message('MATLAB:uistring:uisetcolor:TitleColor'));
        end
        
        function createPeer(obj)
            if ~isempty(obj.Peer)
                delete(obj.Peer);
            end
            obj.Peer = handle(javaObjectEDT('com.mathworks.mlwidgets.graphics.ColorDialog',obj.Title),'callbackproperties');
        end
        
              
        function setPeerInitialColor(obj,v)
            jColor = java.awt.Color(v(1),v(2),v(3));
            obj.Peer.setInitialColor(jColor);
            %awtinvoke(obj.Peer,'setInitialColor(Ljava.awt.Color;)',jColor);
        end
        
        
        function show(obj)
            setPeerTitle(obj,obj.Title);
            setPeerInitialColor(obj,obj.InitialColor);
            jSelectedColor = obj.Peer.showDialog(obj.getParentFrame);
            if ~isempty(jSelectedColor)
                obj.SelectedColor = convertZeroToOne(obj,[jSelectedColor.getRed  jSelectedColor.getGreen jSelectedColor.getBlue]);
            else
                obj.SelectedColor = [];
            end
        end
        
        
        function out = convertZeroToOne(obj,v)
            out = v/255;
        end
        
        function out = convertZero255(obj,v)
            out = v * 255;
        end
    end
    
    methods(Access = 'protected')
        function setPeerTitle(obj,v)
            obj.Peer.setTitle(v);
            %awtinvoke(obj.Peer,'setTitle(Ljava.lang.String;)',java.lang.String(v));
        end
    end
    methods(Access='private')
        function bool = isvalidmultidimensional(obj,v)
            sizeofv = size(v);
            occurrencesofthree = find(sizeofv==3);
            if (length(occurrencesofthree)~=1  && prod(sizeofv)~=3)
                bool =false;
            else
                bool = true;
            end
        end
        function color = convert(obj,v)
            if isvalidmultidimensional(obj,v)
                color = [v(1) v(2) v(3)];
            else
                color = [];
                error(message('MATLAB:UiColorChooser:InvalidColorDimension'));
            end
            %Checking range of rgb values
            if ismember(0,((color(:)<=1) & (color(:)>=0)))
                error(message('MATLAB:UiColorChooser:InvalidRGBRange'));
            end
        end
        
    end
end
