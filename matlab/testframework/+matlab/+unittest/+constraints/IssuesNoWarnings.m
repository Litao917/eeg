classdef IssuesNoWarnings < matlab.unittest.internal.constraints.WarningQualificationConstraint
    % IssuesNoWarnings - Constraint specifying a function that issues no warnings
    %   The IssuesNoWarnings constraint produces a qualification failure for
    %   any value that is not a function handle or is a function handle that
    %   issues at least one warning.
    %
    %   The FunctionOutputs property provides access to the output arguments
    %   produced when invoking the function handle. The Nargout property
    %   specifies the number of output arguments to be returned.
    %
    %
    %   IssuesNoWarnings methods:
    %       IssuesNoWarnings - Class constructor
    %
    %   IssuesNoWarnings properties:
    %       FunctionOutputs - cell array of outputs produced when invoking the
    %           supplied function handle
    %       Nargout - specifies the number of outputs this instance should supply
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IssuesNoWarnings;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % Simple case
    %       testCase.verifyThat(@true, IssuesNoWarnings);
    %       testCase.verifyThat(@() size([]), IssuesNoWarnings('WhenNargoutIs', 2));
    %
    %       % Access the outputs returned by the function handle
    %       issuesNoWarningsConstraint = IssuesNoWarnings('WhenNargoutIs', 2);
    %       testCase.verifyThat(@() size([]), issuesNoWarningsConstraint);
    %       [actualOut1, actualOut2] = issuesNoWarningsConstraint.FunctionOutputs{:};
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.verifyThat(5, IssuesNoWarnings);
    %
    %       % Issues a warning
    %       testCase.verifyThat(@() warning('some:id', 'Message'), IssuesNoWarnings);
    %
    %   See also
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.IssuesWarnings
    %       matlab.unittest.constraints.Throws
    %       warning
    
    
    %  Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function constraint = IssuesNoWarnings(varargin)
            % IssuesNoWarnings - Class constructor
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesNoWarnings creates a
            %   constraint that is able to determine whether an actual value is a
            %   function handle that issues no MATLAB warnings when invoked, and
            %   produces an appropriate qualification failure if warnings are issued
            %   upon function invocation.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesNoWarnings('WhenNargoutIs',NUMOUTPUTS)
            %   creates a constraint that is able to determine whether an actual value
            %   is a function handle that issues no MATLAB warnings when invoked with
            %   NUMOUTPUTS number of output arguments.
            %
            %   See also:
            %       Nargout
            
            constraint = constraint.parse(varargin{:});
            
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.issuesNoWarnings(actual);
            
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.getDiagnosticFor@matlab.unittest.internal.constraints.FunctionHandleConstraint(actual);
                return
            end
            
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never issued any warnings
            if constraint.HasIssuedSomeWarnings
                diag = constraint.createWarningsIssuedDiagnostic;
                return
            end
            
            
            % If we've made it this far and we have no conditions then we have passed
            diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                DiagnosticSense.Positive);
            
        end

    end
    
    methods(Hidden,Access=protected)
        function processWarnings(constraint)
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            
            % Broadcast which warnings were accounted for via this constraint. Warnings
            % not accounted for may be picked up by external tooling. However, all
            % warnings thrown here are caught through a failure of this
            % tool and thus are accounted for.
            ExpectedWarningsNotifier.notifyExpectedWarnings(constraint.ActualWarningsIssued);
        end
    end
    
    methods(Access=private)
        function tf = issuesNoWarnings(constraint, actual)
            constraint.invoke(actual);
            
            tf = ~constraint.HasIssuedSomeWarnings;
            
        end
        
        
        function diag = createWarningsIssuedDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                constraint, DiagnosticSense.Positive, ...
                constraint.convertToDisplayableList(constraint.ActualWarnings));
            subDiag.Description = getString(message('MATLAB:unittest:IssuesNoWarnings:WarningsWereIssued')); 
            subDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesNoWarnings:WarningsIssuedHeader'));
            
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
    end
    
end