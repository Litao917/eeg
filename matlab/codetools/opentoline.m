function opentoline(fileName, lineNumber, columnNumber)
%OPENTOLINE Open to specified line in function file in Editor
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   OPENTOLINE(FILENAME, LINENUMBER, COLUMN)
%   LINENUMBER the line to scroll to in the Editor. The absolute value of
%   this argument will be used.
%   COLUMN argument is optional.  If it is not present, the whole line 
%   will be selected.
%
%   See also matlab.desktop.editor.openAndGoToLine, matlab.desktop.editor.openAndGoToFunction.

%   Copyright 1984-2010 The MathWorks, Inc.

%% complete the path if it is not absolute
javaFile = java.io.File(fileName);
if ~javaFile.isAbsolute
    %resolve the filename if a partial path is provided.
    fileName = char(com.mathworks.util.FileUtils.absolutePathname(fileName));
end
lineNumber = abs(lineNumber); % dbstack uses negative numbers for "after"

%% open the editor
if nargin == 2
    %just go to a particular line, will silently fail if fileName does not exist
    matlab.desktop.editor.openAndGoToLine(fileName, lineNumber);
else
    %go to a line and a column, if fileName exists
    editorObj = matlab.desktop.editor.openDocument(fileName);
    if (~isempty(editorObj))
        editorObj.goToPositionInLine(lineNumber, columnNumber);
    end
end

