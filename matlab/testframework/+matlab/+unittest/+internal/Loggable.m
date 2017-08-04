classdef Loggable < handle
    % This class is undocumented.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    events (Hidden, NotifyAccess=private)
        % This event is undocumented and may change in a future release.
        
        % DiagnosticLogged - Event triggered by calls to the log method.
        %   The DiagnosticLogged event provides a means to observe and react to
        %   calls to the log method. Callback functions listening to the event
        %   receive information about the time and location of the call to the log
        %   method as well as the user-supplied diagnostic message and the level.
        %
        %   See also: matlab.unittest.TestCase/log
        DiagnosticLogged
    end
    
    methods (Hidden, Sealed)
        function log(content, varargin)
            % This method is undocumented and may change in a future release.
            
            % log - Print diagnostic information.
            %   The log method provides a means for tests to log information during the
            %   execution of a test. Logged messages are displayed only if the
            %   framework is configured to do so, for example, through the use of a
            %   matlab.unittest.plugins.LoggingPlugin instance.
            %
            %   TESTCASE.log(DIAG) logs the supplied diagnostic DIAG which can be
            %   specified as a string, a function handle that displays a string, or an
            %   instance of a matlab.unittest.diagnostics.Diagnostic.
            %
            %   TESTCASE.log(LEVEL, DIAG) logs the diagnostic at the specified LEVEL.
            %   LEVEL can be either a numeric value (0, 1, 2, or 3) or a value from the
            %   matlab.unittest.Verbosity enumeration. When level is unspecified, the
            %   log method uses level Concise (1).
            %   
            %   See also: matlab.unittest.plugins.LoggingPlugin, matlab.unittest.Verbosity
            
            import matlab.unittest.Verbosity;
            import matlab.unittest.diagnostics.LoggedDiagnosticEventData;
            
            % Before doing anything else, capture the current time to get
            % the best estimate of the time the log method was invoked.
            timestamp = clock;
            
            narginchk(2,3);
            
            if nargin > 2
                level = varargin{1};
            else
                % Default verbosity level is Concise
                level = Verbosity.Concise;
            end
            
            diag = varargin{end};
            stack = dbstack('-completenames');
            
            evd = LoggedDiagnosticEventData(level, diag, stack, timestamp);
            content.notify('DiagnosticLogged', evd);
        end
    end
end

% LocalWords:  completenames evd
