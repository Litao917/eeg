function [varargout] = subsref(a,s)
%SUBSREF Subscripted reference for a categorical array.
%     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
%     with the fields:
%         type -- string containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array or string containing the actual subscripts.
%
%   See also CATEGORICAL/CATEGORICAL, SUBSASGN.

%   Copyright 2006-2013 The MathWorks, Inc.

switch s(1).type
case '()'
    % Make sure nothing follows the () subscript
    if ~isscalar(s)
        error(message('MATLAB:categorical:InvalidSubscripting'));
    end
    b = a;
    b.codes = a.codes(s.subs{:});
    varargout{1} = b;
case '{}'
    error(message('MATLAB:categorical:CellReferenceNotAllowed'))
case '.'
    error(message('MATLAB:categorical:FieldReferenceNotAllowed'))
end
