classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) LinkAxes < handle
% This class is undocumented and will change in a future release
   
% Container class for a linkprop object used for linkaxes operations 
% where de-serialization restores the linkaxes  
    
%   Copyright 2010 The MathWorks, Inc.
    
    properties
       Targets;
       PropertyNames;
    end
 
    properties (Transient = true)
        LinkProp; % Listeners in linkprop objects cannot be serialized
    end     
   
    methods 
        
        function this = LinkAxes(varargin)
            this = this@handle;
            if nargin>=1
                this.LinkProp = varargin{1};
            end
        end
        
        % Serialize the Target and PropertyNames
        function this = saveobj(this)
            if ~isempty(this.LinkProp)
                this.Targets = this.LinkProp.Targets;
                this.PropertyNames = this.LinkProp.PropertyNames;
            end
        end
        
        function removetarget(h,target)
            if ~isempty(this.LinkProp)
                removetarget(this.LinkProp,target)
            end
        end
            
    end
            
   methods (Static = true) 
        % Restore the linkaxes on de-serialization.
        function this = loadobj(this)
            if ~isempty(this.Targets) && ~isempty(this.PropertyNames) && ...
                    all(ishghandle(this.Targets,'axes'))
                this.LinkProp = linkprop(this.Targets,this.PropertyNames);
            end
        end
   end
   

end