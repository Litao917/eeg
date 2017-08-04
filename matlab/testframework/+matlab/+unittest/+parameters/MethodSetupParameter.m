classdef MethodSetupParameter < matlab.unittest.parameters.Parameter
    % MethodSetupParameter - Specification of a Method Setup Parameter.
    %
    %   The matlab.unittest.parameters.MethodSetupParameter class holds
    %   information about a single value of a Method Setup Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Method Setup Parameter
    %       Name     - Name of the Method Setup Parameter
    %       Value    - Value of the Method Setup Parameter
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    methods (Access=private)
        function methodParam = MethodSetupParameter(varargin)
            methodParam = methodParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function params = getParameters(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            
            params = SetupParameter.getSetupParameters(testClass, ...
                @MethodSetupParameter, 'TestMethodSetup', 'MethodSetupParameter');
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.MethodSetupParameter;
            
            param = SetupParameter.fromName(testClass, propName, name, ...
                @MethodSetupParameter, 'MethodSetupParameter');
        end
        
        function names = getAllParameterProperties(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            
            names = SetupParameter.getAllParameterProperties(testClass, ...
                'TestMethodSetup');
        end
    end
end