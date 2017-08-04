classdef HasField < matlab.unittest.constraints.BooleanConstraint
    % HasField - Constraint specifying a structure containing the mentioned field
    %
    %    The HasField constraint produces a qualification failure for any actual argument that is a structure
    %    that does not contain the specified field or is not a structure.
    %
    %    HasField methods:
    %       HasField - Class constructor
    %
    %    Examples:
    %
    %       import matlab.unittest.constraints.HasField;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %       % Passing Scenarios
    %       %%%%%%%%%%%%%
    %       S1 = struct('one',[]);
    %       testCase.verifyThat(S1, HasField('one'));
    %       testCase.assumeThat(struct('Tag', 123, 'Serial', 345), HasField('Tag'));
    %
    %
    %       % Failing Scenarios
    %       %%%%%%%%%%%%%
    %       S1 = struct('one',[]);
    %       testCase.verifyThat(S1, HasField('One'));
    %       testCase.assumeThat(struct('Tag', 123, 'Serial', 345), HasField('Name'));
    %       testCase.assertThat([2 3], HasField('Name'))
    
    %  Copyright 2012 The MathWorks, Inc.
    
    
    properties (SetAccess=private)
        % Field - field that a structure must have to satisfy the constraint
        Field
    end
    
    methods
        
        function constraint = HasField(fieldname)
            % HasField Constructor
            %
            % HasField(FIELDNAME) creates a constraint that is able to determine
            % if the specified FIELDNAME is a field of the structure actual value
            %
            
            constraint.Field = fieldname;
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            tf = isfield(actual, constraint.Field);  % if Field is a cell array
        end
        
        % diagnostic
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                % Use a sub diagnostic to report if the actual value was a
                % structure or did not contain the expected field.
                if (isstruct(actual))
                    
                    if (~all(size(fieldnames(actual)) > 0))
                        actVal = getString(message('MATLAB:unittest:HasField:NoField'));
                    else
                        actVal = fieldnames(actual);
                    end
                    
                    fieldDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, actVal, mat2cell(constraint.Field,1,numel(constraint.Field)));
                    fieldDiag.Description = getString(message('MATLAB:unittest:HasField:MustHaveExpectedField'));
                    fieldDiag.ActValHeader = getString(message('MATLAB:unittest:HasField:ActualField'));
                    fieldDiag.ExpValHeader = getString(message('MATLAB:unittest:HasField:ExpectedField'));
                    diag.addCondition(fieldDiag);
                else
                    diag.addCondition(message('MATLAB:unittest:HasField:NotAStruct',class(actual)));
                end
            end
        end
        
        
        function constraint = set.Field(constraint,fieldname)
            validateattributes(fieldname,{'char'},{'row','nonempty'})    % row -> mxn char arrays
            constraint.Field = fieldname;
        end
    end
    
    methods (Access = protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative,actual, mat2cell(constraint.Field,1,numel(constraint.Field)));
                diag.addCondition(getString(message('MATLAB:unittest:HasField:MustNotHaveField')));
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasField:UnexpectedField'));
                
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative);
            end
        end
    end
end
