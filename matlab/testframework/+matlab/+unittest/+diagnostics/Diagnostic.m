classdef Diagnostic < handle & matlab.mixin.Heterogeneous
    % Diagnostic - Fundamental interface for matlab.unittest diagnostics.
    %
    %   The Diagnostic interface is the means by which the matlab.unittest
    %   framework and its clients package diagnostic information. All
    %   diagnostics are built off of the Diagnostic interface, whether they are
    %   user-supplied diagnostics  for an individual comparison or if they are
    %   diagnostics associated with a given Constraint implementation used in
    %   that comparison.
    %
    %   Classes which derive from the Diagnostic interface encode the
    %   diagnostic actions to be performed and produce a diagnostic result that
    %   can be used by the test running framework and displayed as appropriate
    %   for that framework.
    %
    %   In exchange for meeting this requirement, any Diagnostic implementation
    %   can be used directly with matlab.unittest qualifications, which execute
    %   the diagnostic action and store the result to be utilized by the test
    %   running framework.
    %
    %   As a convenience, the framework creates appropriate diagnostic
    %   instances for raw strings and function handles when they are user
    %   supplied diagnostics. To remain performant, these values are only
    %   converted into Diagnostic instances when a qualification failure occurs
    %   or when the test running framework is explicitly observing passed
    %   qualifications, which the default test runner does not.
    %
    %   Diagnostic properties:
    %       DiagnosticResult - Result of the diagnostic evaluation
    %
    %   Diagnostic methods:
    %       diagnose    - Execute diagnostic action for the instance
    %       join        - Join multiple diagnostics into a single array
    %
    %   Examples:
    %
    %   import matlab.unittest.constraints.IsEqualTo;
    %   import matlab.unittest.TestCase;
    %
    %   % Create a TestCase for interactive use
    %   testCase = TestCase.forInteractiveUse;
    %
    %   % Convenience API to create StringDiagnostic upon failure
    %   testCase.verifyThat(1, IsEqualTo(2), 'User supplied Diagnostic');
    %
    %   % Convenience API to create FunctionHandleDiagnostic upon failure
    %   testCase.verifyThat(1, IsEqualTo(2), @() system('ps'));
    %
    %   % Usage of user defined Diagnostic upon failure (see definition below)
    %   testCase.verifyThat(1, IsEqualTo(2), ProcessStatusDiagnostic('Could not close my third party application!'));
    %
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   % Diagnostic definition
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   classdef ProcessStatusDiagnostic < matlab.unittest.diagnostics.Diagnostic
    %       % ProcessStatusDiagnostic - an example diagnostic
    %       %
    %       %   Simple example to demonstrate how to create a custom
    %       %   diagnostic.
    %
    %       properties
    %
    %           % HeaderText - user-supplied header to display
    %           HeaderText = '(No header supplied)';
    %       end
    %
    %       methods
    %           function diag = ProcessStatusDiagnostic(header)
    %               % Constructor - construct a ProcessStatusDiagnostic
    %               %
    %               %   The ProcessStatusDiagnostic constructor takes an
    %               %   optional header to be displayed along with process
    %               %   information.
    %               diag.HeaderText = header;
    %           end
    %
    %           function diagnose(diag)
    %
    %               [status processInfo] = system('ps');
    %               if (status ~= 0)
    %                   processInfo = sprintf(...
    %                       '!!! Could not obtain status diagnostic information!!! [exit status code: %d]\n%s', ...
    %                       status, processInfo);
    %               end
    %               diag.DiagnosticResult = sprintf('%s\n%s', diag.HeaderText, processInfo);
    %           end
    %       end
    %
    %   end %classdef
    %
    %   See also
    %       StringDiagnostic
    %       FunctionHandleDiagnostic
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    
    
    methods(Static)
        function diag = join(varargin)
            % Diagnostic.join      - Join multiple diagnostics into a single array
            %
            %   DIAGARRAY = Diagnostic.join(DIAG1, DIAG2, ... DIAGN) joins together all
            %   of the diagnostic content specified in DIAG1, DIAG2, ... DIAGN into a
            %   single Diagnostic array DIAGARRAY. The elements DIAG1, DIAG2, ... DIAGN
            %   can be Diagnostic instances, strings, function handles, or any other
            %   arbitrary values. The resulting diagnostics become:
            %
            %       Diagnostic      - (unchanged - used as supplied)
            %       char            - matlab.unittest.diagnostics.StringDiagnostic
            %       function handle - matlab.unittest.diagnostics.FunctionHandleDiagnostic
            %       arbitrary value - matlab.unittest.diagnostics.DispDiagnostic
            %
            %   Examples:
            %
            %       % The following example creates a diagnostic array of length 4,
            %       % demonstrating standard Diagnostic conversions. Note:
            %       % MyCustomDiagnostic is for example purposes and is not executable
            %       % code.
            %
            %       import matlab.unittest.diagnostics.Diagnostic;
            %       import matlab.unittest.constraints.IsTrue;
            %
            %       arbitraryValue = 5;
            %       testCase.verifyThat(false, IsTrue, ...
            %           Diagnostic.join(...
            %               'should have been true', ...
            %               @() system('ps'), ...
            %               arbitraryValue, ...
            %               MyCustomDiagnostic))
            %
            %   See also:
            %       matlab.mixin.Heterogeneous
            

            import matlab.unittest.diagnostics.Diagnostic;
            narginchk(1,Inf);
            diag = Diagnostic.convertObject('matlab.unittest.diagnostic.Diagnostic', varargin{1});
            diag = [diag varargin{2:end}];
        end
    end
    
    properties(SetAccess=protected)
        % DiagnosticResult -  Result of the diagnostic evaluation
        %
        %   The DiagnosticResult property encompasses the means by which the actual
        %   diagnostic information is communicated to consumers of Diagnostics such
        %   as testing frameworks. The property currently must be a string, and
        %   should be populated during the diagnostic evaluation performed in the
        %   diagnose method.
        %
        %   See also diagnose
        %
        DiagnosticResult = getString(message('MATLAB:unittest:Diagnostic:NotYetPopulated'));
    end
    
    methods(Abstract)
        % diagnose(diag) - Execute diagnostic action for the instance
        %
        %   The diagnose method is the means by which individual Diagnostic
        %   implementations can perform their respective diagnostic evaluations.
        %   Each concrete implementation is responsible for populating the
        %   DiagnosticResult property. Any text printed to the Command
        %   Window during diagnostic evaluation is not considered part of the
        %   diagnostic result and is ignored by the testing framework.
        %
        %   See also DiagnosticResult
        %
        diagnose(diag);
    end
    
    methods
        function set.DiagnosticResult(diag, result)
            validateattributes(result, {'char'}, {}, '', 'result');
            diag.DiagnosticResult = result;
        end
    end
    
    methods (Hidden, Static, Access=protected, Sealed)
        function convertedObject = convertObject(~, objectToConvert)
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
            import matlab.unittest.diagnostics.StringDiagnostic;
            import matlab.unittest.diagnostics.DisplayDiagnostic;
            
            class = metaclass(objectToConvert);
            if class <= ?char
                convertedObject = StringDiagnostic(objectToConvert);
            elseif class <= ?function_handle
                convertedObject = FunctionHandleDiagnostic(objectToConvert);
            else
                convertedObject = DisplayDiagnostic(objectToConvert);
            end
        end
        function instance = getDefaultScalarElement
            instance = matlab.unittest.internal.diagnostics.EmptyDiagnostic;
        end
        
    end
    
    methods(Hidden, Access=protected)
        function diag = Diagnostic
        end
    end
    
end

% LocalWords:  performant ps DIAGARRAY DIAGN
