classdef AbsoluteTolerance < matlab.unittest.internal.constraints.ElementwiseTolerance
    %AbsoluteTolerance   Absolute numeric tolerance
    %
    %   This numeric tolerance assesses the magnitude of the difference
    %   between actual and expected values.
    %
    %   Requirement: | expVal - actVal | <= absTol
    %
    %   The data types of the inputs to the AbsoluteTolerance constructor
    %   determine the data types to which the tolerance is applied. For
    %   example, AbsoluteTolerance(10*eps) constructs an AbsoluteTolerance
    %   for comparing double-precision numeric arrays while
    %   AbsoluteTolerance(int8(2)) constructs an AbsoluteTolerance for
    %   comparing numeric arrays of type int8. If the actual and expected
    %   values being compared contain more than one numeric data type, the
    %   tolerance only applies to the data types specified by the values
    %   passed into the constructor.
    %
    %   Different tolerance values can be specified for different data
    %   types by passing multiple tolerance values to the constructor. For
    %   example, AbsoluteTolerance(10*eps, 10*eps('single'), int8(1))
    %   constructs an AbsoluteTolerance that would apply the following
    %   absolute tolerances:
    %       * 10*eps for double-precision numeric arrays
    %       * 10*eps('single') for single-precision numeric arrays
    %       * int8(1) for numeric arrays of type int8.
    %
    %   More than one tolerance can be specified for a particular data type
    %   by combining tolerances with the & and | operators. In order to
    %   combine two tolerances, the sizes of the tolerance values for each
    %   data type must be compatible.
    %
    %   AbsoluteTolerance properties:
    %   	Values - Cell array containing scalar or vector numerical tolerances.
    %
    %   AbsoluteTolerance methods:
    %       AbsoluteTolerance - Class constructor.
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
    %           'Within', AbsoluteTolerance(0.5)));
    %
    %       % Specify different tolerances for different data types
    %       act = {'abc', 123, single(123), int8([1, 2, 3])};
    %       exp = {'abc', 122, single(120), int8([2, 4, 6])};
    %       testCase.verifyThat(act, IsEqualTo(exp, 'Within', ...
    %           AbsoluteTolerance(single(3), int8([2, 3, 5])) | ...
    %           RelativeTolerance(2, single(1))));
    %
    %   See also
    %      matlab.unittest.constraints.RelativeTolerance
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
                comp = abs(expVal - actVal) <= tolVal;
                
                % Perform subtraction in reverse order to work around
                % saturation when subtracting unsigned integers
                if ~isfloat(expVal)
                    comp = comp & (abs(actVal - expVal) <= tolVal);
                end
            end
        end
    end
    
    methods
        function tolerance = AbsoluteTolerance(varargin)
            %AbsoluteTolerance   Class constructor.
            %
            %   Each input argument can be a scalar or array of tolerance
            %   values.
            
            % Validate the tolerance values and assign type and size information.
            tolerance = tolerance.validateToleranceValues(varargin);
            
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
                tolDiag.Description = getString(message('MATLAB:unittest:Tolerance:AbsoluteToleranceFailed'));
                tolDiag.ActValHeader = getString(message('MATLAB:unittest:Tolerance:ToleranceValue'));
                tolDiag.ActVal = tolerance.getToleranceValueFor(expVal); 
                tolDiag.DisplayActVal = true;
                tolDiag.DisplayExpVal = false;
                diag = tolerance.produceDiagnostic(failed, actVal, expVal, tolDiag);
            end
        end
    end
end

% LocalWords:  abc
