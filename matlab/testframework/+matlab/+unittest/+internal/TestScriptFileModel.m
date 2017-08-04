classdef(Hidden) TestScriptFileModel < matlab.unittest.internal.TestScriptModel
    % The TestScriptFileModel utilizes static analysis in order to retrieve
    % the test content contained inside test code sections.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties(SetAccess = immutable)
        Filename
        FileContents
    end
    
    properties(GetAccess=private, SetAccess=immutable)
        ParseTree
    end
    
    properties(Dependent, SetAccess=immutable)
        TestCellContent
        TestCellNames
        ScriptName
    end
    
                    
    
    methods(Static)
        
        function [tf, tree] = isScript(filename)
            import matlab.unittest.internal.TestScriptFileModel;
            tf = false;
            tree = mtree.empty;
            
            try
                tree = TestScriptFileModel.parseTree(filename);
            catch ex %#ok<NASGU>
                % The contract is that any file in which a valid mtree
                % cannot be constructed is not a valid test case script.
                % All test cases scripts must be subject to static analysis.
                % Ignoring the MException ID in this case is a considered
                % deviation from typical best programming practices.
                return
            end
            if isnull(tree)
                return
            end
            
            % classes aren't scripts
            if tree.anykind('CLASSDEF')
                return
            end
            
            %functions aren't scripts
            if tree.anykind('FUNCTION')
                return
            end
            
            tf = true;
            
        end
        
        
        function tree = parseTree(filename)
            tree = mtree(filename, '-file', '-cell');
        end
    end
    
    methods
        
        function model = TestScriptFileModel(filename, parseTree)
            import matlab.unittest.internal.TestScriptFileModel
            model.Filename = filename;
            model.FileContents = fileread(filename);
            if nargin < 2
                parseTree = TestScriptFileModel.parseTree(filename);
            end
            model.ParseTree = parseTree;
        end
        function scriptName = get.ScriptName(model)
            [~, scriptName] = fileparts(model.Filename);
        end
        function content = get.TestCellContent(model)
            import matlab.desktop.editor.textToLines;
            import matlab.desktop.editor.linesToText;
            
            allCode = textToLines(model.FileContents);
            
            startLines = model.locateCodeSections;
            endLines = [startLines(2:end)-1, numel(allCode)];
            
            numSections = numel(startLines);
            content = cell(numSections,1);
            for idx = 1:numSections
                thisCell = allCode(startLines(idx):endLines(idx));
                content{idx} = linesToText(thisCell);
            end
        end
        function names = get.TestCellNames(model)
            import matlab.desktop.editor.textToLines;
            import matlab.lang.makeValidName;
            import matlab.lang.makeUniqueStrings;
            
            allCode = textToLines(model.FileContents);
            startLineCode = allCode(model.locateCodeSections);
            startLineCode = regexprep(startLineCode, '^\s*(%{2}|.*)\s*', '');
            names = makeUniqueStrings(makeValidName(startLineCode),{}, namelengthmax);            
        end
    end
    methods(Hidden)
        
        function locations = locateCodeSections(model)
            
            tree = model.ParseTree;
            
            
            locations = 1; % There is always at least one
            thisNode = tree.select(1);
            while ~isempty(thisNode)
                if (thisNode.iskind('CELLMARK'))
                    line = thisNode.lineno;
                    locations = [locations, line]; %#ok<AGROW>
                end
                thisNode = thisNode.Next;
            end
            locations = unique(locations);
        end
        
                   
    end
    
end