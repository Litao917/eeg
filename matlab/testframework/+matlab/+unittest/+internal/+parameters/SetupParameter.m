classdef SetupParameter < matlab.unittest.parameters.Parameter
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods (Static)
        function params = getSetupParameters(testClass, paramConstructor, setupType, paramType)
            import matlab.unittest.parameters.Parameter;
            import matlab.unittest.parameters.EmptyParameter;
            
            % Get a mapping from parameter names to the method(s) which use that parameter.
            paramNameToMethodsMap = getSetupParameterMap(testClass, setupType);
            
            if isempty(paramNameToMethodsMap)
                % No setup level parameterization.
                params = {EmptyParameter.empty};
                return;
            end
            
            % Construct Parameter arrays for each parameter used.
            setupParameterArrays = getSetupLevelParameters(paramNameToMethodsMap, ...
                paramConstructor, paramType, testClass);
            
            % Determine how the setup methods combine the parameters.
            setupLevelCombinationAttribute = getCombinationAttribute( ...
                paramNameToMethodsMap, setupType, testClass);
            
            [status, params] = Parameter.combineParameters( ...
                setupParameterArrays, setupLevelCombinationAttribute);
            
            if ~status
                error(message('MATLAB:unittest:Parameter:IncompatibleParameterSizesSetupMethods', ...
                    setupType, testClass.Name));
            end
        end
        
        function param = fromName(testClass, propName, name, paramConstructor, paramType)
            
            prop = testClass.PropertyList.findobj('Name',propName, paramType,true);
            if isempty(prop)
                error(message('MATLAB:unittest:Parameter:PropertyNotFound', ...
                    testClass.Name, paramType, propName));
            end
            
            param = paramConstructor(prop, name);
        end
        
        function names = getAllParameterProperties(testClass, setupType)
            paramNameToMethodsMap = getSetupParameterMap(testClass, setupType);
            names = sort(paramNameToMethodsMap.keys);
        end
    end
end


function paramNameToMethodsMap = getSetupParameterMap(testClass, setupType)
% getSetupParameterMap - Return a mapping from parameter names to the
%   method(s) which use that parameter.

import matlab.unittest.parameters.Parameter;

setupMethods = rot90(testClass.MethodList.findobj(setupType,true));
paramNameToMethodsMap = containers.Map('KeyType','char', 'ValueType','any');

for method = setupMethods
    paramNames = Parameter.getParameterNamesFor(method);
    
    for parameterIdx = 1:numel(paramNames)
        parameterName = paramNames{parameterIdx};
        
        % Add the method to the map, appending to the list of other methods
        % that also use the parameter.
        if paramNameToMethodsMap.isKey(parameterName)
            paramNameToMethodsMap(parameterName) = [paramNameToMethodsMap(parameterName), method];
        else
            paramNameToMethodsMap(parameterName) = method;
        end
    end
end
end


function parameterArrays = getSetupLevelParameters(parameterMap, parameterConstructor, paramType, testClass)
% getSetupLevelParameters - Construct arrays of setup-level Parameters.

parameterNames = sort(parameterMap.keys);
numSetupParameters = numel(parameterNames);
parameterArrays = cell(1, numSetupParameters);

setupParameterProperties = testClass.PropertyList.findobj(paramType,true);

for paramIdx = 1:numSetupParameters
    paramName = parameterNames{paramIdx};
    
    prop = setupParameterProperties.findobj('Name',paramName);
    
    if isempty(prop)
        % Get the name of a method that uses the parameter. There could be
        % more than one such method, but we need only one.
        methods = parameterMap(paramName);
        methodName = methods(1).Name;
        
        error(message('MATLAB:unittest:Parameter:ParameterDoesNotExist', ...
            testClass.Name, paramType, paramName, methodName));
    end
    
    parameterArrays{paramIdx} = parameterConstructor(prop);
end
end


function combinationAttribute = getCombinationAttribute(paramNameToMethodMap, setupType, testClass)
% getCombinationAttribute - Determine how setup method parameters are combined.

import matlab.unittest.parameters.Parameter;

parameterizedMethods = values(paramNameToMethodMap);
parameterizedMethods = [parameterizedMethods{:}];

allParameterCombinationAttributes = {parameterizedMethods.ParameterCombination};
allParameterCombinationAttributes(strcmp(allParameterCombinationAttributes, '')) = ...
    {Parameter.DefaultCombinationAttribute};
combinationAttribute = unique(allParameterCombinationAttributes);

if numel(combinationAttribute) ~= 1
    error(message('MATLAB:unittest:Parameter:ConflictingParameterCombinationAttribute', ...
        setupType, testClass.Name));
end

combinationAttribute = combinationAttribute{1};
end