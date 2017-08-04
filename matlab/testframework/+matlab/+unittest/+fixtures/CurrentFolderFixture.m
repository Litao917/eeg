classdef CurrentFolderFixture < matlab.unittest.fixtures.Fixture
    % CurrentFolderFixture - Fixture for changing the current working folder.
    %
    %   CurrentFolderFixture(FOLDER) constructs a fixture for changing the
    %   current working folder to FOLDER. When the fixture is set up, the
    %   working folder is changed to FOLDER. When the fixture is torn down,
    %   the working folder is restored to its previous state.
    %
    %   CurrentFolderFixture methods:
    %       CurrentFolderFixture - Class constructor.
    %
    %   CurrentFolderFixture properties:
    %       Folder - String containing the folder to make the current working folder.
    %
    %   Example:
    %       classdef (SharedTestFixtures={matlab.unittest.fixtures.CurrentFolderFixture('helperFiles')}) ...
    %               testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   % Test for Foo
    %               end
    %           end
    %       end
    %
    %   See also: PathFixture
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % Folder - String containing the folder to make the current working folder.
        %
        %   The Folder property is a string representing the absolute path to the
        %   folder that becomes the current working folder when the fixture is set up.
        Folder
    end
    
    properties(Access=private)
        StartFolder = '';
    end
    
    methods
        function fixture = CurrentFolderFixture(folder)
            % CurrentFolderFixture - Class constructor.
            %
            %   FIXTURE = CurrentFolderFixture(FOLDER) constructs a fixture for making
            %   FOLDER the current working folder. FOLDER may refer to a relative or
            %   absolute path.
            
            validateattributes(folder,{'char'},{'row'},'', 'folder');
            
            [status, folderInfo] = fileattrib(folder);
            if ~(status && folderInfo.directory)
                error(message('MATLAB:unittest:CurrentFolderFixture:FolderDoesNotExist', folder));
            end
            
            fixture.Folder = folderInfo.Name;
        end
        
        function setup(fixture)
            fixture.StartFolder = cd(fixture.Folder);
            
            fixture.SetupDescription = getString(message('MATLAB:unittest:CurrentFolderFixture:SetupDescription', ...
                fixture.Folder));
        end
        
        function teardown(fixture)
            cd(fixture.StartFolder);
            
            fixture.TeardownDescription = getString(message('MATLAB:unittest:CurrentFolderFixture:TeardownDescription', ...
                fixture.StartFolder));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = strcmp(fixture.Folder, other.Folder);
        end
    end
end