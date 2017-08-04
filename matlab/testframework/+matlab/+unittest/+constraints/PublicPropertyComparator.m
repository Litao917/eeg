classdef PublicPropertyComparator < matlab.unittest.internal.constraints.FieldComparator
    % PublicPropertyComparator - Compare the public properties of MATLAB objects
    %   The PublicPropertyComparator supports MATLAB objects (or arrays of
    %   objects) and performs comparison by recursively comparing data
    %   structures contained in the public properties. By default,
    %   PublicPropertyComparator only supports objects that have no public
    %   properties. However, it can support other data types during recursion
    %   by passing a comparator to the constructor. The supportingAllValues
    %   static method can also be used to construct a PublicPropertyComparator
    %   that supports all MATLAB data types in recursion. PublicPropertyComparator
    %   differs from the isequal function in that it only examines the public
    %   properties of the objects.
    %
    %   PublicPropertyComparator properties:
    %      Recursive        - Optional boolean to compare data structures recursively
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   PublicPropertyComparator methods:
    %      supportingAllValues - Create a PublicPropertyComparator that supports any value in recursion
    %
    % Examples:
    %      import matlab.unittest.constraints.IsEqualTo;
    %      import matlab.unittest.constraints.PublicPropertyComparator;
    %      import matlab.unittest.TestCase;
    %
    %      % Create a TestCase for interactive use
    %      testCase = TestCase.forInteractiveUse;
    %
    %      % Passing case
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','MsgText');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues));
    %      
    %      % Failing case
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','msgtext');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues));
    %
    %      % Passing case (the strings are compared ignoring case differences)
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','msgtext');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues,'IgnoringCase',true));
    %
    %  See also
    %       matlab.unittest.constraints.IsEqualTo
    %       matlab.unittest.constraints.ObjectComparator
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (Constant, Hidden, Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:PublicPropertyComparator');
    end
    
    properties (Access=private)
        % Cell arrays of handle objects that have been compared for use in
        % cycle detection.
        ActualValueHandlesCompared = {};
        ExpectedValueHandlesCompared = {};
    end
    
    methods (Static)
        function comparator = supportingAllValues
            % supportingAllValues - Create a PublicPropertyComparator that supports any value in recursion
            %
            %   COMPARATOR = matlab.unittest.constraints.PublicPropertyComparator.supportingAllValues
            %   creates PublicPropertyComparator that supports any value in recursion.

            import matlab.unittest.constraints.PublicPropertyComparator;
            import matlab.unittest.constraints.IsEqualTo;
            
            % Return a comparator that supports only objects at the top
            % level but supports any value in recursion.
            list = IsEqualTo.DefaultComparatorList;
            list = list.addComparator(PublicPropertyComparator('Recursively',true));
            comparator = PublicPropertyComparator(list);
        end
    end
    
    methods
        function comparator = PublicPropertyComparator(varargin)
            comparator = comparator@matlab.unittest.internal.constraints.FieldComparator(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = (isobject(value) && ~isempty(metaclass(value))) || ...
                isa(value, 'handle.handle');
        end
    end
    
    methods (Hidden, Access=protected)
        function [bool, comparator] = haveAlreadyCompared(comparator, actVal, expVal)
            % Implement cycle detection for handle objects
            
            bool = false;
            
            if isa(actVal,'handle')
                actVisited = cellfun(@(h)h==actVal, comparator.ActualValueHandlesCompared);
                expVisited = cellfun(@(h)h==expVal, comparator.ExpectedValueHandlesCompared);
                
                if any(actVisited & expVisited)
                    bool = true;
                    return;
                else
                    comparator.ActualValueHandlesCompared = [comparator.ActualValueHandlesCompared {actVal}];
                    comparator.ExpectedValueHandlesCompared = [comparator.ExpectedValueHandlesCompared {expVal}];
                end
            end
        end
    end
end

% LocalWords:  msgtext