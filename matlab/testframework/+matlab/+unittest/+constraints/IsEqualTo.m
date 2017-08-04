classdef IsEqualTo < matlab.unittest.constraints.BooleanConstraint & ...
                     matlab.unittest.internal.constraints.UsingMixin & ...
                     matlab.unittest.internal.constraints.WithinMixin & ...
                     matlab.unittest.internal.constraints.IgnoringCaseMixin & ...
                     matlab.unittest.internal.constraints.IgnoringWhitespaceMixin & ...
                     matlab.unittest.internal.constraints.ConciseDiagnosticMixin & ...
                     matlab.unittest.internal.constraints.ConciseNegativeDiagnosticMixin
    %IsEqualTo   General constraint used to compare various MATLAB types.
    %
    %   The IsEqualTo constraint compares the following object types for
    %   equality:
    %
    %      * MATLAB & Java Objects
    %      * Logical
    %      * Numerics
    %      * Strings
    %      * Structures
    %      * Cell arrays
    %
    %   The type of comparison used is governed by the type of the expected
    %   value. The first check performed is to check whether the expected value
    %   is an object. This check is performed first because in this case it is
    %   possible for the object to have overridden methods that are used in
    %   subsequent checks (e.g. islogical). The following list categorizes and
    %   describes the various tests in the order they are performed:
    %
    %   [MATLAB & Java Objects] If the expected value is a MATLAB or Java
    %   object, the IsEqualTo constraint calls the isequal method on the
    %   expected value object. If isequal returns false and a supported
    %   tolerance has been specified, the actual and expected values are
    %   checked for equivalent class, size, and sparsity. If these checks
    %   fail, the constraint is not satisfied. If these checks pass, the
    %   tolerance is used for comparison.
    %
    %   [Logicals] If the expected value is a logical, the actual and
    %   expected values are checked for equivalent sparsity. If the
    %   sparsity matches, the values are compared using the isequal method.
    %   Otherwise, the constraint is not satisfied.
    %
    %   [Numerics] If the expected value is numeric, the actual and
    %   expected values are checked for equivalent class, size, and
    %   sparsity. If the all these checks match, isequaln is used. If
    %   isequaln returns true, the constraint is satisfied. If the
    %   complexity does not match or isequaln returns false, and a
    %   supported tolerance has been supplied, it is used to perform the
    %   comparison. Otherwise, the constraint is not satisfied.
    %
    %   [Strings] If the expected value is a string, the strcmp function is
    %   used to check the actual and expected values for equality unless
    %   IgnoreCase is true, in which case the strings are compared using
    %   strcmpi. If IgnoreWhitespace is true, all whitespace characters are
    %   removed from the actual and expected strings before passing them to
    %   strcmp or strcmpi.
    %
    %   [Structures] If the expected value is a struct, the field count of
    %   the actual and expected values is compared. If not equal, the
    %   constraint is not satisfied. Otherwise, each field of the expected
    %   value struct must exist on the actual value struct. If any field
    %   names are different, the constraint is not satisfied. The fields
    %   are then recursively compared in a depth first examination. The
    %   recursion continues until a fundamental data type is encountered
    %   (i.e. logical, numeric, string, or object), and the values are
    %   compared as described above.
    %
    %   [Cell Arrays] If the expected value is a cell array, the actual and
    %   expected values are checked for size equality. If they are not
    %   equal in size, the constraint is not satisfied. Otherwise, each
    %   element of the array is recursively compared in a manner identical
    %   to fields in a structure, described above.
    %
    %
    %   IsEqualTo properties:
    %      Expected         - The expected value that will be compared to the actual value.
    %      Comparator       - The comparator object used to check equality.
    %      Tolerance        - Optional tolerance object for inexact numerical comparisons.
    %      IgnoreCase       - Optional boolean to compare strings ignoring case differences.
    %      IgnoreWhitespace - Optional boolean to compare strings ignoring whitespace differences.
    %
    %   IsEqualTo methods:
    %      IsEqualTo - Class constructor.
    %
    %   Examples:
    %      import matlab.unittest.constraints.IsEqualTo;
    %      import matlab.unittest.constraints.AbsoluteTolerance;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %      %%% Simple equality check %%%
    %      testCase.verifyThat(5, IsEqualTo(5));
    %
    %      %%% Comparison using tolerance %%%
    %      testCase.assertThat(5, IsEqualTo(4.95, 'Within', AbsoluteTolerance(0.1)));
    %
    %      %%% Comparison ignoring case %%%
    %      testCase.fatalAssertThat('aBc', IsEqualTo('ABC', 'IgnoringCase', true));
    %
    %      %%% Comparison ignoring whitespace %%%
    %      testCase.assumeThat('a bc', IsEqualTo('ab c', 'IgnoringWhitespace', true));
    %
    %
    %   See also:
    %      matlab.unittest.constraints.Constraint
    %      matlab.unittest.constraints.Tolerance
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Expected - The expected value that will be compared to the actual value.
        Expected;
    end
    
    properties (Hidden, Constant)
        % DefaultComparatorList - A ComparatorList containing a set of six
        %   comparators which supports all MATLAB data types.
        DefaultComparatorList = generateDefaultComparatorList();
    end
    
    properties (Hidden, Constant, Access = protected)
        % DefaultComparator - The comparator that will be used by default
        %   when the 'Using' parameter is not specified by the user.
        DefaultComparator = matlab.unittest.constraints.IsEqualTo.DefaultComparatorList;
        
        % DefaultTolerance - The tolerance that will be used by default
        %   when the 'Within' parameter is not specified by the user.
        DefaultTolerance = [];
    end

    methods
        function this = IsEqualTo(expectedValue, varargin)
            %IsEqualTo - Class constructor.
            %
            %  Examples:
            %     %%% Creates an IsEqualTo constraint object with an expected value equal
            %     %%% to expectedValue.
            %     IsEqualTo(expectedValue)
            %
            %     %%% Creates an IsEqualTo constraint object with an expected value equal 
            %     %%% to expectedValue and an absolute tolerance equal to tol.
            %     IsEqualTo(expectedValue, 'Within', AbsoluteTolerance(tol))
            %
            %     %%% Creates an IsEqualTo constraint object with an expected value equal 
            %     %%% to expectedValue without regard to case differences in strings
            %     IsEqualTo(expectedValue, 'IgnoringCase', true)
            %
            %     %%% Creates an IsEqualTo constraint object with an expected value equal 
            %     %%% to expectedValue without regard to whitespace differences in strings
            %     IsEqualTo(expectedValue, 'IgnoringWhitespace', true)
            
            this.Expected = expectedValue;
            this = this.parse(varargin{:});
        end
        
        function bool = satisfiedBy(constraint, actual)
            %satisfiedBy   Method that indicates satisfaction.
            %
            %   Returns a logical value indicating the equality of two entities. If a 
            %   tolerance has been specified, it is used to determine the equality of 
            %   numerical values.
            %
            %   See also
            %      matlab.unittest.constraints.IsEqualTo
            
            comp = constraint.prepareComparator(constraint.Comparator);
            bool = comp.supports(actual) && comp.satisfiedBy(actual, constraint.Expected);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comp = constraint.prepareComparator(constraint.Comparator);
            
            if comp.satisfiedBy(actual, constraint.Expected)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Expected);
                
                subDiag = comp.getDiagnosticFor(actual, constraint.Expected);
                
                if subDiag.RecursiveDepth > 0
                    subDiag.pushOnRecursivePath(getString(message('MATLAB:unittest:IsEqualTo:ExpectedValue')));
                    diag.ActValHeader = getString(message('MATLAB:unittest:IsEqualTo:ActualHeader',class(actual)));
                    diag.ExpValHeader = getString(message('MATLAB:unittest:IsEqualTo:ExpectedHeader',class(constraint.Expected)));
                elseif strcmp(diag.getDisplayableString(diag.ActVal), subDiag.getDisplayableString(subDiag.ActVal)) && ...
                        strcmp(diag.getDisplayableString(diag.ExpVal), subDiag.getDisplayableString(subDiag.ExpVal))
                    
                    % Don't display the Actual and Expected values
                    % twice, but do use the Headers returned from the
                    % comparator.
                    subDiag.DisplayActVal = false;
                    subDiag.DisplayExpVal = false;
                    diag.ActValHeader = subDiag.ActValHeader;
                    diag.ExpValHeader = subDiag.ExpValHeader;                    
                end                
                diag.addCondition(subDiag);
            end
        end                
    end
    
    methods (Hidden)
        function diag = getConciseDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comp = constraint.prepareComparator(constraint.Comparator);
            
            if comp.satisfiedBy(actual, constraint.Expected)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Expected);
                
                subDiag = comp.getDiagnosticFor(actual, constraint.Expected);
                
                if subDiag.RecursiveDepth > 0
                    subDiag.pushOnRecursivePath(getString(message('MATLAB:unittest:IsEqualTo:ExpectedValue')));
                    diag.ActValHeader = getString(message('MATLAB:unittest:IsEqualTo:ActualHeader',class(actual)));
                    diag.ExpValHeader = getString(message('MATLAB:unittest:IsEqualTo:ExpectedHeader',class(constraint.Expected)));
                    diag_ = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, subDiag.ActVal, subDiag.ExpVal);
                    diag_.Description = [subDiag.RecursivePathHeader subDiag.RecursivePath];
                    diag_.ActValHeader = subDiag.ActValHeader;
                    diag_.ExpValHeader = subDiag.ExpValHeader;
                    diag_ = generateConciseDiagnostic(diag_, subDiag);
                    diag.addCondition(diag_);
                    return;
                elseif strcmp(diag.getDisplayableString(diag.ActVal), subDiag.getDisplayableString(subDiag.ActVal)) && ...
                        strcmp(diag.getDisplayableString(diag.ExpVal), subDiag.getDisplayableString(subDiag.ExpVal))
                    
                    % Don't display the Actual and Expected values
                    % twice, but do use the Headers returned from the
                    % comparator.
                    subDiag.DisplayActVal = false;
                    subDiag.DisplayExpVal = false;
                    diag.ActValHeader = subDiag.ActValHeader;
                    diag.ExpValHeader = subDiag.ExpValHeader;
                end
                diag = generateConciseDiagnostic(diag, subDiag);
            end
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comp = constraint.prepareComparator(constraint.Comparator);
            
            if comp.satisfiedBy(actual, constraint.Expected)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Expected);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsEqualTo:ValueNotExpected'));
                
                subDiag = comp.getDiagnosticFor(actual, constraint.Expected);
                diag.addCondition(subDiag);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
    
    methods (Access = protected, Hidden)
        function diag = getConciseNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comp = constraint.prepareComparator(constraint.Comparator);
            
            if comp.satisfiedBy(actual, constraint.Expected)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Expected);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsEqualTo:ValueNotExpected'));
                
                subDiag = comp.getDiagnosticFor(actual, constraint.Expected);
                diag.addConditionsFrom(subDiag);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end        
        
    end
    
    methods (Access = private)
        function comp = prepareComparator(constraint, comp)
            % Set any mixin properties on the supplied comparator and
            % validate that it supports the expected value.
            
            if constraint.wasExplicitlySpecified('Within') && isa(comp, 'matlab.unittest.internal.constraints.WithinMixin')
                comp = comp.within(constraint.Tolerance);
            end            
           
            if constraint.IgnoreCase && isa(comp, 'matlab.unittest.internal.constraints.IgnoringCaseMixin')
                comp = comp.ignoringCase();
            end
            
            if constraint.IgnoreWhitespace && isa(comp, 'matlab.unittest.internal.constraints.IgnoringWhitespaceMixin')
                comp = comp.ignoringWhitespace();
            end
            
            % Confirm that a user-specified comparator supports the
            % expected value (assume that the default comparator supports
            % any expected value making this check unnecessary when using
            % the default comparator).
            if constraint.wasExplicitlySpecified('Using') && ~comp.supports(constraint.Expected)
                if isa(comp, 'matlab.unittest.constraints.ComparatorList')
                    % This provides a more detailed error including a list
                    % of all comparators contained in the list.
                    comp.throwUnsupportedType(constraint.Expected);
                else
                    error(message('MATLAB:unittest:IsEqualTo:UnsupportedType'));
                end
            end
        end
    end
end

function list = generateDefaultComparatorList()
import matlab.unittest.constraints.ComparatorList;
import matlab.unittest.constraints.LogicalComparator;
import matlab.unittest.constraints.NumericComparator;
import matlab.unittest.constraints.StringComparator;
import matlab.unittest.constraints.StructComparator;
import matlab.unittest.constraints.CellComparator;
import matlab.unittest.constraints.ObjectComparator;

list = ComparatorList();
list = list.addComparator(CellComparator('Recursively',true));
list = list.addComparator(StructComparator('Recursively',true));
list = list.addComparator(LogicalComparator());
list = list.addComparator(StringComparator());
list = list.addComparator(NumericComparator());
list = list.addComparator(ObjectComparator());
end

function diag = generateConciseDiagnostic(diag, subDiag)
% Generate a concise diagnostic from a sub-diagnostic.
for i = 1:subDiag.ConditionsCount
    cond = subDiag.getConditionAt(i);
    if ischar(cond) || metaclass(cond) <= ?message
        diag.addCondition(cond);
    else
        diag.addConditionsFrom(cond);
    end
end
end

% LocalWords:  isequaln Bc bc