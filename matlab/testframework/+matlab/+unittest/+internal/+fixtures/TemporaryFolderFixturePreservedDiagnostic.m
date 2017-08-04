classdef TemporaryFolderFixturePreservedDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % This class is undocumented.
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Folder;
    end
    
    methods
        function diag = TemporaryFolderFixturePreservedDiagnostic(folder)
            diag.Folder = folder;
        end
        
        function diagnose(diag)
            header = getString(message('MATLAB:unittest:TemporaryFolderFixture:FolderPreserved'));
            diag.DiagnosticResult = sprintf('%s\n%s\n', header, diag.Folder);
        end
    end
end