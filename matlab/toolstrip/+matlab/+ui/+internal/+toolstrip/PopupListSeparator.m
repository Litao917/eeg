classdef PopupListSeparator < matlab.ui.internal.toolstrip.base.Component
    % Popup List Separator
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListSeparator.PopupListSeparator">PopupListSeparator</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Index">Index</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.PopupList
   
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = PopupListSeparator(varargin)
            % Constructor "PopupListSeparator": 
            %
            %   Creates a popup list separator
            %
            %   Examples:
            %       separator = matlab.ui.internal.toolstrip.PopupListSeparator();
            %       popup.add(separator)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Component();
            % set type
            this.Type = 'PopupListSeparator';
            % create peer node
            this.createPeer();
        end
        
    end
    
end

