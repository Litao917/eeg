classdef TestParameter < matlab.unittest.parameters.Parameter
    % TestParameter - Specification of a Test Parameter.
    %
    %   The matlab.unittest.parameters.TestParameter class holds
    %   information about a single value of a Test Parameter.
    %
    %   TestParameter properties:
    %       Property - Name of the property that defines the Test Parameter
    %       Name     - Name of the Test Parameter
    %       Value    - Value of the Test Parameter
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    methods (Access=private)
        function testParam = TestParameter(varargin)
            testParam = testParam@matlab.unittest.parameters.Parameter(varargin{:});
        end
    end
    
    methods (Hidden, Static)
        function parameterMap = getParameters(testClass, testMethods)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.TestParameter;
            import matlab.unittest.parameters.EmptyParameter;
            
            % Initialize a map of parameter arrays to return
            parameterMap = containers.Map('KeyType','char', 'ValueType','any');
            
            % Construct a map of all the TestParameters in the class so
            % that we only have to construct the TestParameter array once
            % for each property.
            testParameterProperties = rot90(testClass.PropertyList.findobj('TestParameter',true));
            parameterPropMap = containers.Map('KeyType','char', 'ValueType','any');
            for prop = testParameterProperties
                parameterPropMap(prop.Name) = TestParameter(prop);
            end
            
            for methodIdx = 1:numel(testMethods)
                method = testMethods(methodIdx);
                methodName = method.Name;
                
                testParameterNames = Parameter.getParameterNamesFor(method);
                
                numParams = numel(testParameterNames);
                if numParams == 0
                    % Method is not parameterized
                    parameterMap(methodName) = {EmptyParameter.empty};
                    continue;
                end
                
                % Look up values of the Test Parameters and store in a cell array.
                parameters = cell(1, numParams);
                for paramIdx = 1:numParams
                    paramName = testParameterNames{paramIdx};
                    
                    if ~parameterPropMap.isKey(paramName);
                        error(message('MATLAB:unittest:Parameter:ParameterDoesNotExist', ...
                            testClass.Name, 'TestParameter', paramName, methodName));
                    end
                
                    parameters{paramIdx} = parameterPropMap(paramName);
                end
                
                % Create the combinations according to the ParameterCombination attribute.
                [status, parameterMap(methodName)] = Parameter.combineParameters( ...
                    parameters, method.ParameterCombination);
                
                if ~status
                    error(message('MATLAB:unittest:Parameter:IncompatibleParameterSizes', ...
                        methodName, testClass.Name));
                end
            end
        end
        
        function param = fromName(testClass, propName, name)
            import matlab.unittest.parameters.TestParameter;
            
            prop = testClass.PropertyList.findobj('Name',propName, 'TestParameter',true);
            if isempty(prop)
                error(message('MATLAB:unittest:Parameter:PropertyNotFound', ...
                    testClass.Name, 'TestParameter', propName));
            end
            
            param = TestParameter(prop, name);
        end
        
        function names = getAllParameterProperties(testClass, methodName)
            import matlab.unittest.parameters.Parameter;
            
            method = testClass.MethodList.findobj('Name',methodName);
            names = Parameter.getParameterNamesFor(method);
        end
    end
end