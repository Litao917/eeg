classdef RelativeTolerance < matlab.unittest.internal.constraints.ElementwiseTolerance
    %RelativeTolerance   Relative numeric tolerance
    %
    %   This numeric tolerance assesses the magnitude of the difference
    %   between actual and expected values, relative to the expected value.
    %
    %   Requirement: | expVal - actVal | <= relTol .* | expVal |
    %
    %   The data types of the inputs to the RelativeTolerance constructor
    %   determine the data types to which the tolerance is applied. For
    %   example, RelativeTolerance(10*eps) constructs a RelativeTolerance
    %   for comparing double-precision numeric arrays while
    %   RelativeTolerance(int8(2)) constructs a RelativeTolerance for
    %   comparing numeric arrays of type int8. If the actual and expected
    %   values being compared contain more than one numeric data type, the
    %   tolerance only applies to the data types specified by the values
    %   passed into the constructor.
    %
    %   Different tolerance values can be specified for different data
    %   types by passing multiple tolerance values to the constructor. For
    %   example, RelativeTolerance(10*eps, 10*eps('single'), int8(0))
    %   constructs a RelativeTolerance that would apply the following
    %   relative tolerances:
    %       * 10*eps for double-precision numeric arrays
    %       * 10*eps('single') for single-precision numeric arrays
    %       * int8(0) for numeric arrays of type int8.
    %
    %   More than one tolerance can be specified for a particular data type
    %   by combining tolerances with the & and | operators. In order to
    %   combine two tolerances, the sizes of the tolerance values for each
    %   data type must be compatible.
    %
    %   RelativeTolerance properties:
    %      Values - Cell array containing scalar or vector numerical tolerances.
    %
    %   RelativeTolerance methods:
    %       RelativeTolerance - Class constructor.
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.constraints.RelativeTolerance;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Simple use in IsEqualTo constraint
    %       testCase.assertThat(4.1, IsEqualTo(4.5, ...
    %           'Within', RelativeTolerance(0.1)));
    %
    %       % Specify different tolerances for different data types
    %       act = {'abc', 123, single(123), int8([1, 2, 3])};
    %       exp = {'abc', 122, single(120), int8([2, 4, 6])};
    %       testCase.verifyThat(act, IsEqualTo(exp, 'Within', ...
    %           AbsoluteTolerance(single(3), int8([2, 3, 5])) | ...
    %           RelativeTolerance(2, single(1))));
    %
    %   See also
    %      matlab.unittest.constraints.AbsoluteTolerance
    %      matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Values - Tolerance values
        %   Values is a cell array of numeric arrays. Each element in the
        %   cell array contains the tolerance specification for a
        %   particular data type. Each numeric array may be a scalar or
        %   array of size equal to the actual and expected values.
        Values;
    end
    
    methods (Hidden, Access=protected)
        function comp = compareValues(tolerance, actVal, expVal)
            % compareValues - Element-wise comparison of the actual and expected values.
            %   Assumes actual and expected validation has already been performed.
            
            import matlab.unittest.internal.constraints.eliminateCommonInfsAndNans;
            
            if ~tolerance.supports(expVal)
                comp = false(size(expVal));
            else
                [actVal, expVal] = eliminateCommonInfsAndNans(actVal, expVal);
                tolVal = tolerance.getToleranceValueFor(expVal);
                comp = (abs(expVal - actVal) <= tolVal .* abs(expVal));
            end
        end
    end
    
    methods
        function tolerance = RelativeTolerance(varargin)
            %RelativeTolerance   Class constructor.
            %
            %   Each input argument can be a scalar or array of tolerance
            %   values. Each value must be floating point data type.
            
            % Validate the tolerance values and assign type and size information.
            tolerance = tolerance.validateToleranceValues(varargin);
            
            % Further validate that each tolerance value is a floating point data type
            cellfun(@(val)validateToleranceValue(val), varargin);
            function validateToleranceValue(val)
                if ~isfloat(val)
                    error(message('MATLAB:unittest:Tolerance:ToleranceMustBeFloat'));
                end
            end
            
            tolerance.Values = varargin;
        end
        
        function diag = getDiagnosticFor(tolerance, actVal, expVal)
            % getDiagnosticFor - Returns a diagnostic object containing
            %   information about the result of a comparison.
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            if ~tolerance.supports(expVal)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:ToleranceNotUsed', class(expVal)));
            else
                failed = ~tolerance.compareValues(actVal, expVal);
                tolDiag = ConstraintDiagnostic;
                tolDiag.DisplayDescription = true;
                tolDiag.Description = getString(message('MATLAB:unittest:Tolerance:RelativeToleranceFailed'));
                tolDiag.ActValHeader = getString(message('MATLAB:unittest:Tolerance:ToleranceValue'));
                tolDiag.DisplayActVal = true;
                tolDiag.ActVal = tolerance.getToleranceValueFor(expVal); 
                tolDiag.DisplayExpVal = false;
                diag = tolerance.produceDiagnostic(failed, actVal, expVal, tolDiag);
            end
        end
    end
end

% LocalWords:  abc
