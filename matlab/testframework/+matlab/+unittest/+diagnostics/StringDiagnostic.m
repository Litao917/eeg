classdef StringDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % StringDiagnostic - A simple string diagnostic.
    %
    %   The StringDiagnostic class provides a diagnostic result using the text
    %   provided. It is a means to provide quick and easy diagnostic
    %   information when that information is known at the time of construction.
    %
    %   As a convenience (and performance improvement) when using
    %   matlab.unittest qualifications, a string can itself be directly
    %   supplied as a test diagnostic, and a StringDiagnostic will be created
    %   automatically.
    %
    %   StringDiagnostic properties:
    %       DiagnosticResult - Simple value of string diagnostic
    %
    %   StringDiagnostic methods:
    %       StringDiagnostic - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.diagnostics.StringDiagnostic;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Create a StringDiagnostic only upon failure
    %       testCase.assertThat(1, IsEqualTo(2), ...
    %           'actual was supposed to be equal to expected' );
    %
    %       % Provide a StringDiagnostic directly
    %       testCase.assertThat(1, IsEqualTo(2), ...
    %           StringDiagnostic('actual was supposed to be equal to expected') );
    %
    %   See also
    %       FunctionHandleDiagnostic
    %
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    
    methods
        function diag = StringDiagnostic(value)
            % StringDiagnostic - Class constructor
            %
            %   StringDiagnostic(VALUE) creates a new StringDiagnostic instance using
            %   the VALUE provided.
            %
            %   Examples:
            %
            %       import matlab.unittest.diagnostics.StringDiagnostic;
            %
            %       StringDiagnostic('Diagnostic text');
            %       StringDiagnostic(sprintf('This text is first created using %s', 'sprintf'));
            %
            validateattributes(value, {'char'}, {}, '', 'value');
            diag.DiagnosticResult = value;
        end
        function diagnose(~)
        end
    end
    
end