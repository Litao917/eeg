function [varargout] = getProperty(t,name,createIfEmpty)
%GETPROPERTY Get a table property.

%   Copyright 2012 The MathWorks, Inc.

import matlab.internal.tableUtils.isStrings

if nargin < 3, createIfEmpty = false; end

% We may be given a name (when called from get), or a subscript expression
% that starts with a '.name' subscript (when called from subsref).  Get the
% name and validate it in any case.
if isstruct(name)
    s = name;
    if s(1).type == '.'
        name = s(1).subs;
    else
        error(message('MATLAB:table:InvalidSubscript'));
    end
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the get method;
% require exact match if it is via subsref
name = matchPropertyName(name,haveSubscript);

% Get the property out of the table.  Some properties need special handling
% when empty:  create either a non-empty default version or a "canonical" 0x0
% cell array (subscripting can sometimes make them 1x0 or 0x1), depending on
% what the caller asks for.
switch name
case 'RowNames'
    p = t.rownames;
    if isempty(p)
        if createIfEmpty
            p = matlab.internal.table.dfltRowNames(1:t.nrows);
        end
    end
case 'VariableNames'
    p = t.varnames;
    % varnames are "always there", so leave them 1x0 when empty
case 'DimensionNames'
    p = t.props.DimensionNames;
case {'VariableDescriptions' 'VariableUnits'}
    p = t.props.(name);
    if isempty(p)
        if createIfEmpty
            p = repmat({''},1,t.nvars);
        end
    end
case 'Description'
    p = t.props.Description;
case 'UserData'
    p = t.props.UserData;
end

if haveSubscript && ~isscalar(s)
    % If there's just one subscript and it's a name, translate it to an index if
    % appropriate.
    if isscalar(s(2).subs) % just one subscript
        sub = s(2).subs{1};
        if isStrings(sub) % a name, names, or colon
            switch name
            case {'VariableNames' 'VariableDescriptions' 'VariableUnits'}
                s(2).subs{1} = getVarIndices(t,sub);
            case 'RowNames'
                s(2).subs{1} = getRowIndices(t,sub);
            case 'DimensionNames'
                s(2).subs{1} = getDimIndices(t,sub);
            end
        end
    end
    % If there's cascaded subscripting into the property, let the property's
    % subsasgn handle the reference.  This may return a comma-separated list,
    % so ask for and assign to as many outputs as we're given.  If there's no
    % LHS to the original expression (nargout==0), this only assigns one
    % output and drops everything else in the CSL.
    [varargout{1:nargout}] = subsref(p,s(2:end));
else
    % If there's no cascaded subscripting, only ever assign the property itself.
    varargout{1} = p;
end
