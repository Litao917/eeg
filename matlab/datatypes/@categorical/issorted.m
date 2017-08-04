function t = issorted(a,flag)
%ISSORTED True for sorted categorical array.
%   TF = ISSORTED(A), when A is a categorical vector, returns logical 1 (true)
%   if the elements of A are in sorted order (in other words, if A and SORT(A)
%   are identical) and logical 0 (false) if not.
%
%   TF = ISSORTED(A,'rows'), when A is a categorical matrix, returns logical 1
%   (true) if the rows of A are in sorted order (if A and SORTROWS(A) are
%   identical) and logical 0 (false) if not.
%
%   If A is sorted, undefined elements appear at the end.
%
%   See also SORT, SORTROWS.

%   Copyright 2006-2013 The MathWorks, Inc. 

if nargin > 1 && ~ischar(flag)
    error(message('MATLAB:categorical:issorted:UnknownFlag'));
end

acodes = a.codes;
% Set the code value for undefined elements to the largest integer to make
% issorted happy if they are at the end.
tmpCode = categorical.invalidCode; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        t = issorted(acodes);
    else
        t = issorted(acodes,flag);
    end
catch ME
    throw(ME);
end
