classdef SuppressedWarningsFixture < matlab.unittest.fixtures.Fixture
    % SuppressedWarningsFixture - Suppress the display of one or more warnings.
    %
    %   When set up, the SuppressedWarningsFixture test fixture disables
    %   one or more warnings. When torn down, the fixture restores the
    %   states of the warnings to their previous values.
    %
    %   SuppressedWarningsFixture methods:
    %       SuppressedWarningsFixture - Class constructor.
    %
    %   SuppressedWarningsFixture properties:
    %       Warnings - Cell array of warning identifiers.
    %
    %   Example:
    %       classdef (SharedTestFixtures={matlab.unittest.fixtures.SuppressedWarningsFixture('Foo:ExpectedWarning')}) ...
    %               testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   % Test for Foo
    %               end
    %           end
    %       end
    %
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    properties (SetAccess=immutable)
        % Warnings - Cell array of warning identifiers.
        %   
        %   The Warnings property contains a cell array of warning identifiers
        %   describing the warnings that are disabled when the fixture is set up.
        Warnings
    end
    
    properties (Dependent, Access=private)
        IndentedWarningListString
    end
    
    properties (Access=private)
        InitialWarningStates
    end
    
    
    methods
        function fixture = SuppressedWarningsFixture(warnings)
            % SuppressedWarningsFixture - Class constructor.
            %
            %   FIXTURE = matlab.unittest.fixtures.SuppressedWarningsFixture(WARNINGS)
            %   creates a fixture that, when set up, disables the warnings with the
            %   specified identifiers. WARNINGS is specified as either a single warning
            %   ID string or as a cell array of warning ID strings.
            
            fixture.Warnings = cellstr(warnings);
        end
        
        function setup(fixture)
            fixture.InitialWarningStates = ...
                cellfun(@(id)warning('off',id), fixture.Warnings);
            
            setupHeader = getString(message('MATLAB:unittest:SuppressedWarningsFixture:SetupDescription'));
            fixture.SetupDescription = sprintf('%s\n%s', setupHeader, fixture.IndentedWarningListString);
        end
        
        function teardown(fixture)
            warning(fixture.InitialWarningStates);
            
            teardownHeader = getString(message('MATLAB:unittest:SuppressedWarningsFixture:TeardownDescription'));
            fixture.TeardownDescription = sprintf('%s\n%s', teardownHeader, fixture.IndentedWarningListString);
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = isempty(setdiff(fixture.Warnings, other.Warnings));
        end
    end
    
    methods
        function list = get.IndentedWarningListString(fixture)
            import matlab.unittest.internal.diagnostics.indent;
            
            warnings = strjoin(fixture.Warnings, '\n');
            list = indent(warnings, '    ');
        end
    end
end