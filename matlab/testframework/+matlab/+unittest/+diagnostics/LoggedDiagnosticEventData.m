classdef (Hidden) LoggedDiagnosticEventData < event.EventData
    % This class is undocumented and may change in a future release.
    
    %   The LoggedDiagnosticEventData class holds information about a call to
    %   the log method. It is passed to callback functions listening to the
    %   DiagnosticLogged event.
    %
    %   LoggedDiagnosticEventData properties:
    %       Verbosity        - The verbosity of the logged message
    %       Timestamp        - The date and time of the call to the log method
    %       Diagnostic       - matlab.unittest.diagnostics.Diagnostic instance
    %       Stack            - Location of the call to the log method
    %       DiagnosticResult - Cell array of logged messages
    %
    %   See also: matlab.unittest.TestCase/log, matlab.unittest.TestCase/DiagnosticLogged
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Verbosity - The verbosity of the logged message
        %   The Verbosity property is an instance of the matlab.unittest.Verbosity
        %   enumeration. It describes the level of verbosity of the logged message.
        Verbosity
        
        % Timestamp - The date and time of the call to the log method
        %   The Timestamp property is the 1-by-6 output that results from the call
        %   to CLOCK at the time the log method is called.
        Timestamp
    end
    
    properties (Dependent, SetAccess=immutable)
        % Diagnostic - matlab.unittest.diagnostics.Diagnostic instance
        %   The Diagnostic property holds onto one or more Diagnostic instances
        %   that describe the logged message.
        Diagnostic
        
        % Stack - Location of the call to the log method
        %   The stack property is a structure array the provides information about
        %   the location of the call to the log method.
        Stack
        
        % DiagnosticResult - Cell array of logged messages
        %   The DiagnosticResult property is a cell array of strings of logged
        %   diagnostic messages.
        DiagnosticResult
    end
    
    properties (Access=private)
        RawDiagnostic
        InternalDiagnostic = [];
        
        RawStack
        InternalStack = [];
        
        InternalDiagnosticResult = [];
    end
    
    properties (Constant, Access=private)
        StackParser = createStackParser;
    end
    
    methods
        function evd = LoggedDiagnosticEventData(verbosity, diag, stack, timestamp)
            validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
            validateattributes(diag, {'char', 'function_handle', 'matlab.unittest.diagnostics.Diagnostic'}, {}, '', 'diagnostic');
            evd.StackParser.parse(stack);
            validateattributes(timestamp, {'double'}, {'size', [1, 6]}, '', 'timestamp');
            
            % Convert a numeric value to an enumeration value. This also
            % validates that the supplied verbosity level is valid.
            evd.Verbosity = matlab.unittest.Verbosity(verbosity);
            
            evd.RawDiagnostic = diag;
            evd.RawStack = stack;
            evd.Timestamp = timestamp;
        end
        
        function diag = get.Diagnostic(evd)
            import matlab.unittest.diagnostics.StringDiagnostic;
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
            
            if isempty(evd.InternalDiagnostic)
                % Convert the raw, user-supplied diagnostic to a
                % matlab.unittest.diagnostics.Diagnostic instance
                rawDiag = evd.RawDiagnostic;
                diagClass = metaclass(rawDiag);
                if diagClass <= ?char
                    evd.InternalDiagnostic  = StringDiagnostic(rawDiag);
                elseif diagClass <= ?function_handle
                    evd.InternalDiagnostic = FunctionHandleDiagnostic(rawDiag);
                else  % matlab.unittest.diagnostics.Diagnostic
                    evd.InternalDiagnostic = rawDiag;
                end
            end
            
            diag = evd.InternalDiagnostic;
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
        
        function result = get.DiagnosticResult(evd)
            if ~iscellstr(evd.InternalDiagnosticResult)
                try
                    arrayfun(@diagnose, evd.Diagnostic);
                    evd.InternalDiagnosticResult = {evd.Diagnostic.DiagnosticResult};
                catch exception
                    evd.InternalDiagnosticResult = ...
                        {getString(message('MATLAB:unittest:Diagnostic:ErrorCapturingDiagnostics', ...
                        getCorrectlyHyperlinkedReport(exception)))};
                end
            end
            
            result = evd.InternalDiagnosticResult;
        end
    end
    
    methods (Static, Hidden)
        function destEvd = fromAnotherLoggedDiagnosticEventData(sourceEvd)
            destEvd = matlab.unittest.diagnostics.LoggedDiagnosticEventData(...
                sourceEvd.Verbosity, ...
                sourceEvd.RawDiagnostic, ...
                sourceEvd.RawStack, ...
                sourceEvd.Timestamp);            
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
% LocalWords:  evd
