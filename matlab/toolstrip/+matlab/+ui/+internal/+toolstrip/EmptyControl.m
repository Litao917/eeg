classdef EmptyControl < matlab.ui.internal.toolstrip.base.Component
    % Empty Control
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EmptyControl.EmptyControl">EmptyControl</a>    
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
    % See also matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = EmptyControl(varargin)
            % Creates an empty control.
            %
            % Example:
            %   obj = matlab.ui.internal.toolstrip.EmptyControl()
            %   column.add(obj);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Component();
            % set type
            this.Type = 'EmptyControl';
            % create peer node
            this.createPeer();
        end
        
    end
    
end

