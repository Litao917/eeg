classdef (Hidden) ComparatorList < matlab.unittest.constraints.Comparator & ...
                                   matlab.unittest.internal.constraints.WithinMixin & ...
                                   matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                                   matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % ComparatorList - Comparator consisting of a collection of comparators.
    %
    %   A comparator list is defined by its collection of comparators. Put a
    %   different way, it supports anything its collection of comparators
    %   supports, and its notion of satisfaction is defined by the comparator
    %   that supports the type of the data being compared.
    %
    %   A comparator list is an ordered collection of comparators. Comparators
    %   can be added to front of the list. This data structure is appropriate
    %   because a supporting comparator is found by iterating over the list
    %   from its beginning to the end. The first comparator that is found that
    %   supports a given data type is the comparator that defines the
    %   comparator list's behavior for that data type. As such, a comparator
    %   earlier in the list takes precedence over another comparator later in
    %   the list if both support the same data type.
    %
    %   If a comparator list does not contain a comparator that supports a
    %   given data type, the comparator list does not support that data type.
    %   By default, a comparator list is empty and thus does not support any
    %   data types and cannot be satisfied.
    %
    %   A comparator list provides special behavior when it contains a
    %   recursive container comparator. When a recursive container comparator
    %   is placed into a comparator list, the recursive container comparator
    %   can contain any type that is supported by one of the comparators in
    %   the comparator list.
    %
    %   ComparatorList properties:
    %      Comparators      - A heterogeneous array of comparator objects
    %      ComparatorCount  - The number of comparators contained within the comparator list
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   ComparatorList methods:
    %      ComparatorList                 - Class constructor.
    %      addComparator                  - Adds a comparator at the front of the internal comparator list.
    %      clearComparators               - Clears the internal comparator list.
    %      getFirstComparatorThatSupports - Returns the first comparator in the list that supports a given data type.
    %      isEmpty                        - Returns a boolean value indicating if there are any comparators in the list.
    %
    %   See also
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Comparators - The list of comparators
        Comparators = matlab.unittest.internal.constraints.DefaultComparator.empty;
    end
    
    properties (Dependent, SetAccess = private)
        % ComparatorCount - The number of comparators contained within the comparator list
        ComparatorCount;
    end
    
    properties (Hidden, Constant, Access = protected)
        % DefaultTolerance - The tolerance that will be used by default
        %   when the 'Within' parameter is not specified by the user.
        DefaultTolerance = [];
    end
    
    methods
        function list = ComparatorList(varargin)
            % ComparatorList - Class constructor.
            
            list = list.parse(varargin{:});
        end
        
        function list = addComparator(list, comp)
            % addComparator - Adds a comparator to the front of the internal comparator list.
            
            validateattributes(comp, ...
                {'matlab.unittest.constraints.Comparator'}, ...
                {'scalar'}, '', 'comparator');
            
            list.Comparators = [comp, list.Comparators];
        end
        
        function list = clearComparators(list)
            % clearComparators - Clears the internal comparator list.
            
            list.Comparators = matlab.unittest.internal.constraints.DefaultComparator.empty;
        end
        
        function bool = supports(list, value)
            c = list.getFirstComparatorThatSupports(value);
            bool = ~isempty(c);
        end
        
        function count = get.ComparatorCount(list)
            count = numel(list.Comparators);
        end
        
        function [comp, n] = getFirstComparatorThatSupports(list, val)
            % getFirstComparatorThatSupports - Returns the first comparator in the list that supports a given data type.
            
            % Note that we return the comparator exactly as it was added to
            % the list (without applying any mixin properties (Tolerance,
            % IgnoreCase, etc.) to it). We assume that changing mixin
            % properties does not alter the value returned from the
            % supports method for any comparator in the list.
            
            comp = [];
            comps = list.Comparators;
            for n = 1:numel(comps)
                if comps(n).supports(val)
                    comp = comps(n);
                    return;
                end
            end
            n = [];
        end
        
        function bool = isEmpty(list)
            % isEmpty - Returns a boolean value indicating if there are any comparators in the list.
            
            bool = (list.ComparatorCount == 0);
        end
    end
    
    methods (Sealed)
        function bool = satisfiedBy(list, actVal, expVal)
            comp = list.getAndPrepareComparatorFor(expVal);
            bool = comp.satisfiedBy(actVal, expVal);
        end
        
        function diag = getDiagnosticFor(list, actVal, expVal)
            comp = list.getAndPrepareComparatorFor(expVal);
            diag = comp.getDiagnosticFor(actVal, expVal);
        end
    end
    
    methods (Hidden)
        function throwUnsupportedType(list, value)
            % throwUnsupportedType - Throw error when list does not contain a comparator supporting a value.
            
            import matlab.unittest.diagnostics.DisplayDiagnostic;
            
            diag = DisplayDiagnostic(value);
            diag.diagnose;
            
            error(message('MATLAB:unittest:ComparatorList:UnsupportedType', ...
                class(value), diag.DiagnosticResult, list.displayListContents()));
        end
        
        function contentsString = displayListContents(list)
            % Returns a string containing the contents of the List. This
            % method assumes that 'list' is a scalar.
            
            contentsString = [getString(message('MATLAB:unittest:ComparatorList:ListHeader')), ...
                list.displayListContentsWithoutHeader()];
        end
    end
    
    methods (Access = private)
        function listContents = displayListContentsWithoutHeader(list)
            % Private helper to build a string containing the contents of
            %   the List without a header. When the List contains another
            %   ComparatorList, this method recursively calls itself.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            listContents = '';
            function appendToContentsString(str)
                listContents = sprintf('%s\n%s', listContents, str);
            end
            
            if list.isEmpty()
                appendToContentsString(getString(message('MATLAB:unittest:ComparatorList:EmptyList')));
            end
            
            for n = 1:list.ComparatorCount
                listItem = list.Comparators(n);
                appendToContentsString(class(listItem));
                if isa(listItem, 'matlab.unittest.constraints.ComparatorList')
                    appendToContentsString(listItem.displayListContentsWithoutHeader());
                end
            end
            
            % Remove the extra newline at the beginning and indent
            listContents = regexprep(listContents, '\n', '', 'once');
            listContents = indent(listContents, '   ');
        end
        
        function comp = getAndPrepareComparatorFor(list, expVal)
            % getAndPrepareComparatorFor - Private helper to retrieve and
            %   prepare the comparator for use on an expected value.
            
            [comp, ind] = list.getFirstComparatorThatSupports(expVal);
            if isempty(comp)
                list.throwUnsupportedType(expVal);
            end
            
            if isa(comp, 'matlab.unittest.internal.constraints.ContainerComparator') && comp.Recursive
                % Set the ListPeers and ListIndex properties of the
                % ContainerComparator so that it can use in recursion its
                % peers in this list.
                list.Comparators(ind) = [];
                comp.ListPeers = list;
                comp.ListIndex = ind;
            end
            
            comp = list.applyMixinPropertiesToComparator(comp);
        end
        
        function comp = applyMixinPropertiesToComparator(list, comp)
            % Set any mixin properties on the supplied comparator.
            
            if list.wasExplicitlySpecified('Within') && isa(comp, 'matlab.unittest.internal.constraints.WithinMixin')
                comp = comp.within(list.Tolerance);
            end
            
            if list.IgnoreCase && isa(comp, 'matlab.unittest.internal.constraints.IgnoringCaseMixin')
                comp = comp.ignoringCase();
            end
            
            if list.IgnoreWhitespace && isa(comp, 'matlab.unittest.internal.constraints.IgnoringWhitespaceMixin')
                comp = comp.ignoringWhitespace();
            end
        end
    end
    
    methods (Hidden, Access = {?matlab.unittest.internal.constraints.ContainerComparator, ...
                               ?matlab.unittest.constraints.ComparatorList})
        function list = appendListContents(list, otherList)
            % appendListContents - Adds the contents of a comparator list to the end of the internal comparator list.
            
            validateattributes(otherList, ...
                {'matlab.unittest.constraints.ComparatorList'}, ...
                {'scalar'}, '', 'ComparatorList');
            
            list.Comparators = [list.Comparators, otherList.Comparators];
        end
        
        function list = appendComparator(list, comp)
            % appendComparator - Adds a comparator to the end of the internal comparator list.
            
            validateattributes(comp, ...
                {'matlab.unittest.constraints.Comparator'}, ...
                {'scalar'}, '', 'comparator');
            
            list.Comparators = [list.Comparators, comp];
        end
        
        function list = insertAt(list, index, comparator)
            % insertAt - Inserts a comparator at a specific index in the internal comparator list.
            
            compList = list.Comparators;
            if index == 1
                % add comparator at the beginning
                compList = [comparator, compList];
            elseif index == (numel(compList)+1)
                % append comparator at the end
                compList = [compList, comparator];
            else
                % insert at the right index
                compList = [compList(1:index-1), comparator, compList(index:end)];
            end           
            list.Comparators = compList;
        end
    end
end