function varargout = intersect(varargin)
%INTERSECT Set intersection.
%   C = INTERSECT(A,B) for vectors A and B, returns the values common to 
%   the two vectors with no repetitions. C will be sorted.
%
%   C = INTERSECT(A,B,'rows') for matrices A and B with the same 
%   number of columns, returns the rows common to the two matrices. The
%   rows of the matrix C will be in sorted order.
%
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB such 
%   that C = A(IA) and C = B(IB). If there are repeated common values in
%   A or B then the index of the first occurrence of each repeated value is
%   returned.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows') also returns index vectors IA and IB 
%   such that C = A(IA,:) and C = B(IB,:). 
%
%   [C,IA,IB] = INTERSECT(A,B,'stable') for arrays A and B, returns the
%   values of C in the same order that they appear in A.
%   [C,IA,IB] = INTERSECT(A,B,'sorted') returns the values of C in sorted
%   order.
%   If A and B are row vectors, then C will be a row vector as well,
%   otherwise C will be a column vector. IA and IB are column vectors.
%   If there are repeated common values in A or B then the index of the
%   first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows','stable') returns the rows of C in the
%   same order that they appear in A.
%   [C,IA,IB] = INTERSECT(A,B,'rows','sorted') returns the rows of C in
%   sorted order.
%
%   The behavior of INTERSECT has changed.  This includes:
%     -	occurrence of indices in IA and IB switched from last to first
%     -	orientation of vector C
%     -	IA and IB will always be column index vectors
%     -	tighter restrictions on combinations of classes
% 
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [C,IA,IB] = INTERSECT(A,B,'legacy')
%      [C,IA,IB] = INTERSECT(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 9 9 9 9 8 8 8 8 7 7 7 6 6 6 5 5 4 2 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 10 10 10]
%
%      [c1,ia1,ib1] = intersect(a,b)
%      % returns
%      c1 = [1 4], ia1 = [21 19]', ib1 = [1 9]'
%
%      [c2,ia2,ib2] = intersect(a,b,'stable')
%      % returns
%      c2 = [4 1], ia2 = [19 21]', ib2 = [9 1]'
%
%      c = intersect([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      c = [1 3]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER, SORT, SORTROWS.

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
    [varargout{1:nlhs}] = intersectR2012a(varargin{:});
else
    % acceptable combinations, with optional inputs denoted in []
    % intersect(A,B, ['rows'], ['legacy'/'R2012a']),
    % intersect(A,B, ['rows'], ['sorted'/'stable']),
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
                error(message('MATLAB:INTERSECT:UnknownFlag',flag));
            else
                error(message('MATLAB:INTERSECT:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:INTERSECT:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
    
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:INTERSECT:SetOrderConflict'))
    end
    if flaginds(4) && flaginds(5)
        error(message('MATLAB:INTERSECT:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(4) && flaginds(4)~=nrhs
        error(message('MATLAB:INTERSECT:LegacyTrailing'))
    end
    if flaginds(5) && flaginds(5)~=nrhs
        error(message('MATLAB:INTERSECT:R2012aTrailing'))
    end
    
    if flaginds(2) || flaginds(3) % 'stable'/'sorted' specified
        if flaginds(4) || flaginds(5) % does not combine with 'legacy'/'R2012a'
            error(message('MATLAB:INTERSECT:SetOrderBehavior'))
        end
        [varargout{1:nlhs}] = intersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(5) % trailing 'R2012a' specified
        [varargout{1:nlhs}] = intersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    elseif flaginds(4) % trailing 'legacy' specified
        [varargout{1:nlhs}] = intersectlegacy(varargin{1:2},logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:nlhs}] = intersectR2012a(varargin{1:2},logical(flaginds(1:3)));
    end
end
end

function [c,ia,ib] = intersectlegacy(a,b,isrows)
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
            error(message('MATLAB:INTERSECT:AandBvectorsOrRowsFlag'));
        end
        
        c = reshape([a([]);b([])],0,1);    % Predefined to determine class of output
        ia = zeros(0,1);
        ib = ia;
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            
            % Do Nothing
            
        elseif (numelA == 1)
            
            % Scalar A: pass to ISMEMBER to determine if A exists in B.
            [tf,pos] = ismember(a,b,'legacy');
            if tf
                c = a;
                ib = pos;
                ia = 1;
            end
            
        elseif (numelB == 1)
            
            % Scalar B: pass to ISMEMBER to determine if B exists in A.
            [tf,pos] = ismember(b,a,'legacy');
            if tf
                c = b;
                ia = pos;
                ib = 1;
            end
            
        else % General handling.
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Switch to sort shorter list.
            
            if numelA < numelB
                if nOut > 1
                    [a,ia] = sort(a);           % Return indices only if needed.
                else
                    a = sort(a);
                end
                
                [tf,pos] = ismember(b,a,'legacy');     % TF lists matches at positions POS.
                
                where = zeros(size(a));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = a(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = ia(tfs);
                    if nOut > 2
                        ib = where(tfs);
                    end
                end
            else
                if nOut > 1
                    [b,ib] = sort(b);           % Return indices only if needed.
                else
                    b = sort(b);
                end
                
                [tf,pos] = ismember(a,b,'legacy');     % TF lists matches at positions POS.
                
                where = zeros(size(b));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = b(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = where(tfs);
                    if nOut > 2
                        ib = ib(tfs);
                    end
                end
            end
            
            if isobject(c)
                c = eval([class(c) '(ctemp)']);
            else
                c = cast(ctemp,class(c));
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
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error(message('MATLAB:INTERSECT:AandBColnumAgree'));
        end
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut > 1
            [a,ia] = unique(a,flag,'legacy');
            [b,ib] = unique(b,flag,'legacy');
            [c,ndx] = sortrows([a;b]);
        else
            a = unique(a,flag,'legacy');
            b = unique(b,flag,'legacy');
            c = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
    
else
    % Handle objects that cannot be converted to doubles     
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:INTERSECT:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];    % Predefined to determine class of output
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            % Predefine index outputs to be of the correct type.
            ia = [];
            ib = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
                ((size(b,1)==0 && size(b,2)==0) || length(b)==1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
                ib = reshape(ia,0,1);
            end
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            [a,ia] = unique(a(:),'legacy');
            [b,ib] = unique(b(:),'legacy');
            
            % Find matching entries
            [c,ndx] = sort([a;b]);
            d = find(c(1:end-1)==c(2:end));
            ndx = ndx([d;d+1]);
            c = c(d);
            n = length(a);
            
            if nOut > 1
                d = ndx > n;
                ia = ia(ndx(~d));
                ib = ib(ndx(d)-n);
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
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error(message('MATLAB:INTERSECT:AandBColnumAgree'));
        end
        
        ia = [];
        ib = [];
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut <= 1
            a = unique(a,flag,'legacy');
            b = unique(b,flag,'legacy');
            c = sortrows([a;b]);
        else
            [a,ia] = unique(a,flag,'legacy');
            [b,ib] = unique(b,flag,'legacy');
            [c,ndx] = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
end
end

function [c,ia,ib] = intersectR2012a(a,b,options)
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
                error(message('MATLAB:INTERSECT:InvalidInputsDataType',class(a),class(b)));
            end
        elseif ~(strcmpi(class(a),'double') || strcmpi(class(b),'double'))
            error(message('MATLAB:INTERSECT:InvalidInputsDataType',class(a),class(b)));
        end
    end
end

% Determine if A and B are both row vectors.
rowvec = isrow(a) && isrow(b);

numelA = numel(a);

if ~byrow
    
    % Convert to columns
    a = a(:);
    b = b(:);
    
    if strcmp(order, 'stable') 
        % Make sure b contains unique elements.
        [uB,uib] = unique(b,'sorted');                      % Find the unique elements of B in sorted 
                                                            % first order.  This is done to extract
        numeluB = numel(uB);                                % the indices of B in first order so one 
                                                            % can later rearrange them to stable order of A.
        [c,ia,ic] = unique([a;uB],'stable');       
                                                            
        % Find the number of unique elements in A.
        numUA = sum(ia <= numelA);  
        
         % Cut down ic to only include the "uB part"
        ic = ic(numelA+1:numelA+numeluB);      
        
        logIcInterAB = ic <= numUA;             % Find the elements in uB that intersect with unique A.  
                                                % This is done by looking at the uB part of ic and if 
                                                % the index in that is <= numUA that implies that the 
                                                % number represented by the index in ic is in the intersect.
        indIcInterAB = ic(logIcInterAB);        
        
        % Force the correct shape when indIcInterAB is [].
        if isequal(indIcInterAB, [])            
            indIcInterAB = zeros(0,1);
        end
        [sortIndIcInterAB, indSortIndIcInterAB] = sort(indIcInterAB);
        
        % Find C
        c = c(sortIndIcInterAB);                
        
        % Find IA and IB if needed
        if nargout > 1
            ia = ia(sortIndIcInterAB);          
            uib = uib(logIcInterAB);            % First pull out the indices in unique B that are in 
            ib = uib(indSortIndIcInterAB);      % the intersection then reorder them so they represent 
        end                                     % the 'stable' order of A.
    else % sorted 
        % Make sure a and b contain unique elements.
        [uA,ia] = unique(a,order);
        [uB,ib] = unique(b,order);
        
        % Find matching entries
        [sortuAuB,indSortuAuB] = sort([uA;uB]);
        indInterAB = sortuAuB(1:end-1)==sortuAuB(2:end);
        
        % Force the correct shape when indIcInterAB is 0.
        if isequal(indInterAB, 0)                   
            indInterAB = zeros(0,1);
        end
        
        % Find C.
        c = sortuAuB(indInterAB);                   
        
        % Find indices if needed.
        if nargout > 1
            indInterAB = find(indInterAB);
            ndx = indSortuAuB([indInterAB;indInterAB+1]);
            lenA = length(uA);
            logIndab = ndx > lenA;          % Find indices by index values in ndx.
            ia = ia(ndx(~logIndab));
            ib = ib(ndx(logIndab)-lenA);
        end
    end
    
    % If A and B are both row vectors, return c as row vector.
    if rowvec
        c = c.';
    end
    
else    % 'rows' case
    if ~(ismatrix(a) && ismatrix(b))
        error(message('MATLAB:INTERSECT:NotAMatrix'));
    end
    
    [rowsA,colsA] = size(a);
    [rowsB,colsB] = size(b);
    
    % Automatically pad strings with spaces
    if ischar(a) && ischar(b)
        b = [b repmat(' ',rowsB,colsA-colsB)];
        a = [a repmat(' ',rowsA,colsB-colsA)];
    elseif colsA ~= colsB
        error(message('MATLAB:INTERSECT:AandBColnumAgree'));
    end
    
    if strcmp(order, 'stable') 
        % Make sure a and b or just b contain unique elements.
        [uB,uib] = unique(b,'sorted','rows');                       % Find the unique elements of B in sorted 
                                                                    % first order.  This is done to extract the 
        rowsuB = size(uB,1);                                        % indices of B in first order so one can 
                                                                    % later rearrange them to stable order of A.
        [c,ia,ic] = unique([a;uB],'stable','rows');
        
        % Find the number of unique elements in A.
        numUA = sum(ia <= rowsA);   
        
        % Cut down ic to only include the "uB part"
        ic = ic(rowsA+1:rowsA+rowsuB);
        
        % Force ic to be a column if a row
        if isequal(ic, zeros(1,0))
            ic = ic.';
        end
        logIcInterAB = ic <= numUA;             % Find the elements in uB that intersect with unique A.  
                                                % This is done by looking at the uB part of ic and if 
        indIcInterAB = ic(logIcInterAB);        % the index in that is <= numUA that implies that the 
                                                % number represented by the index in ic is in the intersect.        
        [sortIndIcInterAB, indSortIndIcInterAB] = sortrows(indIcInterAB);
        
        % Find C.
        c = c(sortIndIcInterAB,:);                
        
        % Find IA and IB if needed
        if nargout > 1
            ia = ia(sortIndIcInterAB);          
            uib = uib(logIcInterAB);            % First pull out the indices in unique B that are 
            ib = uib(indSortIndIcInterAB);      % in the intersection then reorder them so they 
        end                                     % represent the 'stable' order of A.
        
    else % sorted
        % Make sure a and b or just b contain unique elements.
        [uA,ia] = unique(a,order,'rows');
        [uB,ib] = unique(b,order,'rows');
        
        % Find matching entries
        [sortab,indSortab] = sortrows([uA;uB]);
        rowsAB = size(sortab,1);
        indInterAB = sortab(1:rowsAB-1,:) == sortab(2:rowsAB,:);
        indInterAB = all(indInterAB,2);
        c = sortab(indInterAB,:);
        
        % Find indices if needed.
        if nargout > 1
            rowsuA = size(uA,1);
            ib = ib(indSortab([false;indInterAB])-rowsuA);
            if isequal(indInterAB, false)
                indInterAB = false(0,1);
            end
            ia = ia(indSortab(indInterAB));     % Find indices by index values in indSortab.
            
        end
    end
    
end
end
