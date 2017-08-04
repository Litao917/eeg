function varargout = setdiff(varargin)
%SETDIFF Set difference.
%   C = SETDIFF(A,B) for vectors A and B, returns the values in A that 
%   are not in B with no repetitions. C will be sorted.
%
%   C = SETDIFF(A,B,'rows') for matrices A and B with the same number of
%   columns, returns the rows from A that are not in B. The rows of the
%   matrix C will be in sorted order.
%
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that
%   C = A(IA). If there are repeated values in A that are not in B, then
%   the index of the first occurrence of each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows') also returns an index vector IA such that
%   C = A(IA,:).
%
%   [C,IA] = SETDIFF(A,B,'stable') for arrays A and B, returns the values
%   of C in the order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'sorted') returns the values of C in sorted order.
%   If A is a row vector, then C will be a row vector as well, otherwise C
%   will be a column vector. IA is a column vector. If there are repeated
%   values in A that are not in B, then the index of the first occurrence of
%   each repeated value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A.
%   [C,IA] = SETDIFF(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
%
%   The behavior of SETDIFF has changed.  This includes:
%     -	occurrence of indices in IA switched from last to first
%     -	orientation of vector C
%     -	IA will always be a column index vector
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA] = SETDIFF(A,B,'legacy')
%      [C,IA] = SETDIFF(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%
%      [c1,ia1] = setdiff(a,b)
%      % returns
%      c1 = [2 5 6 7 8 9]
%      ia1 = [20 17 14 11 7 1]'
%
%      [c2,ia2] = setdiff(a,b,'stable')
%      % returns
%      c2 = [9 8 7 6 5 2]
%      ia2 = [1 7 11 14 17 20]'
%
%      c = setdiff([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [2 NaN]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER, SORT, SORTROWS.

%   Copyright 1984-2013 The MathWorks, Inc.

% Determine the number of outputs requested.
if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end

narginchk(2,4);
nrhs = nargin;
if nrhs == 2
    [varargout{1:nlhs}] = setdiffR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % setdiff(A,B, ['rows'], ['legacy'/'R2012a']),
    % setdiff(A,B, ['rows'], ['sorted'/'stable']),
    % where the position of 'rows' and 'sorted'/'stable' may be reversed
    nflagvals = 5;
    flagvals = {'rows' 'sorted' 'stable' 'legacy' 'R2012a'};
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,nflagvals);
    for i = 3:nrhs
        flag = varargin{i};
        foundflag = strcmpi(flag,flagvals);
        if ~any(foundflag)
            if ischar(flag)
                error(message('MATLAB:SETDIFF:UnknownFlag',flag));
            else
                error(message('MATLAB:SETDIFF:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:SETDIFF:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:SETDIFF:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:SETDIFF:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:SETDIFF:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:SETDIFF:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:SETDIFF:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = setdiffR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = setdiffR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = setdifflegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = setdiffR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia] = setdifflegacy(a,b,isrows)
% 'legacy' flag implementation

if nargin==3 && isrows
    flag = 'rows';
else
    isrows = 0;
    flag = [];
end

rowsA = size(a,1);
colsA = size(a,2);
rowsB = size(b,1);
colsB = size(b,2);

rowvec = ~((rowsA > 1 && colsB <= 1) || (rowsB > 1 && colsA <= 1) || isrows);

nOut = nargout;

if ~(isa(a,'opaque') || isa(b,'opaque')) 
    
    if isempty(flag)
        
        numelA = length(a);
        numelB = length(b);
        
        if numel(a)~=numelA || numel(b)~=numelB
            error(message('MATLAB:SETDIFF:AandBvectorsOrRowsFlag'));
        end
        
        % Handle empty arrays.
        
        if (numelA == 0)
            % Predefine outputs to be of the correct type.
            c = a([]);
            ia = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = (rowsA==0 && colsA==0) && ...
                ((rowsB==0 && colsB==0) || numelB == 1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
            end
        elseif (numelB == 0)
            % If B is empty, invoke UNIQUE to remove duplicates from A.
            if nOut <= 1
                c = unique(a,'legacy');
            else
                [c,ia] = unique(a,'legacy');
            end
            return
            
            % Handle scalar: one element.  Scalar A done only.
            % Scalar B handled within ISMEMBER and general implementation.
            
        elseif (numelA == 1)
            if ~ismember(a,b,'legacy')
                c = a;
                ia = 1;
            else
                c = [];
                ia = [];
            end
            return
            
            % General handling.
            
        else
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Convert to double arrays, which sort faster than other types.
            
            whichclass = class(a);
            isdouble = strcmp(whichclass,'double');
            
            if ~isdouble
                a = double(a);
            end
             
            if ~isa(b,'double')
                b = double(b);
            end
            
            % Call ISMEMBER to determine list of non-matching elements of A.
            tf = ~(ismember(a,b,'legacy'));
            c = a(tf);
            
            % Call UNIQUE to remove duplicates from list of non-matches.
            if nargout <= 1
                c = unique(c,'legacy');
            else
                [c,ndx] = unique(c,'legacy');
                
                % Find indices by using TF and NDX.
                where = find(tf);
                ia = where(ndx);
            end
            
            % Re-convert to correct output data type using FEVAL.
            if ~isdouble
                c = feval(whichclass,c);
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
            end
        end
        
    else    % 'rows' case
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
                colsA = colsB;
            end
        elseif colsA ~= colsB
            error(message('MATLAB:SETDIFF:AandBColnumAgree'));
        end
        
        % Handle empty arrays
        if rowsA == 0
            c = zeros(rowsA,colsA);
            ia = [];
        elseif colsA == 0 && rowsA > 0
            c = zeros(1,0);
            ia = rowsA;
            % General handling
        else
            % Remove duplicates from A; get indices only if needed
            if nOut > 1
                [a,ia] = unique(a,flag,'legacy');
            else
                a = unique(a,flag,'legacy');
            end
            
            % Create sorted list of unique A and B; want non-matching entries
            [c,ndx] = sortrows([a;b]);
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:) ~= c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            d = any(d,2);
            d(rowsC,1) = 1;   % Final entry always included.
            
            % d = 1 now for any unmatched entry of A or of B.
            n = size(a,1);
            d = d & ndx <= n; % Now find only the ones in A.
            
            c = c(d,:);
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
    end
    
    % Automatically deblank strings
    if ischar(a)
        c = deblank(c);
    end
    
else 
    % Handle objects that cannot be converted to doubles    
    if isempty(flag)
        
        numelA = length(a);
        numelB = length(b);
        
        if numel(a)~=numelA || numel(b)~=numelB
            error(message('MATLAB:SETDIFF:AandBvectorsOrRowsFlag'));
        end
        
        % Handle empty arrays.
        
        if (numelA == 0)
            % Predefine outputs to be of the correct type.
            c = a([]);
            ia = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = (rowsA==0 && colsA==0) && ...
                ((rowsB==0 && colsB==0) || numelB == 1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
            end
        elseif (numelB == 0)
            % If B is empty, invoke UNIQUE to remove duplicates from A.
            if nOut <= 1
                c = unique(a,'legacy');
            else
                [c,ia] = unique(a,'legacy');
            end
            return
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            if nOut > 1
                [a,ia] = unique(a(:),'legacy');
            else
                a = unique(a(:),'legacy');
            end
            
            b = unique(b(:),'legacy');
            
            % Find matching entries
            [c,ndx] = sort([a;b]);
            
            % d indicates the location of matching entries
            d = find(c(1:end-1)==c(2:end));
            
            % Remove all matching entries
            ndx([d;d+1]) = [];
            
            d = ndx <= length(a);     % Values in a that don't match.
            
            c = a(ndx(d));
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
            end
        end
        
    else    % 'rows' case
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
                colsA = colsB;
            end
        elseif colsA ~= colsB
            error(message('MATLAB:SETDIFF:AandBColnumAgree'));
        end
        
        % Handle empty arrays
        if rowsA == 0
            c = zeros(rowsA,colsA);
            ia = [];
        elseif colsA == 0 && rowsA > 0
            c = zeros(1,0);
            ia = rowsA;
            % General handling
        else
            % Remove duplicates from A; get indices only if needed
            if nOut > 1
                [a,ia] = unique(a,flag,'legacy');
            else
                a = unique(a,flag,'legacy');
            end
            
            % Create sorted list of unique A and B; want non-matching entries
            [c,ndx] = sortrows([a;b]);
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:) ~= c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            d = any(d,2);
            d(rowsC,1) = 1;   % Final entry always included.
            
            % d = 1 now for any unmatched entry of A or of B.
            n = size(a,1);
            d = d & ndx <= n; % Now find only the ones in A.
            
            c = c(d,:);
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
    end
    
    % Automatically deblank strings
    if ischar(a)
        c = deblank(c);
    end
end
end

function [c,ia] = setdiffR2012a(a,b,options)
% 'R2012a' flag implementation

% flagvals = {'rows' 'sorted' 'stable'};
if nargin == 2
    byrow = false;
    order = 'sorted';
else
    byrow = (options(1) > 0);
    if options(3) > 0
        order = 'stable';
    else % if options(2) > 0 || sum(options(2:3)) == 0)
        order = 'sorted';
    end
end

% Check that one of A and B is double if A and B are non-homogeneous. Do a
% separate check if A is a heterogeneous object and only allow a B
% that is of the same root class.  
if ~(isa(a,'handle.handle') || isa(b,'handle.handle'))
    if ~strcmpi(class(a),class(b))
        if isa(a,'matlab.mixin.Heterogeneous') && isa(b,'matlab.mixin.Heterogeneous')
            rootClassA = meta.internal.findHeterogeneousRootClass(a);
            if isempty(rootClassA) || ~isa(b,rootClassA.Name)
                error(message('MATLAB:SETDIFF:InvalidInputsDataType',class(a),class(b)));
            end
        elseif ~(strcmpi(class(a),'double') || strcmpi(class(b),'double'))
            error(message('MATLAB:SETDIFF:InvalidInputsDataType',class(a),class(b)));
        end
    end
end

% Determine if A is a row vector.
rowvec = isrow(a);

sparseA = false;

% Determine if A is sparse
if issparse(a)
    sparseA = true;
    a = full(a);
end
if issparse(b)
    b = full(b);
end

if ~byrow
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    % Call ISMEMBER to determine list of non-matching elements of A.
    logUA = ~(ismember(a,b,'R2012a'));
    c = a(logUA);
    
    % Call UNIQUE to remove duplicates from list of non-matches.
    if nargout <= 1
        c = unique(c,order);
    else
        [c,ndx] = unique(c,order);
        
        % Find indices by using logUA and NDX.
        indlogUA = find(logUA);
        ia = indlogUA(ndx);
    end
    
    % If a is a row vector, return c as a row vector.
    if rowvec
        c = c.';
    end
    % If a is sparse then c is sparse.
    if sparseA
        c = sparse(c);
    end
    
else    % 'rows' case
    if ~(ismatrix(a) && ismatrix(b))
        error(message('MATLAB:SETDIFF:NotAMatrix'));
    end
    
    [rowsA,colsA] = size(a);
    [rowsB,colsB] = size(b);
    
    % Automatically pad strings with spaces
    if ischar(a) && ischar(b)
        if colsA > colsB
            b = [b repmat(' ',rowsB,colsA-colsB)];
        elseif colsA < colsB
            a = [a repmat(' ',rowsA,colsB-colsA)];
            colsA = colsB;
        end
    elseif colsA ~= colsB
        error(message('MATLAB:SETDIFF:AandBColnumAgree'));
    end
    
    % Handle empty arrays
    if rowsA == 0
        c = zeros(rowsA,colsA);
        ia = zeros(0,1);
    elseif colsA == 0 && rowsA > 0
        c = zeros(1,0);
        ia = rowsA;
    % General handling
    else
        % Remove duplicates from A; get indices only if needed
        if nargout > 1
            [uA,ia] = unique(a,'rows',order);
        else
            uA = unique(a,'rows',order);
        end
        
        % Create sorted list of unique A and B; want non-matching entries
        [sortuAB,ndx] = sortrows([uA;b]);
        [rowsC,colsC] = size(sortuAB);
        
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of non-matching entries
            d = sortuAB(1:rowsC-1,:) ~= sortuAB(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = any(d,2);
        d(rowsC,1) = 1;   % Final entry always included.
        numRowsUA = size(uA,1);
        d = d & ndx <= numRowsUA; % Now find only the ones in A.
        
        if strcmp(order, 'stable') % 'stable'
            d = sort(ndx(d));   % Sort ndx(d) to maintain 'stable' order
            c = uA(d,:);
        else
            c = sortuAB(d,:);
        end
        
        % Find IA only if needed.
        if nargout > 1
            if strcmp(order, 'stable') % 'stable'
                ia = ia(d);
            else
                ia = ia(ndx(d));
            end
        end
    end
    % If a is sparse then c is sparse.
    if sparseA
        c = sparse(c);
    end
end
end
