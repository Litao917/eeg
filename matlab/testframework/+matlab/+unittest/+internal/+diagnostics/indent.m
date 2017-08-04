% This function is undocumented.

%  Copyright 2010-2012 The MathWorks, Inc.

function str = indent(str, indention)
str = sprintf('%s%s', indention, regexprep(str, '\n',['\n', indention]));
end