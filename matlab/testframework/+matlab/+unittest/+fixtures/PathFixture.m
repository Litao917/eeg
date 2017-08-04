classdef PathFixture < matlab.unittest.fixtures.Fixture
    % PathFixture - Fixture for adding a folder to the MATLAB path.
    %
    %   PathFixture(FOLDER) constructs a fixture for adding FOLDER to the
    %   MATLAB path. When the fixture is set up, FOLDER is added to the path.
    %   When the fixture is torn down, the MATLAB path is restored to it
    %   previous state.
    %
    %   PathFixture methods:
    %       PathFixture - Class constructor.
    %
    %   PathFixture properties:
    %       Folder - String containing the folder to be added to the path.
    %
    %   Example:
    %       classdef (SharedTestFixtures={matlab.unittest.fixtures.PathFixture('helperFiles')}) ...
    %               testFoo < matlab.unittest.TestCase
    %           methods(Test)
    %               function test1(testCase)
    %                   % Test for Foo
    %               end
    %           end
    %       end
    %
    %   See also: CurrentFolderFixture
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % Folder - String containing the folder to be added to the path.
        %
        %   The Folder property is a string representing the absolute path to the
        %   folder that is added to the MATLAB path when the fixture is set up.
        Folder
    end
    
    properties(Access=private)
        StartPath
    end
    
    methods
        function fixture = PathFixture(folder)
            % PathFixture - Class constructor.
            %
            %   FIXTURE = PathFixture(FOLDER) constructs a fixture for adding FOLDER to
            %   the MATLAB path. FOLDER may refer to a relative or absolute path.
            
            validateattributes(folder,{'char'}, {'row'}, '', 'folder');
            
            [status, folderInfo] = fileattrib(folder);
            if ~(status && folderInfo.directory)
                error(message('MATLAB:unittest:PathFixture:FolderDoesNotExist', folder));
            end
            
            fixture.Folder = folderInfo.Name;
        end
        
        function setup(fixture)
            fixture.StartPath = addpath(fixture.Folder);
            
            fixture.SetupDescription = getString(message('MATLAB:unittest:PathFixture:SetupDescription', ...
                fixture.Folder));
        end
        
        function teardown(fixture)
            path(fixture.StartPath);
            
            fixture.TeardownDescription = getString(message('MATLAB:unittest:PathFixture:TeardownDescription'));
        end
    end
    
    methods (Hidden, Access=protected)
        function bool = isCompatible(fixture, other)
            bool = strcmp(fixture.Folder, other.Folder);
        end
    end
end