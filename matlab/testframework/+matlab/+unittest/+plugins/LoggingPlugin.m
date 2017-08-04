classdef (Hidden) LoggingPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                  matlab.unittest.internal.plugins.Printable                   
	%
    
    % This class is undocumented and may change in a future release.
    
    % LoggingPlugin - Report diagnostic messages created by the log method.
    %   The LoggingPlugin provides a means to report diagnostic messages that
    %   are created by calls to the matlab.unittest.TestCase log method.
    %   Through the withVerbosity static method, the plugin can be configured
    %   to respond to messages of a particular verbosity. The withVerbosity
    %   method also accepts a number of name/value pairs for configuring the
    %   format for reporting logged messages.
    %
    %   LoggingPlugin properties:
    %       Verbosity      - Levels supported by this plugin instance.
    %       Description    - Logged diagnostic message description.
    %       HideLevel      - Boolean that indicates whether the level is printed.
    %       HideTimestamp  - Boolean that indicates whether the timestamp is printed.
    %       NumStackFrames - Number of stack frames to print.
    %
    %   LoggingPlugin methods:
    %       withVerbosity - Construct a LoggingPlugin for messages of the specified verbosity.
    %
    %   See also: matlab.unittest.TestCase/log, matlab.unittest.Verbosity
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Verbosity - Levels supported by this plugin instance.
        %   The Verbosity property is an array of matlab.unittest.Verbosity
        %   instances. The plugin only reacts to diagnostics that are logged at a
        %   level listed in this array.
        Verbosity;
        
        % Description - Logged diagnostic message description.
        %   The Description property is a string which is printed alongside each
        %   logged diagnostic message. By default, the Description "Diagnostic
        %   logged" is used.
        Description;
        
        % HideLevel - Boolean that indicates whether the level is printed.
        %   The HideLevel property is a logical value which determines whether or
        %   not the verbosity level of the message is printed alongside each logged
        %   diagnostic. By default, HideLevel is false meaning that the
        %   verbosity level is printed.
        HideLevel;
        
        % HideTimestamp - Boolean that indicates whether the timestamp is printed.
        %   The HideTimestamp property is a logical value which determines whether
        %   or not the time when the logged message was generated is printed
        %   alongside each logged diagnostic. By default, HideTimestamp is false
        %   meaning that the timestamp is printed.
        HideTimestamp;
        
        % NumStackFrames - Number of stack frames to print.
        %   The NumStackFrames property is an integer that dictates the number of
        %   stack frames to print after each logged diagnostic message. By default,
        %   NumStackFrames is zero, meaning that no stack information is printed.
        %   NumStackFrames can be set to Inf to print all available stack frames.
        NumStackFrames;
    end
    
    properties (Constant, Access=private)
        Parser = createParser;
        Catalog = matlab.internal.Catalog('MATLAB:unittest:LoggingPlugin');
    end
    
    methods (Static)
        function plugin = withVerbosity(varargin)
            % This methods is undocumented and will change in a future release.
            
            % withVerbosity - Construct a LoggingPlugin for messages of the specified verbosity.
            %   PLUGIN = LoggingPlugin.withVerbosity(VERBOSITY) constructs a LoggingPlugin that
            %   reacts to messages logged at VERBOSITY or lower. VERBOSITY can be
            %   specified as a numeric value (0, 1, 2, or 3) or one of the values from
            %   the matlab.unittest.Verbosity enumeration.
            %
            %   PLUGIN = LoggingPlugin.withVerbosity(VERBOSITY, STREAM) creates a
            %   LoggingPlugin and redirects all the text output produced to the
            %   OutputStream STREAM. If this is not supplied, a ToStandardOutput stream
            %   is used.
            %
            %   PLUGIN = withVerbosity(VERBOSITY, NAME, VALUE, ...) constructs a
            %   LoggingPlugin with one or more Name/Value pairs. Specify an of the
            %   following Name/Value pairs:
            %       * Description    - String to print alongside each logged diagnostic.
            %                          By default, the plugin uses "Diagnostic logged" as
            %                          the Description.
            %       * HideLevel      - Boolean that indicates whether the level is printed.
            %                          By default, the plugin displays the verbosity level.
            %       * HideTimestamp  - Boolean that indicates whether the timestamp is
            %                          printed. By default, the plugin displays the
            %                          timestamp.
            %       * NumStackFrames - Number of stack frames to print. By default, the
            %                          plugin displays zero stack frames.
            %
            %   See also: OutputStream, ToStandardOutput
            
            import matlab.unittest.plugins.LoggingPlugin;
            
            parser = LoggingPlugin.Parser;
            parser.parse(varargin{:});
            
            if any(strcmp(parser.UsingDefaults,'Stream'))
                plugin = LoggingPlugin;
            else
                plugin = LoggingPlugin(parser.Results.Stream);
            end
            
            if parser.Results.ExcludingLowerLevels
                % The plugin reacts to only the specified level
                plugin.Verbosity = matlab.unittest.Verbosity(parser.Results.Verbosity);
            else
                % The plugin reacts to the specified level and all lower levels
                plugin.Verbosity = matlab.unittest.Verbosity(0:double(parser.Results.Verbosity));
            end
            
            plugin.Description = parser.Results.Description;
            plugin.NumStackFrames = parser.Results.NumStackFrames;
            plugin.HideLevel = parser.Results.HideLevel;
            plugin.HideTimestamp = parser.Results.HideTimestamp;
        end
    end
    
    methods (Access=protected)
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(fixture);
        end
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(testCase);
        end
        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            plugin.registerDiagnosticLoggedCallback(testCase);
        end
    end
    
    methods (Hidden, Access=protected)
        function registerDiagnosticLoggedCallback(plugin, content)
            content.addlistener('DiagnosticLogged', @plugin.processLoggedDiagnostic);
        end
    end
    
    methods (Access=private)
        % Private constructor. Must use static methods to create an instance.
        function plugin = LoggingPlugin(varargin)
            plugin@matlab.unittest.internal.plugins.Printable(varargin{:});
        end
        
        function processLoggedDiagnostic(plugin, ~, evd)
            % Print only those diagnostics that are logged at a level that
            % the plugin reacts to.
            if any(plugin.Verbosity == evd.Verbosity)
                plugin.printLoggedDiagnostic(evd);
            end
        end
        
        function printLoggedDiagnostic(plugin, evd)
            % Print the header using the format
            % [Level] Description (Timestamp): Message
            plugin.print('%s%s%s%s%s', ...
                plugin.getVerbosityString(evd), ...
                plugin.Description, ...
                plugin.getDescriptionTimestampSpace, ...
                plugin.getTimestampString(evd), ...
                plugin.getDescriptionTimestampColon);
            
            result = evd.DiagnosticResult;
            if numel(result) > 1 || ~isempty(strfind(result{1}, sprintf('\n')))
                % When there is more than one Diagnostic, each one
                % (including the first) goes on its own line.
                % We also insert a newline when the first diagnostic
                % extends to multiple lines.
                plugin.printEmptyLine;
            end
            
            % Print the actual logged diagnostic(s)
            for idx = 1:numel(result)
                plugin.print('%s\n', result{idx});
            end
            
            if plugin.NumStackFrames > 0
                plugin.printStackInformation(evd);
            end
        end
        
        % Getters for returning formatted string fragments for printing
        % logged diagnostic messages.
        function str = getVerbosityString(plugin, evd)
            if plugin.HideLevel
                str = '';
            else
                str = sprintf('[%s] ', char(evd.Verbosity));
            end
        end
        function str = getTimestampString(plugin, evd)
            if plugin.HideTimestamp
                str = '';
            else
                str = sprintf('(%s)', datestr(evd.Timestamp, 30));
            end
        end
        function str = getDescriptionTimestampColon(plugin)
            if isempty(plugin.Description) && plugin.HideTimestamp
                str = '';
            else
                str = ': ';
            end
        end
        function str = getDescriptionTimestampSpace(plugin)
            if isempty(plugin.Description) || plugin.HideTimestamp
                str = '';
            else
                str = ' ';
            end
        end
        
        function printStackInformation(plugin, evd)
            import matlab.unittest.internal.diagnostics.createStackInfo;
            import matlab.unittest.internal.diagnostics.indent;
            
            % Print the header
            indention = '    ';
            plugin.printLine(indent(plugin.Catalog.getString('StackInformation'), indention));
            
            % Starting from the top of the stack, print as many frames as
            % requested, up to the total number of stack frames present.
            stack = evd.Stack;
            stack = stack(1:min(end,plugin.NumStackFrames));
            plugin.print('%s\n', indent(createStackInfo(stack), indention));
        end
    end
end

function parser = createParser
import matlab.unittest.plugins.LoggingPlugin;

parser = inputParser;
parser.PartialMatching = false;
parser.CaseSensitive = true;
parser.StructExpand = false;

parser.addRequired('Verbosity', @validateVerbosity);
parser.addOptional('Stream', [], ...
    @(stream)validateattributes(stream, {'matlab.unittest.plugins.OutputStream'}, ...
    {'scalar'}, '', 'OutputStream'));
parser.addParameter('Description', LoggingPlugin.Catalog.getString('DefaultDescription'), ...
    @(desc)validateattributes(desc, {'char'}, {}, '', 'Description'));
parser.addParameter('ExcludingLowerLevels', false, ...
    @(exclude)validateattributes(exclude, {'logical'}, {'scalar'}, '', 'ExcludingLowerLevels'));
parser.addParameter('NumStackFrames', 0, @validateNumStackFrames);
parser.addParameter('HideLevel', false, ...
    @(level)validateattributes(level, {'logical'}, {'scalar'}, '', 'HideLevel'));
parser.addParameter('HideTimestamp', false, ...
    @(time)validateattributes(time, {'logical'}, {'scalar'}, '', 'HideTimestamp'));
end

function validateVerbosity(verbosity)
validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
% Validate that a numeric value is valid
matlab.unittest.Verbosity(verbosity);
end

function bool = validateNumStackFrames(num)
validateattributes(num, {'numeric'}, {'scalar', 'real', 'nonnan', 'nonnegative'}, '', 'NumStackFrames');
% NumStackFrames must also be integer-valued
bool = isequal(num, round(num));
end

% LocalWords:  evd
