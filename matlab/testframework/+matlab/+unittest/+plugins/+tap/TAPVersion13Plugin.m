classdef(Sealed) TAPVersion13Plugin < matlab.unittest.plugins.tap.TAPOriginalFormatPlugin
    %
    
    % This class is undocumented and will change in a future release.
    
    % Copyright 2013 The MathWorks, Inc.
   
    methods(Access={?matlab.unittest.plugins.TAPPlugin})
        function plugin = TAPVersion13Plugin(varargin)
            plugin@matlab.unittest.plugins.tap.TAPOriginalFormatPlugin(varargin{:});
        end
    end
    
    
    methods (Access=protected)
        
        function runTestSuite(plugin, pluginData)
            
            plugin.printLine('TAP version 13');
            runTestSuite@matlab.unittest.plugins.tap.TAPOriginalFormatPlugin(plugin, pluginData);

        end
        
    end
end

