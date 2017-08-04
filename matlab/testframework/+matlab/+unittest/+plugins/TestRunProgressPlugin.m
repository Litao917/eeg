classdef (Hidden) TestRunProgressPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                          matlab.unittest.internal.plugins.Printable
    %
    
    % This class is undocumented and may change in a future release.
    
    % TestRunProgressPlugin - Factory for creating test run progress plugin.
    % 
    %   The TestRunProgressPlugin factory can be used to construct a plugin to
    %   show the progress of the test run to the Command Window.
    %
    %   TestRunProgressPlugin Methods:
    %       withVerbosity - Construct a TestRunProgressPlugin with a specified verbosity.
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Constant, Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:TestRunProgressPlugin');
    end
    
    properties(Constant, Hidden)
        ContentDelimiter = repmat('_', 1, 10);
    end
    
    methods (Static)
        function plugin = withVerbosity(verbosity, stream)
            %
            
            % This method is undocumented and will change in a future release.
            
            %withVerbosity - Construct a TestRunProgressPlugin with a specified verbosity.
            %   PLUGIN = TestRunProgressPlugin.withVerbosity(VERBOSITY) returns a
            %   plugin that prints test run progress at the specified verbosity level.
            %   VERBOSITY can be specified as either a numeric value (0, 1, 2, or 3) or
            %   a value from the matlab.unittest.Verbosity enumeration.
            %
            %   PLUGIN = TestRunProgressPlugin.withVerbosity(VERBOSITY, STREAM) creates
            %   a TestRunProgressPlugin and redirects all the text output produced to
            %   the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   See also: OutputStream
            
            import matlab.unittest.Verbosity;
            import matlab.unittest.plugins.testrunprogress.TerseProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.DetailedProgressPlugin;
            import matlab.unittest.plugins.testrunprogress.VerboseProgressPlugin;
            
            % Validate the Verbosity input
            validateattributes(verbosity, {'numeric', 'matlab.unittest.Verbosity'}, {'scalar'}, '', 'verbosity');
            matlab.unittest.Verbosity(verbosity);
            
            if nargin < 2
                stream = {};
            else
                stream = {stream};
            end
            
            if verbosity == Verbosity.Terse
                plugin = TerseProgressPlugin(stream{:});
            elseif verbosity == Verbosity.Concise
                plugin = ConciseProgressPlugin(stream{:});
            elseif verbosity == Verbosity.Detailed
                plugin = DetailedProgressPlugin(stream{:});
            elseif verbosity == Verbosity.Verbose
                plugin = VerboseProgressPlugin(stream{:});
            end
        end
    end
    
    methods (Access=protected)
        function plugin = TestRunProgressPlugin(varargin)
            plugin@matlab.unittest.internal.plugins.Printable(varargin{:});
        end
    end
end
% LocalWords:  testrunprogress
