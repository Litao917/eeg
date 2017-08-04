classdef(Hidden) TestScriptModel
    % The TestScriptModel an interface for defining models of test scripts
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties(Abstract, SetAccess=immutable)
        ScriptName
        TestCellNames
        TestCellContent
    end
end