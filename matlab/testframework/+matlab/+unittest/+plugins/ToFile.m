classdef ToFile < matlab.unittest.plugins.OutputStream
    %ToFile  Write text output to a file.
    %   ToFile is an OutputStream which sends text to a file. Whenever text is
    %   printed to this stream it opens the file, appends the text to the end
    %   of the file, and closes it.
    %
    %   ToFile properties:
    %       Filename - Name of the file to which text is written.
    %
    %   ToFile methods:
    %       ToFile - Create an output stream to a file.
    %
    %   Examples:
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.TAPPlugin;
    %       import matlab.unittest.plugins.ToFile;
    %
    %       % Create a TestSuite array
    %       suite   = TestSuite.fromClass(?mypackage.MyTestClass);
    %       % Create a test runner
    %       runner = TestRunner.withTextOutput;
    %
    %       % Create a TAPPlugin, redirecting its output to a file
    %       filename = 'MyTapOutput.tap';
    %       plugin = TAPPlugin.producingOriginalFormat(ToFile(filename));
    %       
    %       % Add the plugin to the TestRunner and run the suite
    %       runner.addPlugin(plugin);
    %       result = runner.run(suite);
    %
    %       % Observe the TAP output written to the file
    %       disp(fileread(filename));
    %
    %   See also: fprintf, OutputStream, matlab.unittest.plugins
    
    
    properties(SetAccess = private)
        %Filename - Name of the file to which text is written.
        %   The Filename property contains the name of the file to which text is
        %   written. The print method opens this file for writing, appends text
        %   to its contents, and closes it.
        Filename
    end
    
    methods
        function stream = ToFile(filename)
            %ToFile - Create an output stream to a file
            %   STREAM = ToFile(FILENAME) creates an OutputStream that writes text
            %   output to FILENAME. FILENAME is a string containing the name of the
            %   file to be written to.
            stream.Filename = filename;
        end
        function print(plugin, formatStr, varargin)
            [fid, msg] = fopen(plugin.Filename, 'a');
            assert(fid > 0, msg);           
            cl = onCleanup(@() fclose(fid));
            fprintf(fid, formatStr, varargin{:});
        end
        
        function stream = set.Filename(stream, filename)
            validateattributes(filename, {'char'}, {'row'},'','filename');
            stream.Filename = filename;
        end
    end
end




% LocalWords:  mypackage fid
