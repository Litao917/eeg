classdef (Hidden) ContainerComparator < matlab.unittest.constraints.Comparator & ...
                                        matlab.unittest.internal.constraints.RecursivelyMixin & ...
                                        matlab.unittest.internal.constraints.WithinMixin & ...
                                        matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                                        matlab.unittest.internal.constraints.IgnoringWhitespaceMixin
    % ContainerComparator - Comparator that algorithmically compares specific data structures.
    %
    %   A container comparator is an interface for comparators that have
    %   intimate knowledge of the structure of certain data types.
    %   Container comparators perform comparisons by examining the elements
    %   they contain.
    %
    %   A container comparator can support different data types in recursion
    %   than it does natively. The idea is that a container comparator may
    %   support a set of data types that contain a completely different set of
    %   data types. An example of this would be a container comparator that
    %   supports cell arrays that can only contain strings.
    %
    %   By default, a container comparator only supports empty containers. By
    %   providing a comparator argument to the constructor, the container
    %   comparator supports in recursion any types that the supplied comparator
    %   supports. For example, a container comparator could be configured to
    %   only compare strings by passing a string comparator to the constructor
    %   of the container comparator.
    %
    %   A recursive container comparator natively supports only itself in
    %   recursion. That is, the container can itself contain other
    %   containers, but not other data types.
    %
    %   By supplying a comparator in a call to the container comparator
    %   constructor and setting the Recursive property true, the container
    %   comparator supports in recursion both itself and the types
    %   supported by the supplied comparator.
    %
    %   When the Recursive property is true, the container comparator also
    %   supports in recursion any comparators contained in the comparator
    %   list that contains the recursive container comparator. This can be
    %   useful when one container can contain another container type, e.g.,
    %   a cell array containing a structure.
    %
    %   ContainerComparator properties:
    %      Recursive        - Optional boolean to compare data structures recursively
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   ContainerComparator methods:
    %       ContainerComparator  - Class constructor
    %       appendComparator     - Adds a comparator to the end of the internal comparator list
    %       appendListContents   - Adds the contents of a comparator list to the end of the internal comparator list
    %       getComparatorFor     - Returns a comparator for a value contained in the data structure
    %
    %   See also
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.ComparatorList
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=private)
        % CompList - A comparator list used for comparing contained elements
        %   Subclasses of ContainerComparator should use the getComparatorFor
        %   method rather than accessing the CompList property to retrieve the
        %   correct comparator when iterating over a data structure.
        CompList = matlab.unittest.constraints.ComparatorList;
    end
    
    properties (Access=?matlab.unittest.constraints.ComparatorList)
        % ListPeers - Comparators that had been peers of the ContainerComparator
        %   in a ComparatorList. The ContainerComparator should use these
        %   comparators to compare contained data.
        ListPeers = matlab.unittest.constraints.ComparatorList;
        
        % ListIndex - Index at which this comparator had been in a ComparatorList.
        ListIndex = 1;
    end
    
    properties (Hidden, Constant, Access=protected)
        % DefaultTolerance - The tolerance that will be used by default
        %   when the 'Within' parameter is not specified by the user.
        DefaultTolerance = [];
    end
    
    methods (Access=protected)
        function comparator = ContainerComparator(varargin)
            % ContainerComparator - Class Constructor
            
            import matlab.unittest.constraints.ComparatorList;
            
            comparator.addOptional('Comparator', ComparatorList(), @validateCompList);
            comparator = comparator.parse(varargin{:});
            
            comp = comparator.ParsingResults.Comparator;
            if isa(comp, 'matlab.unittest.constraints.ComparatorList')
                comparator.CompList = comp;
            else
                comparator.CompList = comparator.CompList.addComparator(comp);
            end
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function comp = getComparatorFor(comparator, val)
            % getComparatorFor - Returns a comparator for a value contained in the data structure
            %   Subclasses of ContainerComparator should call this method when
            %   iterating over a data structure to retrieve the correct comparator for
            %   comparing the contained data type.
            
            if ~comparator.Recursive
                % Non-recursive ContainerComparators always dispatch in
                % recursion to the comparator provided to the constructor.
                comp = comparator.CompList;
                comp = comparator.applyMixinPropertiesToComparator(comp);
                return;
            end
            
            if comparator.CompList.supports(val)
                % A comparator provided to the constructor of a recursive
                % container comparator has precedence over the comparator
                % itself and the ListPeers.
                comp = comparator.CompList;
                comp = comparator.applyMixinPropertiesToComparator(comp);
                return;
            end
            
            if comparator.ListPeers.supports(val)
                % Reconstruct the original ComparatorList with the
                % ContainerComparator in the right order. Note that the
                % ComparatorList should already have any mixin properties
                % set, so they need not be set again.
                comp = comparator.ListPeers;
                comparator.ListPeers = comparator.ListPeers.clearComparators();
                comp = comp.insertAt(comparator.ListIndex, comparator);
                return;
            end
            
            if comparator.supports(val)
                % The recursive ContainerComparator supports the data type.
                % Reuse it again as-is for the recursion.
                comp = comparator;
                return;
            end
            
            % The container comparator cannot support the contained data
            % type at all. Return the CompList which will later throw an
            % "Unsupported Type" exception). There is no need to apply
            % mixin properties.
            comp = comparator.CompList;
        end
        
        function comparator = appendComparator(comparator, comp)
            % appendComparator - Adds a comparator to the end of the internal comparator list.
            
            comparator.CompList = comparator.CompList.appendComparator(comp);
        end
        
        function comparator = appendListContents(comparator, list)
            % appendListContents - Adds the contents of a comparator list to the end of the internal comparator list.
            
            comparator.CompList = comparator.CompList.appendListContents(list);
        end
    end
    
    methods (Access=private)
        function comp = applyMixinPropertiesToComparator(comparator, comp)
            % Set any mixin properties on the supplied comparator.
            
            if comparator.wasExplicitlySpecified('Within')
                comp = comp.within(comparator.Tolerance);
            end
            
            if comparator.IgnoreCase
                comp = comp.ignoringCase();
            end
            
            if comparator.IgnoreWhitespace
                comp = comp.ignoringWhitespace();
            end
        end
    end
end

function validateCompList(list)
validateattributes(list, ...
    {'matlab.unittest.constraints.Comparator'}, ...
    {'scalar'}, '', 'Comparator')
end