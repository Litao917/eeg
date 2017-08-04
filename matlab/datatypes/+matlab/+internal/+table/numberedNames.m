function names = numberedNames(prefix,numbers,oneName)
%NUMBEREDNAMES Append numeric suffix to a common base string.

%   Copyright 2012 The MathWorks, Inc.

if nargin < 3 || ~oneName % return cellstr
    if isempty(numbers)
        names = cell(1,0);
    else
        names = strcat({prefix},num2str(numbers(:),'%-d'))';
    end
else % return one string
    names = strcat(prefix,num2str(numbers,'%-d'));
end
