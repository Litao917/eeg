function c = cellstr(s)
%CELLSTR Create cell array of strings from character array.
%   C = CELLSTR(S) places each row of the character array S into
%   separate cells of C.
%
%   Use CHAR to convert back.
%
%   Another way to create a cell array of strings is by using the curly
%   braces:
%      C = {'hello' 'yes' 'no' 'goodbye'};
%
%   See also STRINGS, CHAR, ISCELLSTR.

%   Copyright 1984-2013 The MathWorks, Inc.

if ischar(s)
    if isempty(s)
        c = {''};
    elseif ~ismatrix(s)
        error(message('MATLAB:cellstr:InputShape'))
    else
        numrows = size(s,1);
        c = cell(numrows,1);
        for i = 1:numrows
            c{i} = s(i,:);
        end
        c = deblank(c);
    end
elseif iscellstr(s)
    c = s;
else
    error(message('MATLAB:cellstr:InputClass'))
end
