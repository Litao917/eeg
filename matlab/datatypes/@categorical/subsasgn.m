function a = subsasgn(a,s,b)
%SUBSASGN Subscripted assignment for a categorical array.
%     A = SUBSASGN(A,S,B) is called for the syntax A(I)=B.  S is a structure
%     array with the fields:
%         type -- string containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array or string containing the actual subscripts.
%
%   See also CATEGORICAL/CATEGORICAL, SUBSREF.

%   Copyright 2006-2013 The MathWorks, Inc.

import matlab.internal.tableUtils.isStrings

creating = isequal(a,[]);
if creating
    a = b; % preserve the subclass
    a.codes = zeros(0,categorical.codesClass);
end

anames = a.categoryNames;

switch s(1).type
case '()'
    % Make sure nothing follows the () subscript
    if ~isscalar(s)
        error(message('MATLAB:categorical:InvalidSubscripting'));
    end
    
    if builtin('_isEmptySqrBrktLiteral',b)
        a.codes(s.subs{:}) = [];
        
    else
        if isa(b,'categorical')
            % If b is categorical, its ordinalness has to match a, and if they are
            % ordinal, their categories have to match.
            if a.isOrdinal ~= b.isOrdinal
                error(message('MATLAB:categorical:OrdinalMismatchAssign'));
            elseif isordinal(a) && ~isequal(b.categoryNames,a.categoryNames)
                error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
            end
            bcodes = b.codes;
            bnames = b.categoryNames;
        elseif isStrings(b)
            [bcodes,bnames] = strings2codes(b);
        else
            error(message('MATLAB:categorical:InvalidRHS', class(a)));
        end
        
        try
            [bcodes,anamesNew] = convertCodesLocal(bcodes,bnames,anames,a.isProtected);
        catch me
            if a.isProtected && strcmp(me.identifier,'MATLAB:categorical:ProtectedForCombination')
                names = setdiff(bnames,anames);
                error(message('MATLAB:categorical:ProtectedForAssign',names{1}));
            else
                rethrow(me);
            end
        end
        a.codes(s.subs{:}) = bcodes;
        a.categoryNames = anamesNew;
    end
    
case '{}'
    error(message('MATLAB:categorical:CellAssignmentNotAllowed'))
    
case '.'
    error(message('MATLAB:categorical:FieldAssignmentNotAllowed'))
end


function [bcodes,anames] = convertCodesLocal(bcodes,bnames,anames,aprotect)
anames = anames(:);

if ischar(bnames)
    ia = find(strcmp(bnames,anames));
    if isempty(ia);
        if aprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
        anames = [anames; bnames];
        bcodes = length(anames);
    else
        bcodes = ia;
    end

else % iscellstr(bnames)
    bnames = bnames(:);
    
    % Get a's codes for b's data.  Any elements of b that do not match a category of
    % a are assigned codes beyond a's range.

    [tf,ia] = ismember(bnames,anames);
    b2a = zeros(1,length(bnames)+1,categorical.codesClass);
    b2a(2:end) = ia;

    % b has more categories than a
    if ~all(tf)
        % Find b's categories that are actually being newly assigned into a
        newlyAssigned(unique(bcodes(bcodes>0))) = true;
        newlyAssigned(tf) = false;

        % If a is protected we can't assign new categories.
        if any(newlyAssigned)
            if aprotect
                throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
            end
            ib = find(newlyAssigned);
            b2a(ib+1) = length(anames) + (1:length(ib));
            if length(b2a)-1 > categorical.maxNumCategories
                throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
            end
            anames = [anames; bnames(ib)];
        end
    end
    bcodes(:) = b2a(bcodes+1);
end
