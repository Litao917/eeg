classdef (Sealed) HasBaseFolder < matlab.unittest.internal.selectors.Selector
    % HasBaseFolder - Select TestSuite elements by defining folder.
    %
    %   The HasBaseFolder selector filters TestSuite array elements based on
    %   the name of the folder where the test class or function is defined. The
    %   base folder is defined as the absolute path to the folder that stores
    %   the test file. For test classes defined in packages, the base folder is
    %   the parent of the top-level package folder. The base folder never
    %   contains any folders that start with "+" or "@".
    %
    %   HasBaseFolder methods:
    %       HasBaseFolder - Class constructor
    %
    %   HasBaseFolder properties:
    %       Constraint - Condition that the base folder must satisfy.
    %
    %   Example:
    %
    %       import matlab.unittest.selectors.HasBaseFolder;
    %       import matlab.unittest.constraints.ContainsSubstring;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromFolder('MyTests', 'IncludingSubfolders', true);
    %
    %       % Select all TestSuite elements for test classes and functions
    %       % that are defined in folders that do not contain the string "Feature1".
    %       newSuite = suite.selectIf(~HasBaseFolder(ContainsSubstring('Feature1')));
    %
    %   See also: matlab.unittest.TestSuite/selectIf
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Constraint - Condition that the base folder must satisfy.
        %   The Constraint property is a matlab.unittest.constraints.Constraint
        %   instance which specifies the condition that the base folder for a
        %   TestSuite array element must satisfy in order to be retained.
        Constraint
    end
    
    methods
        function selector = HasBaseFolder(folderName)
            % HasBaseFolder - Class constructor
            %
            %   selector = HasBaseFolder(FOLDERNAME) creates a selector that filters
            %   TestSuite array elements by defining folder. FOLDERNAME can be either a
            %   string or a matlab.unittest.constraints.Constraint instance. When
            %   FOLDERNAME is a string, only the TestSuite array elements whose base
            %   folder exactly matches FOLDERNAME are retained. When FOLDERNAME is a
            %   constraint, the TestSuite array element's base folder must satisfy the
            %   constraint in order to be retained.
            
            import matlab.unittest.internal.selectors.convertStringToConstraint;
            selector.Constraint = convertStringToConstraint(folderName);
        end
    end
    
    methods (Hidden)
        function bool = uses(~, attributeClass)
            bool = attributeClass <= ?matlab.unittest.internal.selectors.BaseFolderAttribute;
        end
        
        function result = select(selector, attributes)
            for currentAttribute = attributes
                if ~currentAttribute.acceptsBaseFolder(selector);
                    result = false;
                    return;
                end
            end
            
            result = true;
        end
    end
end

% LocalWords:  Subfolders FOLDERNAME
