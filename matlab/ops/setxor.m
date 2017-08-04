function varargout = setxor(varargin)
%SETXOR Set exclusive-or.
%   C = SETXOR(A,B) for vectors A and B, returns the values that are not 
%   in the intersection of A and B with no repetitions. C will be sorted. 
%
%   C = SETXOR(A,B,'rows') for matrices A and B with the same number of 
%   columns, returns the rows that are not in the intersection of A and B.
%   The rows of the matrix C will be in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that 
%   C is a sorted combination of the values A(IA) and B(IB). If there 
%   are repeated values that are not in the intersection in A or B then the
%   index of the first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of rows A(IA,:) and B(IB,:).
%
%   [C,IA,IB] = SETXOR(A,B,'stable') for arrays A and B, returns the values
%   of C in the same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'sorted') returns the values of C in sorted
%   order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are repeated values that are not in the intersection of A and
%   B, then the index of the first occurrence of each repeated value is
%   returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A, then B.
%   [C,IA,IB] = SETXOR(A,B,'rows','sorted') returns the rows of C in sorted
%   order.
%
%   The behavior of SETXOR has changed.  This includes:
%     -	occurrence of indices in IA and IB switched from last to first
%     -	orientation of vector C
%     -	IA and IB will always be column index vectors
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA,IB] = SETXOR(A,B,'legacy')
%      [C,IA,IB] = SETXOR(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%      [c1,ia1,ib1] = setxor(a,b)
%      % returns
%      c1 = [2 3 5 6 7 8 9 10], ia1 = [20 17 14 11 7 1]', ib1 = [4 14]'
%
%      [c2,ia2,ib2] = setxor(a,b,'stable')
%      % returns
%      c2 = [9 8 7 6 5 2 3 10], ia2 = [1 7 11 14 17 20]', ib2 = [4 14]'
%
%      c = setxor([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [2 4 NaN NaN]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER, SORT, SORTROWS.

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
    [varargout{1:nlhs}] = setxorR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % setxor(A,B, ['rows'], ['legacy'/'R2012a']),
    % setxor(A,B, ['rows'], ['sorted'/'stable']),
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
                error(message('MATLAB:SETXOR:UnknownFlag',flag));
            else
                error(message('MATLAB:SETXOR:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:SETXOR:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:SETXOR:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:SETXOR:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:SETXOR:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:SETXOR:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:SETXOR:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = setxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = setxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = setxorlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = setxorR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia,ib] = setxorlegacy(a,b,isrows)
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

numelA = numel(a);
numelB = numel(b);
nOut = nargout;

if ~(isa(a,'opaque') || isa(b,'opaque')) 
    
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:SETXOR:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];
        
        % Handle empty arrays.
        
        if (numelA == 0 || numelB == 0)
            % Predefine outputs to be of the correct type.
            if (numelA == 0 && numelB == 0)
                ia = []; ib = [];
                if (max(size(a)) > 0 || max(size(b)) > 0)
                    c = reshape(c,0,1);
                    ia = reshape(ia,0,1);
                    ib = reshape(ia,0,1);
                end
            elseif (numelA == 0)
                [c, ib] = unique(b(:),'legacy');
                ia = zeros(0,1);
            else
                [c, ia] = unique(a(:),'legacy');
                ib = zeros(0,1);
            end
            
            % General handling.
            
        else
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Convert to double arrays, which sort faster than other types.
            
            whichclass = class(c);
            isdouble = strcmp(whichclass,'double');
            
            if ~isdouble
%                 if ~strcmp(class(a),'double') %#ok<STISA> Should not pass Sub-classes of double
                if ~isa(a,'double')                
                    a = double(a);
                end
%                 if ~strcmp(class(b),'double') %#ok<STISA> Should not pass Sub-classes of double
                if ~isa(b,'double')
                    b = double(b);
                end
            end
            
            % Sort if unsorted.  Only check this for long lists.
            
            checksortcut = 1000;
            
            if nOut <= 1
                if numelA <= checksortcut || ~(issorted(a))
                    a = sort(a);
                end
                if numelB <= checksortcut || ~(issorted(b))
                    b = sort(b);
                end
            else
                if numelA <= checksortcut || ~(issorted(a))
                    [a,ia] = sort(a);
                else
                    ia = (1:numelA)';
                end
                if numelB <= checksortcut || ~(issorted(b))
                    [b,ib] = sort(b);
                else
                    ib = (1:numelB)';
                end
            end
            
            % Find members of the XOR set.  Pass to ISMEMBC directly if
            % possible (real, full, no NaN) since A and B are sorted double arrays.
            if (isreal(a) && isreal(b)) && (~issparse(a) && ~issparse(b))
                if ~isnan(b(numelB))    % Check final index of B for NaN.
                    tfa = ~ismembc(a,b);
                else
                    tfa = ~ismember(a,b,'legacy'); % Call ISMEMBER if NaN detected in B.
                end
                if ~isnan(a(numelA))    % Check final index of A for NaN.
                    tfb = ~ismembc(b,a);
                else
                    tfb = ~ismember(b,a,'legacy'); % Call ISMEMBER if NaN detected in A.
                end
            else
                tfa = ~ismember(a,b,'legacy');   % If wrong types, call ISMEMBER directly.
                tfb = ~ismember(b,a,'legacy');
            end
            
            % a(tfa) now contains all members of A which are not in B
            % b(tfb) now contains all members of B which are not in A
            if nOut <= 1
                c = unique([a(tfa);b(tfb)],'legacy');    % Remove duplicates from XOR list.
            else
                ia = ia(tfa);
                ib = ib(tfb);
                n = size(ia,1);
                [c,ndx] = unique([a(tfa);b(tfb)],'legacy');  % NDX holds indices to generate C.
                d = ndx > n;                        % Find indices of A and of B.
                ia = ia(ndx(~d));
                ib = ib(ndx(d) - n);
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
                if nOut > 2
                    ib = ib.';
                end
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
            error(message('MATLAB:SETXOR:AandBColnumAgree'));
        end
        
        % Handle empty arrays.
        
        if isempty(a) && isempty(b)
            % Predefine c to be of the correct type.
            c = [a([]);b([])];
            if (rowsA + rowsB == 0)
                c = reshape(c,0,colsA);
            elseif (colsA == 0)
                c = reshape(c,(rowsA > 0) + (rowsB > 0),0);   % Empty row array.
                if rowsA > 0
                    ia = rowsA;
                else
                    ia = [];
                end
                if rowsB > 0
                    ib = rowsB;
                else
                    ib = [];
                end
            end
            
        else
            % Remove duplicates from A and B and sort.
            if nOut <= 1
                a = unique(a,flag,'legacy');
                b = unique(b,flag,'legacy');
                c = sortrows([a;b]);
            else
                [a,ia] = unique(a,flag,'legacy');
                [b,ib] = unique(b,flag,'legacy');
                [c,ndx] = sortrows([a;b]);
            end
            
            % Find all non-matching entries in sorted list.
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:)~=c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            
            d = any(d,2);
            d(rowsC,1) = 1;     % Last row is always unique.
            d(2:rowsC) = d(1:rowsC-1) & d(2:rowsC); % Remove both if match.
            
            c = c(d,:);         % Keep only the non-matching entries
            
            if nOut > 1
                ndx = ndx(d);     % NDX: indices of non-matching entries
                n = size(a,1);
                d = ndx <= n;     % Values in a that don't match.
                ia = ia(ndx(d));
                d = ndx > n;      % Values in b that don't match.
                ib = ib(ndx(d)-n);
            end
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            c = deblank(c);
        end
    end
    
else
    % Handle objects that cannot be converted to doubles 
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:SETXOR:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];
        
        % Handle empty arrays.
        
        if (numelA == 0 || numelB == 0)
            % Predefine outputs to be of the correct type.
            if (numelA == 0 && numelB == 0)
                ia = []; ib = [];
                if (max(size(a)) > 0 || max(size(b)) > 0)
                    c = reshape(c,0,1);
                    ia = reshape(ia,0,1);
                    ib = reshape(ia,0,1);
                end
            elseif (numelA == 0)
                [c, ib] = unique(b(:),'legacy');
                ia = zeros(0,1);
            else
                [c, ia] = unique(a(:),'legacy');
                ib = zeros(0,1);
            end
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            [a,ia] = unique(a(:),'legacy');
            [b,ib] = unique(b(:),'legacy');
            
            % Find matching entries
            e = [a;b];
            [c,ndx] = sort(e);
            
            % d indicates the location of matching entries
            d = find(c(1:end-1)==c(2:end));
            ndx([d;d+1]) = []; % Remove all matching entries
            
            c = e(ndx);
            
            if nOut > 1
                n = length(a);
                d = ndx <= n;
                ia = ia(ndx(d));        % Find indices for set A if needed.
                if nOut > 2
                    d = ndx > n;
                    ib = ib(ndx(d)-n);    % Find indices for set B if needed.
                end
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
                if nOut > 2
                    ib = ib.';
                end
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
            error(message('MATLAB:SETXOR:AandBColnumAgree'));
        end
        
        % Handle empty arrays.
        
        if isempty(a) && isempty(b)
            % Predefine c to be of the correct type.
            c = [a([]);b([])];
            ia = []; ib = [];
            if (rowsA + rowsB == 0)
                c = reshape(c,0,colsA);
            elseif (colsA == 0)
                c = reshape(c,(rowsA > 0) + (rowsB > 0),0);   % Empty row array.
                if rowsA > 0
                    ia = rowsA;
                end
                if rowsB > 0
                    ib = rowsB;
                end
            end
            
        else
            % Remove duplicates from A and B and sort.
            if nOut <= 1
                a = unique(a,flag,'legacy');
                b = unique(b,flag,'legacy');
                c = sortrows([a;b]);
            else
                [a,ia] = unique(a,flag,'legacy');
                [b,ib] = unique(b,flag,'legacy');
                [c,ndx] = sortrows([a;b]);
            end
            
            % Find all non-matching entries in sorted list.
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:)~=c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            
            d = any(d,2);
            d(rowsC,1) = 1;     % Last row is always unique.
            d(2:rowsC) = d(1:rowsC-1) & d(2:rowsC); % Remove both if match.
            
            c = c(d,:);         % Keep only the non-matching entries
            
            if nOut > 1
                ndx = ndx(d);     % NDX: indices of non-matching entries
                n = size(a,1);
                d = ndx <= n;     % Values in a that don't match.
                ia = ia(ndx(d));
                d = ndx > n;      % Values in b that don't match.
                ib = ib(ndx(d)-n);
            end
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            c = deblank(c);
        end
    end
end
end

function [c,ia,ib] = setxorR2012a(a,b,options)
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
                error(message('MATLAB:SETXOR:InvalidInputsDataType',class(a),class(b)));
            end
        elseif ~(strcmpi(class(a),'double') || strcmpi(class(b),'double'))
            error(message('MATLAB:SETXOR:InvalidInputsDataType',class(a),class(b)));
        end
    end
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

if ~byrow
    
    numelA = numel(a);
    numelB = numel(b);
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    % Sort for sorted.  
    if nargout <= 1
        if strcmp(order, 'sorted')  % || strcmp(order, 'last')
            a = sort(a);
            b = sort(b);
        end
    else
        if ~strcmp(order, 'stable')
            [a,ia] = sort(a);
        else
            ia = (1:numelA)';
        end
        if ~strcmp(order, 'stable')
            [b,ib] = sort(b);
        else
            ib = (1:numelB)';
        end
    end
    
    % Call ismember to find the elements in A which are not in B and
    % vice versa
    tfa = ~ismember(a,b,'R2012a');
    tfb = ~ismember(b,a,'R2012a');
    
    
    % a(tfa) now contains all members of A which are not in B
    % b(tfb) now contains all members of B which are not in A
    if nargout <= 1
        c = unique([a(tfa);b(tfb)],order);    % Remove duplicates from XOR list.
    else
        ia = ia(tfa);
        ib = ib(tfb);
        n = size(ia,1);
        [c,ndx] = unique([a(tfa);b(tfb)],order);  % NDX holds indices to generate C.
        d = ndx > n;                        % Find indices of A and of B.
        ia = ia(ndx(~d));
        ib = ib(ndx(d) - n);
        if isempty(ib)
            ib = zeros(0,1);
        end
        if isempty(ia)
            ia = zeros(0,1);
        end
    end
    
    % If A and B are row vectors, return C as row vector.
    if rowvec
        c = c.';
    end
    
else    % 'rows' case
    if ~(ismatrix(a) && ismatrix(b))
        error(message('MATLAB:SETXOR:NotAMatrix'));
    end
    
    [rowsA,colsA] = size(a);
    [rowsB,colsB] = size(b);
    
    % Automatically pad strings with spaces
    if ischar(a) && ischar(b)
        b = [b repmat(' ',rowsB,colsA-colsB)];
        a = [a repmat(' ',rowsA,colsB-colsA)];
    elseif colsA ~= colsB
        error(message('MATLAB:SETXOR:AandBColnumAgree'));
    end
    
    % Make sure a and b contain unique elements.
    if nargout <= 1
        uA = unique(a,'rows',order);
        uB = unique(b,'rows',order);
    else
        [uA,ia] = unique(a,'rows',order);
        [uB,ib] = unique(b,'rows',order);
    end
    
    catuAuB = [uA;uB];                                  % Sort [uA;uB] in order to find matching entries
    [sortuAuB,indSortuAuB] = sortrows(catuAuB);
    
    d = find(all(sortuAuB(1:end-1,:)==sortuAuB(2:end,:),2));    % d indicates the location of matching entries
    indSortuAuB([d;d+1]) = [];                                  % Remove all matching entries - indSortuAuB only contains elements not in intersect
    
    if strcmp(order, 'stable') % 'stable'
        indSortuAuB = sort(indSortuAuB);        % Sort the indices to get 'stable' order
    end
    
    c = catuAuB(indSortuAuB,:);                 % Find C
    
    % Find indices if needed
    if nargout > 1
        n = size(uA,1);
        d = indSortuAuB <= n;           % Find indices in indSortuAuB that belong to A
        if d == 0                       % Force d to be correct shape if none of the elements
            d = zeros(0,1);             % in A are in C.
        end
        ia = ia(indSortuAuB(d));
        if nargout > 2
            d = indSortuAuB > n;            % Find indices in indSortuAuB that belong to B
            if d == 0                       % Force d to be correct shape if none of the elements
                d = zeros(0,1);             % in B are in C
            end
            ib = ib(indSortuAuB(d)-n);      % Find indices in indSortuAuB that belong to B
        end
    end
end
end
