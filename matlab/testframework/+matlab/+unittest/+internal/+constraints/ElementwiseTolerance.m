classdef ElementwiseTolerance < matlab.unittest.constraints.Tolerance
    %ElementwiseTolerance   Abstract base class for element-wise tolerance types
    %   This is a numeric tolerance for comparing arrays on an element-wise
    %   basis. Subclasses of ElementwiseTolerance implement a compareValues
    %   method that performs an element-wise comparison of the actual and
    %   expected values and returns a boolean array.
    %
    % ElementwiseTolerance methods:
    %   compareValues - Element-wise comparison of the actual and expected values
    %   and - the logical element-wise conjunction of a tolerance
    %   or - the logical element-wise disjunction of a tolerance
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    properties (Hidden, Access = protected)
        % Types - A cell array of strings containing class names
        %   Types specifies the datatype of each tolerance value.
        Types;
        
        % Sizes - A cell array of numeric scalars
        %   Sizes specifies the size of each tolerance value.
        Sizes;
    end
    
    methods
        function bool = supports(tolerance, value)
            % supports - Returns a boolean indicating whether the tolerance supports the specified value.
            
            bool = tolerance.hasType(class(value));
        end
        
        function tf = satisfiedBy(tolerance, actVal, expVal)
            %satisfiedBy   Method for determining tolerance satisfaction.
            %
            %   This method returns a logical value indicating whether the tolerance has 
            %   been satisfied by the provided actual and expected values.
            %
            %   Element-wise tolerances require that actual and expected values be scalars or
            %   arrays of the same size and type. The tolerance values must also be a
            %   scalar or array of the same size and type as the actual and expected values.
            
            tolerance.validateActualExpectedValues(actVal, expVal);
            comp = tolerance.compareValues(actVal, expVal);
            tf = full(all(comp(:)));            
        end
    end
    
    methods (Hidden, Access = protected)
        function validateActualExpectedValues(tolerance, actVal, expVal)
            %validateActualExpectedValues   Utility method for validation of actual and expected values.
            %
            %   Any comparator which delegates comparison to an
            %   ElementwiseTolerance should first perform checks to make sure that
            %   the size, class, and sparsity of the actual and expected values are
            %   equivalent. This method performs a sanity check and errors if these
            %   conditions are not satisfied.
            
            % In the future, we might loosen the requirement that the actual and
            % expected value have the same size, class, and sparsity if use cases
            % are discovered where these checks do not make sense (for example, a
            % custom MATLAB object could define its own notion of size such that
            % the size check below could fail yet the two instances are still
            % considered equal).
            
            if ~isa(expVal, 'numeric') && ~isobject(expVal)
                error(message('MATLAB:unittest:Tolerance:InvalidExpectedValueType'));
            end
            
            if ~isequal(size(expVal), size(actVal))
                error(message('MATLAB:unittest:Tolerance:ActExpSizeMismatch'));
            end
            if ~strcmp(class(actVal), class(expVal))
                error(message('MATLAB:unittest:Tolerance:ActExpClassMismatch'));
            end
            if issparse(expVal) ~= issparse(actVal)
                error(message('MATLAB:unittest:Tolerance:ActExpSparsityMismatch'));
            end
            
            % Also validate the expected value size
            if tolerance.supports(expVal)
                tolSize = tolerance.getSizeFromType(class(expVal));
                if ~isequal(tolSize, [1, 1]) && ~isequal(tolSize, size(expVal))
                    error(message('MATLAB:unittest:Tolerance:TolAndExpValSizeMismatch'));
                end
            end
        end
        
        function tolerance = validateToleranceValues(tolerance, values)
            % validateToleranceValues - Validate a cell array of tolerance values.
            %   Validate the supplied tolerance values and assign type and
            %   size information.
            
            validateattributes(values, {'cell'}, {'vector', 'nonempty'}, '', 'values');
            
            cellfun(@(val)validateToleranceValue(val), values);
            function validateToleranceValue(val)
                if ~isa(val, 'numeric') && ~isobject(val)
                    error(message('MATLAB:unittest:Tolerance:InvalidToleranceType'));
                end
                if isempty(val) || ~isreal(val) || any(val(:) < 0) || ~all(isfinite(val(:)))
                    error(message('MATLAB:unittest:Tolerance:InvalidToleranceValue'));
                end
            end
            
            types = cellfun(@(tol)class(tol), values, 'UniformOutput',false);
            if numel(types) ~= numel(unique(types))
                error(message('MATLAB:unittest:Tolerance:DuplicateType'));
            end
            
            sizes = cellfun(@size, values, 'UniformOutput',false);
            
            tolerance.Types = types;
            tolerance.Sizes = sizes;
        end
        
        function diag = produceDiagnostic(tolerance, failedMask, actVal, expVal, tolDiag)
            % produceDiagnostic - Utility method containing logic for producing an appropriate diagnostic.
            %
            %    The produceDiagnostic method contains boiler-plate code for producing a
            %    standard diagnostic for tolerances. It includes code for displaying
            %    failing indices and allows the specification of a failing condition
            %    string using the condMsg argument.
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if any(failedMask(:))
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                if ~isscalar(actVal)
                    % Tolerance has two parts to be displayed:
                    %   a. Tolerance value
                    %   b. Failing Indices, if any
                    %   The tolerance value is populated by the concrete
                    %   tolerance classes. This class populates the failed
                    %   indices as an expected value
                    failedIndices = find(failedMask);
                    tolDiag.ExpVal = failedIndices(:)';
                    tolDiag.ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:FailingIndices'));
                    tolDiag.DisplayExpVal = true;
                end
                diag.addCondition(tolDiag);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive);
            end
        end
        
        function [combinedTypes, combinedSizes] = combineTypesAndSizes(tol1, tol2)
            % combineTypesAndSizes - Combine type and size information from two ElementwiseTolerances.
            %   Validation is also performed to ensure that the two
            %   tolerances being combined are compatible. An error is
            %   thrown if the objects are not compatible.
            
            % Start with the types that are specified in only one of the
            % two tolerances. These need no further validation and can
            % simply be concatenated together.
            [combinedTypes, sizeInd1, sizeInd2] = setxor(tol1.Types, tol2.Types, 'stable');
            combinedSizes = {tol1.Sizes{sizeInd1}, tol2.Sizes{sizeInd2}};
            
            % Next consider the data types which are specified in both
            % tolerances. The types can be take as-is.
            commonTypes = intersect(tol1.Types, tol2.Types);
            combinedTypes = [combinedTypes, commonTypes];
            
            % Validate sizes for each data type which is specified in both
            % tolerances. Also allow scalar expansion (i.e., allow
            % scalar/array combinations). In the case of scalar expansion,
            % return the non-scalar size.
            for type = commonTypes
                size1 = tol1.getSizeFromType(type{1});
                size2 = tol2.getSizeFromType(type{1});
                if ~isequal(size1, [1, 1]) && ~isequal(size2, [1, 1]) && ~isequal(size1, size2);
                    error(message('MATLAB:unittest:Tolerance:SizeMismatch', type{1}));
                end
                combinedSizes = [combinedSizes, {max(size1, size2)}]; %#ok<AGROW>
            end
        end
        
        function bool = hasType(tolerance, type)
            % Returns a boolean indicating whether the ElementwiseTolerance
            % contains a tolerance for a particular data type.
            
            bool = nnz(strcmp(tolerance.Types, type)) == 1;
        end
        
        function sz = getSizeFromType(tolerance, type)
            % Return the tolerance size for a given data type.
            
            sz = tolerance.Sizes{strcmp(tolerance.Types, type)};
        end
        
        function tolVal = getToleranceValueFor(tolerance, expVal)
            % getToleranceValueFor - Return the tolerance value for a given expected value.
            %   It is assumed that this method will only be called from
            %   subclasses which have a Values property (e.g.,
            %   AbsoluteTolerance or RelativeTolerance).
            
            tolVal = tolerance.Values{strcmp(tolerance.Types, class(expVal))};
        end
    end
    
    methods (Abstract, Hidden, Access = protected)
        % compareValues - Element-wise comparison of the actual and expected values.
        %   Returns a boolean array indicating whether the actual and
        %   expected values satisfy the tolerance on an element-wise basis.
        %   This method should return a correctly-sized array of logical
        %   zeros if the expected value is not supported.
        comp = compareValues(tolerance, actVal, expVal);
    end
    
    methods (Sealed)
        function tolerance = and(tolerance1, tolerance2)
            % and - the logical element-wise conjunction of a tolerance
            %
            %   and(tolerance1, tolerance2) returns a tolerance which is
            %   the boolean conjunction of tolerance1 and tolerance2. This
            %   is a means to specify that every element of the actual
            %   value should be equal to the expected value to within the
            %   tolerance specified by both tolerance1 and tolerance2. A
            %   qualification failure should be produced when either
            %   tolerance1 or tolerance2 is not satisfied for one or more
            %   elements of the values being compared.
            %
            %   Typically, the AND method is not called directly, but the
            %   MATLAB "&" operator is used to denote the conjunction of
            %   any two ElementwiseTolerance objects.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Passing qualifications
            %       testCase.verifyThat(101, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.02)));
            %       testCase.assumeThat([101, 105], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance([2, 10]) & RelativeTolerance([0.02, 0.1])));
            %
            %       % Failing qualifications
            %       testCase.assertThat(101, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.02)));
            %       testCase.fatalAssertThat([101, 105], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.02)));
            
            import matlab.unittest.constraints.AndTolerance;
            
            tolerance = AndTolerance(tolerance1, tolerance2);
        end
        
        function tolerance = or(tolerance1, tolerance2)
            % or - the logical element-wise disjunction of a tolerance
            %
            %   or(tolerance1, tolerance2) returns a tolerance which is the
            %   boolean disjunction of tolerance1 and tolerance2. This is a
            %   means to specify that every element of the actual value
            %   should be equal to the expected value to within the
            %   tolerance specified by either tolerance1 or tolerance2. A
            %   qualification failure should be produced when both
            %   tolerance1 and tolerance2 are not satisfied for one or more
            %   elements of the values being compared.
            %
            %   Typically, the OR method is not called directly, but the
            %   MATLAB "|" operator is used to denote the disjunction of
            %   any two ElementwiseTolerance objects.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Simple passing qualification
            %       testCase.verifyThat(105, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(3) | RelativeTolerance(0.1)));
            %
            %       % The following qualification passes because the OR
            %       % operation is performed element-wise between the
            %       % actual and expected values being compared:
            %       testCase.assertThat([8, 104], IsEqualTo([10, 100], 'Within', ...
            %           AbsoluteTolerance(3) | RelativeTolerance(0.05)));
            %       % Note that the following would fail:
            %       testCase.assertThat([8, 104], ...
            %           IsEqualTo([10, 100], 'Within', AbsoluteTolerance(3)) | ...
            %           IsEqualTo([10, 100], 'Within', RelativeTolerance(0.05)));
            %
            %       % Failing qualifications
            %       testCase.fatalAssertThat(101, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(0.5) | RelativeTolerance(0)));
            %       testCase.assumeThat([101, 101], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance([2, 0.5]) | RelativeTolerance([0.02, 0.001])));
            
            import matlab.unittest.constraints.OrTolerance;
            
            tolerance = OrTolerance(tolerance1, tolerance2);
        end
    end
end

% LocalWords:  Elementwise
