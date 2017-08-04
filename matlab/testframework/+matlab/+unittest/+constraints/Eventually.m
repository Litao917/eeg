classdef Eventually < matlab.unittest.internal.constraints.FunctionHandleConstraint
    % Eventually - Poll for a value to asynchronously satisfy a constraint
    %
    %   The Eventually constraint produces a qualification failure for any
    %   value that is not a function handle or is a function handle that never
    %   returns a value that satisfies a provided constraint within a given
    %   timeout period. A constraint is required, and the timeout value is
    %   optional, with a default timeout value of 20 seconds. The drawnow
    %   function is invoked while the Eventually constraint waits for the
    %   constraint provided to be satisfied.
    %
    %
    %   Eventually methods:
    %       Eventually - Class constructor
    %
    %   Eventually properties:
    %       Timeout - specifies the maximum time to wait for passing behavior
    %
    %   Examples:
    %       import matlab.unittest.constraints.Eventually;
    %       import matlab.unittest.constraints.IsGreaterThan;
    %       import matlab.unittest.constraints.IsLessThan;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Simple passing example
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(10)));
    %
    %       % Simple failing example
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsLessThan(0)));
    %
    %       % Passing example with timeout
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(50), ...
    %           'WithTimeoutOf', 75), 'test diagnostic');
    %
    %       % Failing example with timeout
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(50), ...
    %           'WithTimeoutOf', 25));
    
    % Copyright 2011-2013 The MathWorks, Inc.
    
    
    properties(SetAccess=immutable)
        % Timeout - specifies the maximum time to wait for passing behavior
        %   The Timeout property, specified through the 'WithTimeoutOf' constructor
        %   parameter, determines the amount of time to wait (in seconds) before
        %   producing a qualification failure if the constraint polled for is
        %   never satisfied by the actual value provided. It has a default value
        %   of 20 seconds.
        Timeout
    end
    
    properties(GetAccess=private,SetAccess=immutable)
        InnerConstraint
    end
    
    properties(Access=private)
        Result
        Passed
    end
    
    methods
        
        function constraint = Eventually(anotherConstraint, varargin)
            % Eventually - Class constructor
            %
            %   CONSTRAINT = matlab.unittest.constraints.Eventually(ANOTHERCONSTRAINT)
            %   creates a constraint that is able to poll for an actual value function
            %   handle to satisfy the constraint specified in ANOTHERCONSTRAINT. It
            %   will produce an appropriate qualification failure if evaluation of the
            %   function handle does not produce a value that satisfies the constraint
            %   within 20 seconds.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesNoWarnings(ANOTHERCONSTRAINT, ...
            %       'WithTimeoutOf', TIMEOUT) 
            %   creates a constraint that is able to determine whether an actual value
            %   is a function handle that returns a value that satisfies the constraint
            %   specified in ANOTHERCONSTRAINT within a time period specified (in
            %   seconds) via TIMEOUT.
            %
            %   See also:
            %       Timeout
            validateattributes(anotherConstraint,{'matlab.unittest.constraints.Constraint'},...
                {'scalar'},'','anotherConstraint');
            constraint.InnerConstraint = anotherConstraint;
            
            p = inputParser;
            p.PartialMatching = false;
            p.addParameter('WithTimeoutOf',20, ...
                @(t) validateattributes(t, {'numeric'},{'scalar','nonnegative'}, '', 'timeout'));
            p.parse(varargin{:});
            
            constraint.Timeout = p.Results.WithTimeoutOf;
            
        end
        
        function tf = satisfiedBy(constraint, actual)
            
            tf = constraint.isFunction(actual) && ...
                constraint.eventuallySatisfiesInnerConstraint(actual);
            
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if ~constraint.isFunction(actual)
                diag = getDiagnosticFor@matlab.unittest.internal.constraints.FunctionHandleConstraint(...
                    constraint, actual);
                return
            end
            
            if constraint.shouldInvoke(actual)
                constraint.Result = constraint.invoke(actual);
                constraint.Passed = constraint.InnerConstraint.satisfiedBy(constraint.Result);
            end
            
            if constraint.Passed
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            else
                subDiag = constraint.InnerConstraint.getDiagnosticFor(constraint.Result);
                diag = constraint.generateFcnDiagnostic(message('MATLAB:unittest:Eventually:Timeout', ...
                    num2str(constraint.Timeout)));
                diag.addCondition(subDiag);
            end
        end
    end
    
    methods(Access=private)
        function tf = eventuallySatisfiesInnerConstraint(constraint, fcn)
            counter = 0;
            start = tic;
            
            % Evaluate first one time outside of the loop for performance in quickly
            % passing cases (no drawnow invoked if it passes right away).
            constraint.Result = constraint.invoke(fcn);
            constraint.Passed = constraint.InnerConstraint.satisfiedBy(constraint.Result);
            while ~constraint.Passed && (toc(start) <= constraint.Timeout)
                counter = counter + 1;
                drawnow;
                if counter > 10
                    pause(1);
                end
                constraint.Result = constraint.invoke(fcn);
                constraint.Passed = constraint.InnerConstraint.satisfiedBy(constraint.Result);
            end
            tf = constraint.Passed;
        end
    end
end
% LocalWords:  ANOTHERCONSTRAINT
