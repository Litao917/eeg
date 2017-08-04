classdef QualificationEventData < event.EventData
    % QualificationEventData - EventData passed to callbacks listening to qualification events
    %
    %   The QualificationEventData class holds information about a
    %   qualification. It is passed to callback functions that are
    %   registered to listen to passing and/or failing qualifications.
    %   
    %   Qualifications can be assertions, fatal assertions, assumptions or
    %   verifications performed on test content. The events associated with
    %   these qualifications are defined in the corresponding qualification
    %   classes.
    %   
    %   QualificationEventData properties:
    %       ActualValue                - Value to which the Constraint is applied
    %       Constraint                 - Constraint used for the qualification
    %       TestDiagnostic             - Diagnostic specified in the qualification
    %       TestDiagnosticResult       - Result of diagnostic specified in the qualification    
    %       FrameworkDiagnosticResult  - Result of diagnostic from constraint used for the qualification
    %       Stack                      - Function call stack leading upto the qualification
    %
    %   See also
    %       matlab.unittest.qualifications.Assertable
    %       matlab.unittest.qualifications.FatalAssertable
    %       matlab.unittest.qualifications.Assumable
    %       matlab.unittest.qualifications.Verifiable
    %       matlab.unittest.fixtures.Fixture


    % Copyright 2011-2013 The MathWorks, Inc.
    
    properties(SetAccess = immutable)   
        % ActualValue - Value to which the Constraint is applied   
        %   
        %   Constraint operates on this value to determine satisfaction
        %   of its qualification logic.
        ActualValue;
    end
    
    properties(Dependent, SetAccess = private)
        % Constraint - Constraint used for the qualification
        Constraint;  

        % TestDiagnostic - Diagnostic specified in the qualification
        TestDiagnostic;                        
        
        % TestDiagnosticResult - Result of diagnostic specified in the qualification
        %
        %   The TestDiagnosticResult is a char array holding the result
        %   from diagnosing the diagnostic specified in the qualification
        TestDiagnosticResult;
        
        % FrameworkDiagnosticResult - Result of diagnostic from constraint used for the qualification
        %
        %   The FrameworkDiagnosticResult is a char array holding the
        %   result from diagnosing the diagnostic from the constraint used
        %   for the qualification
        FrameworkDiagnosticResult;
        
        % Stack - Function call stack leading upto the qualification
        %
        %   The stack property is a structure array the provides
        %   information about the location of the call leading upto the
        %   qualification.
        Stack;
    end
    
    properties (Access = private)        
        RawStack;
        InternalStack = [];
        InternalTestDiagnosticResult;
        InternalFrameworkDiagnosticResult;    
        InternalConstraint;
    end
    
    properties (SetAccess = immutable, GetAccess = private)
        InternalTestDiagnostic = '';        
    end
    
    properties(Dependent, Access = private)
        FrameworkDiagnostic;
    end
    
    properties(Constant, Access=private)
        StackParser = createStackParser;
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        % These are undocumented properties and will be removed in a future
        % release.
        UserDiagnostic;
        UserDiagnosticResult;
        ConstraintDiagnosticResult;
    end
        
    methods
        function evd = QualificationEventData(stack, actual, constraint, testDiag)            
            % QualificationEventData - Class constructor

            evd.StackParser.parse(stack);
            evd.RawStack = stack;
            
            evd.ActualValue = actual;
            evd.InternalConstraint = constraint;
            
            if nargin > 3
                validateattributes(testDiag, {'char', 'function_handle', 'matlab.unittest.diagnostics.Diagnostic'}, ...
                    {}, '', 'diag');
                evd.InternalTestDiagnostic = testDiag;
            end            
        end
    end  
    
    methods (Static, Hidden)
        function destEvd = fromAnotherQualificationEventData(sourceEvd)
            % Static [re]construction of a QualificationEventData instance
            % from a source QualificationEventData. This is usually useful
            % to forward an event notification re-using the information
            % held by the source event data.
            destEvd = matlab.unittest.qualifications.QualificationEventData(...
                sourceEvd.RawStack, ...
                sourceEvd.ActualValue, ...
                sourceEvd.InternalConstraint, ...
                sourceEvd.TestDiagnostic);
        end
    end
    
    methods
        function constraint = get.Constraint(evd)
            if isa(evd.InternalConstraint, 'matlab.unittest.internal.constraints.ConstraintDecorator')
                constraint = evd.InternalConstraint.RootConstraint;
            else
                constraint = evd.InternalConstraint;
            end
        end
        
        function stack = get.Stack(evd)
            import matlab.unittest.internal.trimStackStart;
            import matlab.unittest.internal.trimStackEnd;
            
            if isempty(evd.InternalStack)
                % Trim both ends of the stack
                evd.InternalStack = trimStackEnd(trimStackStart(evd.RawStack));
            end            
            stack = evd.InternalStack;
        end
        
        function diag = get.FrameworkDiagnostic(evd)
            import matlab.unittest.diagnostics.StringDiagnostic;
            
            if isa(evd.ActualValue, 'matlab.unittest.constraints.ActualValueProxy')
                obj = evd.ActualValue;
                value = evd.InternalConstraint;
            else
                obj = evd.InternalConstraint;
                value = evd.ActualValue;
            end
            
            try
                diag = obj.getDiagnosticFor(value);
            catch exception
                diag = StringDiagnostic(getString(message('MATLAB:unittest:Diagnostic:ErrorEvaluatingDiagnostic', ...
                    getCorrectlyHyperlinkedReport(exception))));
            end
        end
        
        function result = get.TestDiagnostic(evd)
            result = evd.InternalTestDiagnostic;
        end
        
        function result = get.TestDiagnosticResult(evd)
            result = captureInternalTestDiagnosticResult(evd);            
        end
        
        function result = get.FrameworkDiagnosticResult(evd)
            result = captureInternalFrameworkDiagnosticResult(evd);            
        end
        
    end
    
    methods
        function result = get.UserDiagnostic(evd)
            result = evd.InternalTestDiagnostic;
        end
        
        function result = get.UserDiagnosticResult(evd)
            result = captureInternalTestDiagnosticResult(evd);            
        end
        
        function result = get.ConstraintDiagnosticResult(evd)
            result = captureInternalFrameworkDiagnosticResult(evd);            
        end        
    end
    
    
    methods(Access=private)
        
        function result = captureFrameworkDiagnosticResult(data)
            
            diag = data.FrameworkDiagnostic;            
            validateattributes(diag, {'matlab.unittest.diagnostics.Diagnostic'}, ...
                {'scalar'}, '', 'diag');
            result = data.captureDiagnosticResult(diag);
        end
        
        function result = captureTestDiagnosticResult(data)
            
            import matlab.unittest.diagnostics.StringDiagnostic;
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
            
            diag = data.TestDiagnostic;
            
            if ischar(diag)
                diag = StringDiagnostic(diag);
            elseif isa(diag, 'function_handle')
                diag = FunctionHandleDiagnostic(diag);
            end
            result = data.captureDiagnosticResult(diag);
        end
        
        function result = captureDiagnosticResult(~, diag) 
            try
                arrayfun(@diagnose, diag);
                result = {diag.DiagnosticResult};
            catch exception
                result = {getString(message('MATLAB:unittest:Diagnostic:ErrorCapturingDiagnostics', ...
                    getCorrectlyHyperlinkedReport(exception)))};
            end
        end
        
        function result = captureInternalTestDiagnosticResult(evd)
            result = evd.InternalTestDiagnosticResult;
            if ~iscellstr(result)
                result = evd.captureTestDiagnosticResult;
                evd.InternalTestDiagnosticResult = result;
            end
        end
        
        function result = captureInternalFrameworkDiagnosticResult(evd)
            result = evd.InternalFrameworkDiagnosticResult;
            if ~iscellstr(result)
                result = evd.captureFrameworkDiagnosticResult;
                evd.InternalFrameworkDiagnosticResult = result;
            end
        end               
        
    end
    
end


function p = createStackParser

p = inputParser;
p.addRequired('stack', @(s) isstruct(s) && all(isfield(s,{'file','name','line'})));
end

function report = getCorrectlyHyperlinkedReport(exception)
if matlab.unittest.internal.diagnostics.shouldHyperLink
    report = getReport(exception, 'extended', 'hyperlinks', 'on');
else
    report = getReport(exception, 'extended', 'hyperlinks', 'off');
end
end