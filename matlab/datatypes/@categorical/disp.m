function disp(a)
%DISP Display a categorical array.
%   DISP(A) prints the categorical array A without printing the array name.
%   In all other ways it's the same as leaving the semicolon off an
%   expression, except that empty arrays don't display.
%
%   See also CATEGORICAL/CATEGORICAL, DISPLAY.

%   Copyright 2006-2013 The MathWorks, Inc. 

catnames = [categorical.undefLabel; a.categoryNames];
s = evalc('disp(reshape(catnames(a.codes+1),size(a.codes)))');

% Replace quotes around category names with spaces.
s = regexprep(s,['\<\''(' strjoin(fliplr(sort(catnames')),'|') ')\''\>'],' $1 '); %#ok<TRSRT,FLPST>
fprintf('%s',s);
