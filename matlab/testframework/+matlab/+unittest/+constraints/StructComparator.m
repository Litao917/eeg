classdef StructComparator < matlab.unittest.internal.constraints.FieldComparator
    % StructComparator - Comparator for comparing MATLAB structs.
    %
    %   The StructComparator natively supports structs (or arrays of
    %   structs) and performs a comparison by recursively examining the
    %   input data structures. By default, a struct comparator only
    %   supports empty struct arrays. However, it can support other data
    %   types during recursion by passing a comparator to the constructor.
    %   Also, by setting the Recursive property true and including the
    %   StructComparator in a ComparatorList, the StructComparator can
    %   support arbitrary collections of structures and other data types.
    %
    %   StructComparator properties:
    %      Recursive        - Optional boolean to compare data structures recursively
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   See also:
    %       matlab.unittest.constraints.ComparatorList
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    properties (Constant, Hidden, Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:StructComparator');
    end
    
    methods
        function comparator = StructComparator(varargin)
            comparator = comparator@matlab.unittest.internal.constraints.FieldComparator(varargin{:});
        end
        
        function bool = supports(~, value)
            bool = isstruct(value);
        end
    end
    
    methods (Hidden, Access=protected)
        function [bool, comparator] = haveAlreadyCompared(comparator, ~, ~)
            % Structures can't have cycles
            bool = false;
        end
    end
end