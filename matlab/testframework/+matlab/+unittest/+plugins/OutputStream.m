classdef OutputStream < handle
    %OutputStream - Interface that determines where to send text output.
    %   The OutputStream interface is an abstract interface class that can be
    %   used as a base class to specify where text output is to be sent and how
    %   it is to be handled. To create a custom stream a print method must be
    %   implemented which correctly handles the formatted text information
    %   passed to it. Many text oriented plugins accept OutputStreams in order
    %   to redirect the text they produce in a configurable manner.
    %
    %   OutputStream methods:
    %       print - Print a string to the OutputStream.
    %
    %   Examples:
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       % Stream Usage (see definition of ToFigure below)
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.plugins.DiagnosticsValidationPlugin;
    %       
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %       
    %       % Create a plugin using custom OutputStream and add it to the runner
    %       plugin = DiagnosticsValidationPlugin(ToFigure);
    %       runner.addPlugin(plugin);
    %       
    %       % When you run the suite normal text output is sent to the command window
    %       % while the DiagnosticsValidationPlugin output is directed to a figure.
    %       runner.run(suite);
    %
    %
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       % Stream definition
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       classdef ToFigure < matlab.unittest.plugins.OutputStream
    %           %ToFigure - An example OutputStream
    %           %   This example creates a ToFigure OutputStream to demonstrate how text
    %           %   produced by a plugin can be redirected to a different location than the
    %           %   command window.
    %           %
    %           
    %           
    %           properties(SetAccess=private)
    %               %Figure - the figure which receives and displays text output.
    %               Figure
    %           end
    %       
    %           properties(Dependent, Access=private)
    %               %CurrentText - the current text in the listbox
    %               %
    %               %   CurrentText is a dependent property which can be used to easily access
    %               %   and set the current text in the list box.
    %               CurrentText
    %           end
    %           
    %           properties(Access=private)
    %               %ListBox - the handle to the listbox used to display text.
    %               ListBox
    %           end
    %       
    %           
    %           methods
    %               function print(stream, formatSpec, varargin)
    %                   
    %                   if isempty(stream.Figure) || ~ishghandle(stream.Figure)
    %                       % Create the figure if needed.
    %                       stream.createFigure;
    %                   end
    %                   
    %                   newStr = sprintf(formatSpec, varargin{:});
    %                   str = sprintf('%s%s', stream.CurrentText, newStr);
    %                   stream.CurrentText = str;
    %                   
    %               end
    %               function str = get.CurrentText(stream)
    %                   % Get the text from the list box on the figure.
    %                   strCell = cellstr(get(stream.ListBox, 'String'));
    %                   str = strjoin(strCell','\n');
    %               end
    %               function set.CurrentText(stream, str)
    %                   % Set the text onto the list box on the figure.
    %                   strCell = strsplit(str, '\n');
    %                   set(stream.ListBox, 'String', strCell, 'ListBoxTop',numel(strCell));
    %                   drawnow;
    %               end
    %           end
    %           
    %           methods(Access=private)
    %               function createFigure(stream)
    %                   % Create the figure and 
    %                   stream.Figure = figure;
    %                   stream.ListBox = uicontrol( ...
    %                       'Parent',   stream.Figure, ...
    %                       'Style',    'listbox', ...
    %                       'Units',    'normalized', ...
    %                       'Position',	[.05 .05 .9 .9], ...
    %                       'Max',      2, ...
    %                       'FontSize', 13, ...
    %                       'HorizontalAlignment', 'left');
    %               end
    %       
    %           end
    %           
    %       end
    %
    %   See also: ToFile, ToStandardOutput, fprintf, matlab.unittest.plugins
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    methods(Abstract)
        %print Write formatted data to an output stream.   
        %   print(STREAM, FORMAT, A, ...) applies the FORMAT to all elements of
        %   array A and any additional array arguments in column order, and sends
        %   the data to the output stream.
        %
        %   See also; fprintf, sprintf
        print(stream, format, varargin);
    end
end




% LocalWords:  mypackage strsplit
