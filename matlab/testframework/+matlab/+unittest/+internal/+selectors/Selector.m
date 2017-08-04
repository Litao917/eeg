classdef Selector
    % Selector - Interface for TestSuite selection.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    methods (Hidden, Abstract)
        % uses - Returns a boolean indicating whether the selector uses a specified attribute.
        %
        %   The uses method provides the selector the opportunity to specify which
        %   attributes it uses when filtering a suite.
        bool = uses(selector, attributeClass)
        
        % select - Filter suite elements.
        %
        %   The select method returns the result of filtering a suite. It is passed
        %   an array of matlab.unittest.internal.selectors.SelectionAttribute
        %   instances, each of which holds a piece of data of interest from a
        %   TestSuite array element. The select method must return either true
        %   (select) or false (filter).
        bool = select(selector, attributes)
    end
    
    methods (Sealed)
        function andSelector = and(firstSelector, secondSelector)
            % and - Logical conjunction of two selectors.
            %
            %   and(selector1, selector2) returns a selector which is the boolean
            %   conjunction of selector1 and selector2. This is a means to specify that
            %   a suite element must satisfy two selection criteria.
            %
            %   Typically, the AND method is not called directly, but the MATLAB "&"
            %   operator is used to denote the conjunction of any two selector objects.
            %
            %   Example:
            %
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasSharedTestFixture;
            %       import matlab.unittest.selectors.HasParameter;
            %       import matlab.unittest.fixtures.PathFixture;
            %
            %       % Create a TestSuite to filter
            %       suite = TestSuite.fromPackage('mypackage');
            %
            %       % Select suite elements that are parameterized AND use a PathFixture.
            %       newSuite = suite.selectIf(HasParameter & HasSharedTestFixture(PathFixture));
            %
            %   See also: or, not
            
            import matlab.unittest.selectors.AndSelector;
            andSelector = AndSelector(firstSelector, secondSelector);
        end
        
        function orSelector = or(firstSelector, secondSelector)
            % or - Logical disjunction of two selectors.
            %
            %   or(selector1, selector2) returns a selector which is the boolean
            %   disjunction of selector1 and selector2. This is a means to specify that
            %   a suite element must satisfy either of two selection criteria.
            %
            %   Typically, the OR method is not called directly, but the MATLAB "|"
            %   operator is used to denote the disjunction of any two selectors
            %   objects.
            %
            %   Example:
            %
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasSharedTestFixture;
            %       import matlab.unittest.selectors.HasParameter;
            %       import matlab.unittest.fixtures.PathFixture;
            %
            %       % Create a TestSuite to filter
            %       suite = TestSuite.fromPackage('mypackage');
            %
            %       % Select suite elements that are parameterized OR use a PathFixture.
            %       newSuite = suite.selectIf(HasParameter | HasSharedTestFixture(PathFixture));
            %
            %   See also: and, not
            
            import matlab.unittest.selectors.OrSelector;
            orSelector = OrSelector(firstSelector, secondSelector);
        end
        
        function notSelector = not(selector)
            % not - Logical negation of a selector.
            %
            %   not(selector) returns a selector that is the boolean complement of the
            %   selector provided. This is a means to specify that a suite element
            %   should be retained if it does not satisfy a selection criterion.
            %
            %   Typically, the NOT method is not called directly, but the MATLAB "~"
            %   operator is used to denote the negation of any given selector.
            %
            %   Examples:
            %
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.selectors.HasSharedTestFixture;
            %       import matlab.unittest.selectors.HasParameter;
            %       import matlab.unittest.fixtures.PathFixture;
            %
            %       % Create a TestSuite to filter
            %       suite = TestSuite.fromPackage('mypackage');
            %
            %       % Select suite elements that are not parameterized.
            %       newSuite = suite.selectIf(~HasParameter);
            %
            %       % Select suite elements that do not use a PathFixture.
            %       newSuite = suite.selectIf(~HasSharedTestFixture(PathFixture));
            %
            %   See also: and, or
            
            import matlab.unittest.selectors.NotSelector;
            notSelector = NotSelector(selector);
        end
    end
end

% LocalWords:  mypackage
