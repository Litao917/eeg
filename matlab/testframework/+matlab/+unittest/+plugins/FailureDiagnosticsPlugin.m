classdef FailureDiagnosticsPlugin < matlab.unittest.plugins.TestRunnerPlugin & ...
                                    matlab.unittest.internal.plugins.Printable
    % FailureDiagnosticsPlugin - Plugin to show diagnostics on failure.
    % 
    %   The FailureDiagnosticsPlugin can be added to the TestRunner
    %   to show diagnostics upon failure.
    %
    %   FailureDiagnosticsPlugin methods:
    %       FailureDiagnosticsPlugin - Class constructor
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.FailureDiagnosticsPlugin;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(FailureDiagnosticsPlugin);
    %
    %       % Run the suite to see diagnostic output on failure
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin, matlab.unittest.diagnostics
    %
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    
    properties(Constant, Access=private)
        FailureDiagCatalog = matlab.internal.Catalog('MATLAB:unittest:FailureDiagnosticsPlugin');
        DiagnosticCatalog = matlab.internal.Catalog('MATLAB:unittest:Diagnostic');
        QualificationDelimiter = repmat('=',1,80);
        Indention = '    ';
    end
    
    methods
        function plugin = FailureDiagnosticsPlugin(varargin)
            %FailureDiagnosticsPlugin - Class constructor
            %   PLUGIN = FailureDiagnosticsPlugin creates a FailureDiagnosticsPlugin
            %   instance and returns it in PLUGIN. This plugin can then be added to a
            %   TestRunner instance to show diagnostics when test failure conditions
            %   are encountered.
            %
            %   PLUGIN = FailureDiagnosticsPlugin(STREAM) creates a
            %   FailureDiagnosticsPlugin and redirects all the text output produced to
            %   the OutputStream STREAM. If this is not supplied, a ToStandardOutput
            %   stream is used.
            %
            %   Example:
            %       
            %       import matlab.unittest.TestRunner;
            %       import matlab.unittest.TestSuite;
            %       import matlab.unittest.plugins.FailureDiagnosticsPlugin;
            %
            %       % Create a TestSuite array
            %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
            %       % Create a TestRunner with no plugins
            %       runner = TestRunner.withNoPlugins;
            %
            %       % Create an instance of FailureDiagnosticsPlugin
            %       plugin = FailureDiagnosticsPlugin;
            %
            %       % Add the plugin to the TestRunner
            %       runner.addPlugin(plugin);
            %
            %       % Run the suite and see diagnostics on failure
            %       result = runner.run(suite)
            %
            %   See also: OutputStream, ToStandardOutput
            %
            plugin@matlab.unittest.internal.plugins.Printable(varargin{:});
        end
    end
    
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            
            % Print a summary table showing the failed and incomplete tests
            if ~isempty(plugin.getFailedAndIncompleteTests(pluginData.TestResult))
                printMessage(plugin, false, false, plugin.FailureDiagCatalog, 'FailureSummary');
                plugin.printEmptyLine;
                printIndentedLine(plugin, plugin.getResultSummaryTable(pluginData.TestResult));
            end
        end
        
        function fixture = createSharedTestFixture(plugin, pluginData)
            fixture = createSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            fixtureName = pluginData.Name;
            fixture.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'SharedTestFixtureAssertionFailure', fixtureName));
            fixture.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'SharedTestFixtureFatalAssertionFailure', fixtureName));
            fixture.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                'SharedTestFixtureAssumptionFailureSummary', ...
                'SharedTestFixtureAssumptionFailureDetails', fixtureName));
            fixture.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                'SharedTestFixtureUncaughtException', fixtureName));            
        end
        
        function testCase = createTestClassInstance(plugin, pluginData)
            testCase = createTestClassInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            containerName = pluginData.Name;
            testCase.addlistener('VerificationFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestClassVerificationFailure', containerName));
            testCase.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestClassAssertionFailure', containerName));
            testCase.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestClassFatalAssertionFailure', containerName));
            testCase.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                'TestClassAssumptionFailureSummary', ...
                'TestClassAssumptionFailureDetails', containerName));
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                'TestClassUncaughtException', containerName));
        end


        function testCase = createTestMethodInstance(plugin, pluginData)
            testCase = createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            testName = pluginData.Name;
            testCase.addlistener('VerificationFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestVerificationFailure', testName));
            testCase.addlistener('AssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestAssertionFailure', testName));
            testCase.addlistener('FatalAssertionFailed', @(~,evd) plugin.printFailureCondition(evd, ...
                'TestFatalAssertionFailure', testName));
            testCase.addlistener('AssumptionFailed', @(~,evd) plugin.printAssumptionFailure(evd, ...
                'TestAssumptionFailureSummary', 'TestAssumptionFailureDetails', testName));
            testCase.addlistener('ExceptionThrown', @(~, evd)plugin.printUncaughtException(evd, ...
                'TestUncaughtException', testName));            
        end                
      
        function table = getResultSummaryTable(plugin, result)
            % getResultSummaryTable - Return a string with information
            %   about failed and incomplete tests.
            
            import matlab.unittest.internal.diagnostics.getStringDisplayWidth;
            
            % Table formatting constants
            MARKER = 'X';
            SPACE = ' ';
            HORIZONTAL_SPACER = repmat(SPACE, 1, 2);
            HALF_HORIZONTAL_SPACER = HORIZONTAL_SPACER(1:ceil(end/2));
            ROW_DIVIDER_HEAVY = '=';
            ROW_DIVIDER_LIGHT = '-';
            
            NAME_HEADER = plugin.FailureDiagCatalog.getString('Name');
            FAILED_HEADER = plugin.FailureDiagCatalog.getString('Failed');
            INCOMPLETE_HEADER = plugin.FailureDiagCatalog.getString('Incomplete');
            REASONS_HEADER = plugin.FailureDiagCatalog.getString('Reasons');
            
            ASSUMPTION_FAILED = plugin.FailureDiagCatalog.getString('AssumptionFailed');
            VERIFICATION_FAILED = plugin.FailureDiagCatalog.getString('VerificationFailed');
            ASSERTION_FAILED = plugin.FailureDiagCatalog.getString('AssertionFailed');
            ERRORED = plugin.FailureDiagCatalog.getString('Errored');
            
            HEADERS = {NAME_HEADER, FAILED_HEADER, INCOMPLETE_HEADER, REASONS_HEADER};
            NAME_COLUMN = 2;
            FAILED_COLUMN = 4;
            INCOMPLETE_COLUMN = 6;
            REASONS_COLUMN = 8;
            
            % Get the tests that need to be displayed in the table
            tests = plugin.getFailedAndIncompleteTests(result);
            if isempty(tests)
                table = '';
                return;
            end
            
            % Determine the size of table and preallocate. Each row in tableCell contains
            % HALF_HORIZONTAL_SPACER, column1, HORIZONTAL_SPACER, column2, HORIZONTAL_SPACER, etc.
            nRows = nnz([tests.AssumptionFailed]) + ...
                    nnz([tests.VerificationFailed]) + ...
                    nnz([tests.AssertionFailed]) + ...
                    nnz([tests.Errored]) + 1;
            nCols = 2*numel(HEADERS);
            tableCell = repmat({''}, nRows, nCols);
            
            % Fill in the whitespace in the table.
            tableCell(:,1) = {HALF_HORIZONTAL_SPACER};
            tableCell(:, 3:2:end) = {HORIZONTAL_SPACER};
            
            % Fill in the column header names
            [tableCell{1, 2:2:end}] = HEADERS{:};
            
            % Fill in name, failed, incomplete, and reason(s)
            currentRow = 2;
            lastTestRow = false(nRows, 1);
            for idx = 1:numel(tests)
                tableCell{currentRow, NAME_COLUMN} = tests(idx).Name;
                
                if tests(idx).Failed
                    tableCell{currentRow, FAILED_COLUMN} = MARKER;
                end
                if tests(idx).Incomplete
                    tableCell{currentRow, INCOMPLETE_COLUMN} = MARKER;
                end
                
                % Record information about all the reasons
                addReason('AssumptionFailed', ASSUMPTION_FAILED);
                addReason('VerificationFailed', VERIFICATION_FAILED);
                addReason('AssertionFailed', ASSERTION_FAILED);
                addReason('Errored', ERRORED);
                
                % Keep track of the rows where the summary for each test ends
                % so we can later print row dividers in the right place. The
                % information for a test can extend to multiple lines.
                lastTestRow(currentRow) = true;
            end
            
            function addReason(typeName, reasonMessage)
                if tests(idx).(typeName)
                    tableCell{currentRow, REASONS_COLUMN} = reasonMessage;
                    currentRow = currentRow + 1;
                end
            end
            
            % Find the maximum width of each column
            columnWidths = zeros(1, nCols);
            for idx = 1:nCols
                columnWidths(idx) = max(cellfun(@getStringDisplayWidth, tableCell(:,idx)));
            end
            totalTableWidth = sum(columnWidths);
            
            % Pad each column to the same width
            nameColumnWidth = columnWidths(NAME_COLUMN);
            failedColumnWidth = columnWidths(FAILED_COLUMN);
            incompleteColumnWidth = columnWidths(INCOMPLETE_COLUMN);
            for rowIdx = 1:nRows
                % Pad the Names, left aligned
                padLeftAlign(rowIdx, NAME_COLUMN, nameColumnWidth);
                
                % Pad Failed and Incomplete, centered
                padCentered(rowIdx, FAILED_COLUMN, failedColumnWidth);
                padCentered(rowIdx, INCOMPLETE_COLUMN, incompleteColumnWidth);
            end
            
            function padLeftAlign(row, col, totalLength)
                tableCell{row,col} = [tableCell{row,col}, ...
                    repmat(SPACE, 1, totalLength-numel(tableCell{row,col}))];
            end
            function padCentered(row, col, totalLength)
                spaces = repmat(SPACE, 1, totalLength-numel(tableCell{row,col}));
                tableCell{row,col} = [spaces(1:floor(end/2)), ...
                    tableCell{row,col}, spaces(floor(end/2)+1:end)];
            end
            
            % Convert the cell array to one big string, adding row dividers and newlines
            dividerWidth = totalTableWidth + numel(HORIZONTAL_SPACER) - numel(HALF_HORIZONTAL_SPACER);
            heavyDivider = repmat(ROW_DIVIDER_HEAVY, 1, dividerWidth);
            lightDivider = repmat(ROW_DIVIDER_LIGHT, 1, dividerWidth);
            table = [tableCell{1,:}];  % headers
            table = sprintf('%s\n%s\n', table, heavyDivider);
            for idx = 2:nRows
                % Print the divider for the previous test
                if lastTestRow(idx)
                    table = sprintf('%s%s\n', table, lightDivider);
                end
                table = sprintf('%s%s\n', table, [tableCell{idx,:}]);
            end
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = shouldApplyCommandWindowFormatting(plugin)
            import matlab.unittest.internal.diagnostics.shouldHyperLink;
            bool = plugin.isUsingStandardOutputStream() && shouldHyperLink();
        end
        
        function report = getCorrectlyHyperlinkedReport(plugin, exception)
            
            import matlab.unittest.internal.TrimmedException;
            
            trimmed = TrimmedException(exception);
                        
            if plugin.shouldApplyCommandWindowFormatting()
                report = getReport(trimmed, 'extended', 'hyperlinks', 'on');
            else
                report = getReport(trimmed, 'extended', 'hyperlinks', 'off');
            end
        end
    end
    
    methods(Access=private)
        function tests = getFailedAndIncompleteTests(~, result)
            tests = result([result.Failed] | [result.Incomplete]);
        end
        
        function printFailureCondition(plugin, eventData, headerMessage, varargin)
            plugin.printEmptyLine;
            plugin.printLine(plugin.QualificationDelimiter);
            printCoreDiagnosticInfo(plugin, eventData, plugin.shouldApplyCommandWindowFormatting(), ...
                plugin.FailureDiagCatalog, plugin.DiagnosticCatalog, headerMessage, varargin{:});
            printStackInformation(plugin, eventData.Stack, plugin.DiagnosticCatalog);
            plugin.printLine(plugin.QualificationDelimiter);
        end
        
        function printAssumptionFailure(plugin, eventData, summaryHeaderMsg, detailsHeaderMsg, varargin)
            import matlab.unittest.internal.diagnostics.createCommandWindowHyperlink;
            import matlab.unittest.internal.plugins.PrintableLoggingStream;
            
            plugin.printEmptyLine;
            plugin.printLine(plugin.QualificationDelimiter);
            printMessage(plugin, false, false, plugin.FailureDiagCatalog, summaryHeaderMsg, varargin{:});
            
            % Print the first user diagnostic, if any, with an inline header
            firstDiag = eventData.TestDiagnosticResult{1};
            if ~isempty(firstDiag)
                printMessage(plugin, false, true, plugin.DiagnosticCatalog, 'TestDiagnostic', firstDiag);
            end
            
            % Display a "Details" link if outputting to the Command Window
            % with hyperlinks enabled.
            shouldFormat = plugin.shouldApplyCommandWindowFormatting();
            if shouldFormat
                % Construct a private Printable to aggregate the text that
                % will be printed in the form on a hyperlink.
                detailsStream = PrintableLoggingStream();
                
                detailsStream.printEmptyLine();
                detailsStream.printLine(plugin.QualificationDelimiter);
                printCoreDiagnosticInfo(detailsStream, eventData, shouldFormat, ...
                    plugin.FailureDiagCatalog, plugin.DiagnosticCatalog, detailsHeaderMsg, varargin{:});
                printStackInformation(detailsStream, eventData.Stack, plugin.DiagnosticCatalog);
                detailsStream.printLine(plugin.QualificationDelimiter);
                detailsStream.printEmptyLine;
                
                printIndentedLine(plugin, createCommandWindowHyperlink(detailsStream.Log, ...
                    plugin.FailureDiagCatalog.getString('AssumptionFailureDetails')));
            end
            
            plugin.printLine(plugin.QualificationDelimiter);
        end

        function printUncaughtException(plugin, eventData, headerMessage, varargin)
            import matlab.unittest.internal.diagnostics.indent;
            import matlab.unittest.internal.diagnostics.wrapHeader;
            
            plugin.printEmptyLine;
            plugin.printLine(plugin.QualificationDelimiter);
            
            printMessage(plugin, plugin.shouldApplyCommandWindowFormatting(), false, ...
                plugin.FailureDiagCatalog, headerMessage, varargin{:});
            
            plugin.printEmptyLine;
            printIndentedHeaderWithDashes(plugin, plugin.FailureDiagCatalog, 'ErrorHeader');
            plugin.print('%s', indent(plugin.getCorrectlyHyperlinkedReport(eventData.Exception), ...
                plugin.Indention));
            plugin.printEmptyLine;
            plugin.printLine(plugin.QualificationDelimiter);            
        end
        
    end
end

function printCoreDiagnosticInfo(printable, eventData, shouldBold, failureCat, diagCat, headerMsg, varargin)
printMessage(printable, shouldBold, false, failureCat, headerMsg, varargin{:});

printDiagnosticResults(printable, ...
    diagCat, 'TestDiagnosticHeader', ...
    eventData.TestDiagnosticResult);
printDiagnosticResults(printable, ...
    diagCat, 'FrameworkDiagnosticHeader', ...
    eventData.FrameworkDiagnosticResult);
end

function printStackInformation(printable, stack, catalog)
import matlab.unittest.internal.diagnostics.createStackInfo;
import matlab.unittest.internal.diagnostics.indent;
import matlab.unittest.internal.diagnostics.wrapHeader;

printable.printEmptyLine;
printIndentedHeaderWithDashes(printable, catalog, 'StackInformationHeader');
printable.print('%s', indent(createStackInfo(stack), ...
    matlab.unittest.plugins.FailureDiagnosticsPlugin.Indention));
printable.printEmptyLine;
end

function printDiagnosticResults(printable, catalog, header, results)
for idx = 1:numel(results)
    result = results{idx};
    if ~isempty(result)
        printable.printEmptyLine;
        printIndentedHeaderWithDashes(printable, catalog, header);
        printIndentedLine(printable, result);
    end
end
end

function printMessage(printable, shouldBold, shouldIndent, catalog, message, varargin)
import matlab.unittest.internal.diagnostics.indent;

str = catalog.getString(message, varargin{:});

if shouldBold
    str = sprintf('<strong>%s</strong>', str);
end

if shouldIndent
    str = indent(str, matlab.unittest.plugins.FailureDiagnosticsPlugin.Indention);
end

printable.printLine(str);
end

function printIndentedLine(printable, str)
import matlab.unittest.internal.diagnostics.indent;
str = indent(str, matlab.unittest.plugins.FailureDiagnosticsPlugin.Indention);
printable.printLine(str);
end

function printIndentedHeaderWithDashes(printable, catalog, header)
import matlab.unittest.internal.diagnostics.wrapHeader;
printIndentedLine(printable, wrapHeader(catalog.getString(header)));
end

% LocalWords:  unittest mypackage evd
