function display(a)
%DISPLAY Display a categorical array.
%   DISPLAY(A) prints the categorical array A.  DISPLAY is called when
%   a semicolon is not used to terminate a statement.
%
%   See also CATEGORICAL/CATEGORICAL, DISP.

%   Copyright 2006-2013 The MathWorks, Inc. 

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

objectname = inputname(1);
if isempty(objectname)
    objectname = 'ans';
end

if isempty(a)
    if (isLoose), fprintf('\n'); end
    fprintf('%s = \n', objectname);
    if (isLoose), fprintf('\n'); end
    sz = size(a);
    if ismatrix(a)
        classStr = getString(message('MATLAB:categorical:uistrings:EmptyMatrixDisplay',class(a)));
    else
        classStr = getString(message('MATLAB:categorical:uistrings:EmptyArrayDisplay',class(a)));
    end
    sepStr = getString(message('MATLAB:categorical:uistrings:DisplaySizeSeparator'));
    fprintf('   %s %d',classStr,sz(1));
    fprintf([sepStr '%d'],sz(2:end));
    fprintf('\n');
    if (isLoose), fprintf('\n'); end
elseif ismatrix(a)
    if (isLoose), fprintf('\n'); end
    fprintf('%s = \n', objectname);
    if (isLoose), fprintf('\n'); end
    disp(a)
else
    % Let the disp method do the real work, then look for the page headers,
    % things like '(:,:,1) =', and replace them with 'objectname(:,:,1) ='
    s = evalc('disp(a)');
    s = regexprep(s,'\([0-9:,]+\) =', [objectname '$0']);
    fprintf('%s',s);
end
