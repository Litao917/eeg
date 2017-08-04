function opendoc(file)
%OPENDOC Opens a Microsoft Word file.

% Copyright 1984-2007 The MathWorks, Inc.

if ispc
    try
        winopen(file)
    catch exception %#ok
        edit(file)
    end
else
    edit(file)
end