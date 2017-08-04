function varargout = ismember(A,B,flag1,flag2)
%ISMEMBER True for set member.
%   LIA = ISMEMBER(A,B) for arrays A and B returns an array of the same
%   size as A containing true where the elements of A are in B and false 
%   otherwise.
%
%   LIA = ISMEMBER(A,B,'rows') for matrices A and B with the same number 
%   of columns, returns a vector containing true where the rows of A are 
%   also rows of B and false otherwise.
%
%   [LIA,LOCB] = ISMEMBER(A,B) also returns an array LOCB containing the
%   lowest absolute index in B for each element in A which is a member of 
%   B and 0 if there is no such index.
%
%   [LIA,LOCB] = ISMEMBER(A,B,'rows') also returns a vector LOCB containing 
%   the lowest absolute index in B for each row in A which is a member 
%   of B and 0 if there is no such index.
%
%   The behavior of ISMEMBER has changed.  This includes:
%     -	occurrence of indices in LOCB switched from highest to lowest
%     -	tighter restrictions on combinations of classes
%
%   If this change in behavior has adversely affected your code, you may 
%   preserve the previous behavior with:
% 
%      [LIA,LOCB] = ISMEMBER(A,B,'legacy')
%      [LIA,LOCB] = ISMEMBER(A,B,'rows','legacy')
%
%   Examples:
%
%      a = [9 9 8 8 7 7 7 6 6 6 5 5 4 4 2 1 1 1]
%      b = [1 1 1 3 3 3 3 3 4 4 4 4 4 9 9 9]
%
%      [lia1,locb1] = ismember(a,b)
%      % returns
%      lia1 = [1 1 0 0 0 0 0 0 0 0 0 0 1 1 0 1 1 1]
%      locb1 = [14 14 0 0 0 0 0 0 0 0 0 0 9 9 0 1 1 1]
%
%      [lia,locb] = ismember([1 NaN 2 3],[3 4 NaN 1])
%      % NaNs compare as not equal, so this returns
%      lia = [1 0 0 1], locb = [4 0 0 1]
%
%   Class support for inputs A and B, where A and B must be of the same
%   class unless stated otherwise:
%      - logical, char, all numeric classes (may combine with double arrays)
%      - cell arrays of strings (may combine with char arrays)
%      -- 'rows' option is not supported for cell arrays
%      - objects with methods SORT (SORTROWS for the 'rows' option), EQ and NE
%      -- including heterogeneous arrays derived from the same root class
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR, SORT, SORTROWS.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin == 2
    [varargout{1:max(1,nargout)}] = cellismemberR2012a(A,B);
else
    % acceptable combinations, with optional inputs denoted in []
    % ismember(A,B, ['rows'], ['legacy'/'R2012a'])
    nflagvals = 3;
    flagvals = {'rows' 'legacy' 'R2012a'};
    % When a flag is found, note the index into varargin where it was found
    flaginds = zeros(1,nflagvals);
    for i = 3:nargin
        if i == 3
            flag = flag1;
        else
            flag = flag2;
        end
        foundflag = strcmpi(flag,flagvals);
        if ~any(foundflag)
            if ischar(flag)
                error(message('MATLAB:ISMEMBER:UnknownFlag',flag));
            else
                error(message('MATLAB:ISMEMBER:UnknownInput'));
            end
        end
        % Only 1 occurrence of each allowed flag value
        if flaginds(foundflag)
            error(message('MATLAB:ISMEMBER:RepeatedFlag',flag));
        end
        flaginds(foundflag) = i;
    end
        
    % Only 1 of each of the paired flags
    if flaginds(2) && flaginds(3)
        error(message('MATLAB:ISMEMBER:BehaviorConflict'))
    end
    % 'legacy' and 'R2012a' flags must be trailing
    if flaginds(2) && flaginds(2)~=nargin
        error(message('MATLAB:ISMEMBER:LegacyTrailing'))
    end
    if flaginds(3) && flaginds(3)~=nargin
        error(message('MATLAB:ISMEMBER:R2012aTrailing'))
    end
    
    if flaginds(3) % trailing 'R2012a' specified
        [varargout{1:max(1,nargout)}] = cellismemberR2012a(A,B,logical(flaginds(1)));
    elseif flaginds(2) % trailing 'legacy' specified
        [varargout{1:max(1,nargout)}] = cellismemberlegacy(A,B,logical(flaginds(1)));
    else % 'R2012a' (default behavior)
        [varargout{1:max(1,nargout)}] = cellismemberR2012a(A,B,logical(flaginds(1)));
    end
end
end

function [tf,loc] = cellismemberlegacy(a,s,isrows)
% 'legacy' flag implementation

if nargin == 3 && isrows
    warning(message('MATLAB:ISMEMBER:RowsFlagIgnored')); 
end

if ~((ischar(a) || iscellstr(a)) && (ischar(s) || iscellstr(s)))
   error(message('MATLAB:ISMEMBER:InputClass',class(a),class(s)))
end

% convert input to cell arrays of strings
if ischar(a)
    a = cellstr(a);
end
if ischar(s)
    s = cellstr(s);
end

% handle special empty cases
if isempty(a) && isempty(s)
   tf = logical([]); % indefinite result. 
   loc = []; % indefinite result. 
   return
elseif length(s) == 1 && cellfun('isempty',s)
	tempTF = cellfun('isempty',a);
	if any(tempTF(:))
		tf = tempTF;				%in case where s is empty, a is found
								   %in s when a is empty      
		loc = double(tf);           %location = 1 since s has only one member
		return
	end
end

lS = cellfun('length',s);
lengthS = length(lS(:));
memS = max(lS(:)) * lengthS;

% work in chunks of at most 16Mb
maxMem = 8e6;
stepsS = ceil(memS/maxMem);
if memS 
   offset = ceil(lengthS/stepsS);
else
   offset = lengthS;
end

lengthA = numel(a);
tf = false(lengthA,1);
loc = zeros(lengthA,1);
chunkEnd  = lengthS;

while chunkEnd >0
    chunkStart = max(chunkEnd - offset,1);
    chunk = chunkStart:chunkEnd; 
    chunkEnd = chunkStart -1;
    % Only return required arguments from ISMEMBER.
    if nargout > 1
        [tfstep,locstep] = ismember(char(a),char(s(chunk)),'rows','legacy');
        loc = max(loc,(locstep + chunkStart - 1).*(locstep > 0));
    else
        tfstep = ismember(char(a),char(s(chunk)),'rows','legacy');
    end
    tf = tf | tfstep;
    if (all(tf))
        break;
    end
end

tf = reshape(tf,size(a));

if nargout > 1
    loc = reshape(loc,size(a));
end
end

function [lia,locb] = cellismemberR2012a(a,b,isrows)
% 'R2012a' flag implementation

% Error check flag 
if nargin == 3 && isrows
    warning(message('MATLAB:ISMEMBER:RowsFlagIgnored'));
end

if ~((ischar(a) || iscellstr(a)) && (ischar(b) || iscellstr(b)))
    error(message('MATLAB:ISMEMBER:InputClass',class(a),class(b)));
end

% Only non-homogeneous A and B allowed are char and cellstr. 
if (ischar(a) && isrow(a)) || isscalar(a) %scalar case, SORT not needed
   
    match = strcmp(a,b);
    lia = any(match(:));
    if nargout > 1
        if lia
        locb = find(match,1,'first');
        else
          locb = 0;
        end
    end
    
elseif (ischar(b) && isrow(b)) || isscalar(b)
    
    lia = strcmp(a,b);
    if nargout > 1
        locb = double(lia);
    end
    
else
    % If A or B is char, convert it to a cellstr and remove trailing spaces
    if ischar(a)
        a = cellstr(a);   %using cellstr to
    end
    if ischar(b)
        b = cellstr(b);   %using cellstr to remove trailing spaces
    end
    % Duplicates within the sets are eliminated
    [uA,~,icA] = unique(a(:),'sorted');
    if nargout <= 1
        uB = unique(b(:),'sorted');
    else
        [uB,ib] = unique(b(:),'sorted');
    end
    % Sort the unique elements of A and B, duplicate entries are adjacent
    [sortuAuB,IndSortuAuB] = sort([uA;uB]);
    
    % d indicates the indices matching entries
    d = strcmp(sortuAuB(1:end-1),sortuAuB(2:end));
    indReps = IndSortuAuB(d);                          % Find locations of repeats in C
    
    if nargout <= 1
        lia = ismember(icA,indReps,'R2012a');          % Find repeats among original list
    else
        szuA = size(uA,1);
        d = find(d);
        [lia,locb] = ismember(icA,indReps,'R2012a');    % Find locb by using given indices
        newd = d(locb(lia));                            % NEWD is D for non-unique A
        where = ib(IndSortuAuB(newd+1)-szuA);
        locb(lia) = where;
    end
    lia = reshape(lia,size(a));
    if nargout > 1
        locb = reshape(locb,size(a));
    end
end
end

