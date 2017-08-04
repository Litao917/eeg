classdef RecursiveConstraintDiagnostic < matlab.unittest.diagnostics.ConstraintDiagnostic
% RecursiveConstraintDiagnostic - A constraint diagnostic specific to recursive comparisons
%
%   The RecursiveConstraintDiagnostic is a ConstraintDiagnostic with an 
%   additional field for storing and displaying the recursive path resulting in 
%   an unsatisfied constraint, and is displayed after the description field. This
%   recursive path is also referred to in MATLAB as a subsref path.
%
%   RecursiveConstraintDiagnostic objects should not be constructed directly.
%   Rather, the ConstraintDiagnosticFactory methods should be used to instantiate
%   objects of this type.
%
%   Comparators are required to return RecursiveConstraintDiagnostic objects from
%   their getDiagnosticFor methods. This is because Comparators are the primary 
%   tool used for recursive comparisons by ComparisonConstraints.
%
%   RecursiveConstraintDiagnostic properties:
%       DisplayRecursivePath - boolean controlling display of the recursive path field
%       RecursivePathHeader  - string containing header information for the recursive path field
%       RecursivePath        - string describing the data structure path to an inequality
%       RecursiveDepth       - the number of levels of recursion
%
%   RecursiveConstraintDiagnostic methods:
%       getPostDescriptionString   - overridden method for displaying RecursivePath field in DiagnosticResult
%       getPreRecursivePathString  - overridable method for adding fields prior to RecursivePath field
%       getPostRecursivePathString - overridable method for adding fields subsequent to RecursivePath field
%       pushOnRecursivePath        - pushes path elements onto the recursive path
%   
%   See also
%       ConstraintDiagnostic
%       ConstraintDiagnosticFactory
%       matlab.unittest.constraints.Comparator

%  Copyright 2010-2012 The MathWorks, Inc.

    properties (Access=private)
        PathArray = cell(1, 0);
    end

    properties (Dependent, SetAccess=private)
        % RecursivePath - string describing the data structure path to an inequality
        %
        %   When displayed, each element in the recursive path is separated by a period.
        %   The recursive path should terminate at a leaf in the data structure.
        %
        %   See also:
        %       pushOnRecursivePath
        RecursivePath;
        
        % RecursiveDepth - the number of levels of recursion
        RecursiveDepth;
    end

    properties
        % DisplayRecursivePath - boolean controlling display of the recursive path field
        %
        %   By default, the recursive path is not displayed and the value of this property
        %   is false.
        DisplayRecursivePath = false;
        
        % RecursivePathHeader - string containing header information for the recursive path field
        %
        %   Contains the following default header:
        %   'Subsref Path:'
        RecursivePathHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:RecursivePathHeader'));
    end

    methods (Sealed, Access = protected)
        function s = getPostDescriptionString(diag)
        % getPostDescriptionString - overridden method for displaying RecursivePath field in DiagnosticResult
        %
        %   This method is overridden from the ConstraintDiagnostic base class and is
        %   used to display the RecursivePath field. In addition, the overridable methods
        %   getPreRecursivePathString and getPostRecursivePathString are called to
        %   display any fields added by subclasses.

            s = '';
            str = diag.getPreRecursivePathString();
            if (~isempty(str))
                s = sprintf('%s%s\n', ...
                            s, ...
                            diag.trimNewlines(str));
            end


            if (diag.RecursiveDepth > 0 && ...
                diag.DisplayRecursivePath)
                    s = sprintf('%s%s %s\n', ...
                                s, ...
                                diag.RecursivePathHeader, ...
                                diag.RecursivePath);
            end

            str = diag.getPostRecursivePathString();
            s = sprintf('%s%s', ...
                        s, ...
                        str);

            s = diag.trimNewlines(s);
        end
    end

    methods (Hidden)
        function diag = RecursiveConstraintDiagnostic()
        % Hidden constructor. Generally, ConstraintDiagnosticFactory should be used to
        % construct RecursiveConstraintDiagnostic objects.
        end
    end

    methods (Access = protected)
        function str = getPreRecursivePathString(~)
        % getPreRecursivePathString - returns text to be displayed prior to the RecursivePath field
        %
        %   This overridable method can be used to inject fields prior to the
        %   RecursivePath field.
            str = '';
        end
        
        function str = getPostRecursivePathString(~)
        % getPostRecursivePathString - returns text to be displayed after the RecursivePath field
        %
        %   This overridable method can be used to inject fields subsequent to the
        %   RecursivePath field.
            str = '';
        end
    end

    methods
        function pushOnRecursivePath(diag, field)
        % pushOnRecursivePath - pushes path elements onto the recursive path
        %
        %   This method adds elements to the start of the recursive path. This can be
        %   used to build a string describing the path in a data structure by pushing the
        %   current field onto the recursive path at each level of recursion.

            validateattributes(field, ...
                               {'char'}, ...
                               {}, ...
                               '', ...
                               'field');
            diag.PathArray = [strtrim(field), ...
                             diag.PathArray];
        end

        function depth = get.RecursiveDepth(diag)
            depth = numel(diag.PathArray);
        end

        function path = get.RecursivePath(diag)
            path = sprintf('%s', ...
                           diag.PathArray{:});
            path = regexprep(path, ...
                             '\.$', ...
                             '');
        end
        function set.RecursivePathHeader(diag, header)
            diag.RecursivePathHeader = diag.trimNewlines(header);
        end

    end
end

% LocalWords:  overridable
