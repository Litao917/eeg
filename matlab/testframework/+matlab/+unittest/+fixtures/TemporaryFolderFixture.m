classdef TemporaryFolderFixture < matlab.unittest.fixtures.Fixture & ...
                                  matlab.unittest.internal.fixtures.PreservingOnFailureMixin & ...
                                  matlab.unittest.internal.fixtures.WithSuffixMixin
    % TemporaryFolderFixture - Create a temporary folder.
    %
    %   The TemporaryFolderFixture test fixture is used to create a temporary
    %   folder. When the fixture is set up, it creates a folder. Typically, the
    %   fixture deletes the folder and all its contents when torn down. Before
    %   deleting the folder, the fixture clears from memory the definitions of
    %   any MATLAB-files, P-files, and MEX-files that are defined in the
    %   temporary folder.
    %
    %   When 'PreservingOnFailure' is specified as true and a failure
    %   (verification, assertion, or fatal assertion qualification failure or
    %   uncaught error) occurs in the test using the fixture, then a message is
    %   printed to the Command Window and the folder is not deleted. Preserving
    %   the folder and its contents may aid in investigation of the cause of
    %   the test failure.
    %
    %   The name of the folder can be customized by specifying the 'WithSuffix'
    %   parameter along with a string. The specified string is appended to the
    %   end of the name of the folder that is created.
    %
    %
    %   TemporaryFolderFixture methods:
    %       TemporaryFolderFixture - Class constructor.
    %
    %   TemporaryFolderFixture properties:
    %       Folder            - Created folder.
    %       PreserveOnFailure - Boolean that specifies whether the folder is deleted after a failure.
    %       Suffix            - String appended to the name of the folder.
    %
    %   Example:
    %       classdef testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   import matlab.unittest.fixtures.TemporaryFolderFixture;
    %                   import matlab.unittest.fixtures.CurrentFolderFixture;
    %
    %                   % Create a temporary folder and make it the current working folder.
    %                   tempFolder = testCase.applyFixture(TemporaryFolderFixture);
    %                   testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
    %
    %                   % The test can now write files to the current working folder.
    %               end
    %           end
    %       end
    %
    %   See also: PathFixture, CurrentFolderFixture
    
    % Copyright 2013 The MathWorks, Inc.
    
    
    properties
        % Folder - Created folder.
        %
        %   The Folder property is a string that specifies the absolute path of the
        %   folder created by the fixture.
        Folder = '';
    end
    
    properties (Access=private)
        TestFailed = false;
    end
    
    properties (Hidden, Constant, Access=protected)
        % DefaultSuffix - The suffix that will be used by default
        %   when the 'WithSuffix' parameter is not specified by the user.
        DefaultSuffix = '';
    end
    
    
    methods
        function fixture = TemporaryFolderFixture(varargin)
            % TemporaryFolderFixture - Class constructor.
            %
            %   FIXTURE = TemporaryFolderFixture creates a temporary folder
            %   fixture instance and returns it as FIXTURE.
            
            fixture = fixture.parse(varargin{:});
        end
        
        function setup(fixture)
            fixture.Folder = [tempname, fixture.Suffix];
            mkdir(fixture.Folder);
            
            fixture.SetupDescription = getString(message( ...
                'MATLAB:unittest:TemporaryFolderFixture:SetupDescription', fixture.Folder));
        end
        
        function teardown(fixture)
            import matlab.unittest.Verbosity;
            import matlab.unittest.internal.fixtures.TemporaryFolderFixturePreservedDiagnostic;
            
            if fixture.PreserveOnFailure && fixture.TestFailed
                fixture.log(Verbosity.Terse, TemporaryFolderFixturePreservedDiagnostic(fixture.Folder));
                return;
            end
            
            % Clear the items in the temporary folder that are in memory.
            [mpInMem, mexInMem] = inmem('-completenames');
            inMemInFolder = [mpInMem; mexInMem];
            folder = [fixture.Folder, filesep];
            
            if ispc
                inMemInFolder = inMemInFolder(strncmpi(inMemInFolder, folder, numel(folder)));
            else
                inMemInFolder = inMemInFolder(strncmp(inMemInFolder, folder, numel(folder)));
            end
            
            cellfun(@clear, inMemInFolder);
            
            % Remove the folder along with its contents.
            [status, msg] = rmdir(fixture.Folder, 's');
            if ~status
                warning(message('MATLAB:unittest:TemporaryFolderFixture:DeletionFailed', ...
                    fixture.Folder, msg));
            end
            
            fixture.TeardownDescription = getString(message( ...
                'MATLAB:unittest:TemporaryFolderFixture:TeardownDescription', fixture.Folder));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = isequal(fixture.ParsingResults, other.ParsingResults);
        end
    end
    
    methods (Hidden)
        function applyTestCase(fixture, testCase)
            testCase.addlistener('VerificationFailed'  , @(~,~)fixture.setFailed);
            testCase.addlistener('AssertionFailed'     , @(~,~)fixture.setFailed);
            testCase.addlistener('FatalAssertionFailed', @(~,~)fixture.setFailed);
            testCase.addlistener('ExceptionThrown'     , @(~,~)fixture.setFailed);
        end
    end
    
    methods (Access=private)
        function setFailed(fixture)
            fixture.TestFailed = true;
        end
    end
end

% LocalWords:  completenames
