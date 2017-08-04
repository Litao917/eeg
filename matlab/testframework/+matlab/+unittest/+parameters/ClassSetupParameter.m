classdef ClassSetupParameter < matlab.unittest.parameters.Parameter
    % ClassSetupParameter - Specification of a Class Setup Parameter.
    %
    %   The matlab.unittest.parameters.ClassSetupParameter class holds
    %   information about a single value of a Class Setup Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Class Setup Parameter
    %       Name     - Name of the Class Setup Parameter
    %       Value    - Value of the Class Setup Parameter
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    methods (Access=private)
        function classParam = ClassSetupParameter(varargin)
            classParam = classParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function params = getParameters(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.ClassSetupParameter;
            
            params = SetupParameter.getSetupParameters(testClass, ...
                @ClassSetupParameter, 'TestClassSetup', 'ClassSetupParameter');
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.internal.parameters.SetupParameter;
            import matlab.unittest.parameters.ClassSetupParameter;
            
            param = SetupParameter.fromName(testClass, propName, name, ...
                @ClassSetupParameter, 'ClassSetupParameter');
        end
        
        function names = getAllParameterProperties(testClass)
            import matlab.unittest.internal.parameters.SetupParameter;
            
            names = SetupParameter.getAllParameterProperties(testClass, ...
                'TestClassSetup');
        end
    end
end