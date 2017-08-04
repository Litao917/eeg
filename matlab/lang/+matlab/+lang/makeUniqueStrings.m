function [uniqueStrings, modified] = makeUniqueStrings(strings, varargin)
%MATLAB.LANG.MAKEUNIQUESTRINGS Constructs unique strings from input strings
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S) constructs unique strings, U,
%   from S by appending an underscore and a number to duplicated strings. S
%   is a string (i.e. a 1xN character array or '') or a cell array of strings.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, EXCLUDED) makes the strings
%   in U unique among themselves and unique with respect to EXCLUDED.
%   MAKEUNIQUESTRINGS does not check EXCLUDED for uniqueness.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, WHICHSTRINGS) makes the
%   strings in S(WHICHSTRINGS) unique among themselves and with respect to
%   the remaining strings. WHICHSTRINGS is a logical vector or a vector of
%	indices. MAKEUNIQUESTRINGS does not check the remaining strings for
%	uniqueness, and returns them unmodified in U. Use this syntax when you
%	have one array of strings, and need to check that only some elements of
%	the array are unique.
%
%   U = MATLAB.LANG.MAKEUNIQUESTRINGS(S, ___, MAXSTRINGLENGTH)
%   specifies the maximum length, MAXSTRINGLENGTH, of strings in U. If
%   MAKEUNIQUESTRINGS cannot make elements in S unique without exceeding
%   MAXSTRINGLENGTH, it throws an error.
%
%   [U, MODIFIED] = MATLAB.LANG.MAKEUNIQUESTRINGS(S, ___) also returns a
%   logical array the same size as S to denote modified strings.
%
%	Examples
%   --------
%   Make unique strings with respect to workspace variable names
%
%		var3 = 0;
%       varNames = MATLAB.LANG.MAKEUNIQUESTRINGS({'var' 'var2' 'var' 'var3'}, who)
%
%   returns the cell array {'var' 'var2' 'var_1' 'var3_1'}
%
%   Make unique strings by checking only some elements of the array
%
%       names = {'Peter' 'John' 'Campion' 'Vlad' 'Nick'};
%       names([2 4]) = {'Jeremy','Nick'}; % change the 2nd and 4th names
%       names = MATLAB.LANG.MAKEUNIQUESTRINGS(names, [2 4])
%
%   returns the cell array {'Peter' 'Jeremy' 'Campion' 'Nick_1' 'Nick'}
%
%   See also MATLAB.LANG.MAKEVALIDNAME, NAMELENGTHMAX, WHO.

%   Copyright 2013 The MathWorks, Inc.

% Parse inputs
[strings, exclStrOrElemToChk, maxStringLength] = parseInputs(strings, varargin{:});

% Wrap STRINGS into a cell if it is a single string for algorithm convenience
isInputSingleString = ischar(strings);
if isInputSingleString
    strings = {strings};
end

% Process differently for 2nd option as checkElements or stringsToProtect
if isnumeric(exclStrOrElemToChk) || islogical(exclStrOrElemToChk) % checkElements
    
    % construct stringsToCheck from STRINGS that need to be made unique
    stringsToCheck = strings(exclStrOrElemToChk);
    stringsToCheck = truncateString(stringsToCheck, maxStringLength);
    
    % construct stringsToProtect from STRINGS that should not be modified,
    % but stringsToCheck cannot duplicate with
    if islogical(exclStrOrElemToChk)
        stringsToProtect = strings(~exclStrOrElemToChk);
    else % exclStrOrElemToChk is indices
        stringsToProtect = strings(setdiff(1:length(strings),exclStrOrElemToChk));
    end
    
    % make stringsToCheck unique against the union of itself & stringsToProtect
    [stringsChecked, modifiedInStringsChecked] = ...
        makeUnique(stringsToCheck, stringsToProtect, maxStringLength);
    
    % combine the protected subset of strings with the checked subset
    uniqueStrings = strings;
    uniqueStrings(exclStrOrElemToChk) = stringsChecked;
    
    % compute the positions of modified strings in the now completed set
    modified = false(size(strings));
    modified(exclStrOrElemToChk) = modifiedInStringsChecked;
else % stringsToProtect
    strings = truncateString(strings, maxStringLength);
    [uniqueStrings, modified] = ...
        makeUnique(strings, exclStrOrElemToChk, maxStringLength);
end

% Return names as a single string if it was input as one
if isInputSingleString
    uniqueStrings = uniqueStrings{1};
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  HELPERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strings, modified] = makeUnique(strings, stringsToProtect, maxStringLength)
% find out if there is duplicate by comparing two sorted STRINGS with one
% having an one-element shift
szStrings = size(strings);
[strings,sortIdx] = sort(strings(:));
inverseSortIdx(sortIdx) = 1:length(strings);
% dups has extra FALSE in the beginning to compensate for the
% one-element shift for this dup-detection method
dups = [false; strcmp(strings(1:end-1),strings(2:end))];
needChange = dups | ismember(strings,stringsToProtect);

if any(needChange)
    % EXCLUSION contains elements UNIQUESTRINGS cannot duplicate with -
    % the beginning of of exclusion is initialized empty and will hold
    % strings appended with underscore-numbers (i.e. made unique to the
    % rest), which the remaining strings cannot duplicate with.
    exclusion = [strings(~needChange); stringsToProtect(:)];
    
    % list of increasing underscore-numbers to append to duplicated strings
    % NUMEL(EXCLUSION) elements in this list is guaranteeded to be enough
    % fo all potential duplicates.
    numStr = regexprep(cellstr(num2str((1:((numel(exclusion)+nnz(needChange))*2))','%-d')),'\d*','_$0');
end

% Iterate multiple uniquefication passes until all elements are unique
% (i.e. all FALSE in needChangeInThisPass) OR when any of the append
% violates the length limit imposed by MAXSTRINGLENGTH
needChangeInThisPass = needChange; % elements that need change in this pass
while any(needChangeInThisPass)
    
    numChangedInThisPass = 0;
    ChangeIdx = find(needChangeInThisPass)'; % make it row for the FOR loop
    
    % Go through each elements that need change and make them unique by
    % appending underscore-numbers, taking into account MAXSTRINGLENGTH
    for i = ChangeIdx
        strInThisLoop = strings{i};
        numAppend = 1;
        canMakeUnique = true;
        
        while canMakeUnique && (isequal(numAppend,1) || any(strcmp(uniqueName,exclusion)))
            strAppend = numStr{numAppend};
            if length(strAppend) > maxStringLength-min(length(strInThisLoop),1)
                % Append itself already violates the limit imposed by 
                % MAXSTRINGLENGTH: NAMEINTHISLOOP is empty, append length 
                % can equal MAXSTRINGLENGTH; otherwise, the first character 
                % is to be always preserved
                canMakeUnique = false;
            else           
                % Append string to make it unique
                uniqueName = [strInThisLoop strAppend];
                if length(uniqueName) > maxStringLength
                    uniqueName = [uniqueName(1:maxStringLength-length(strAppend)) strAppend];
                end
                numAppend = numAppend + 1;
            end
        end
        
        % Update list of strings, EXCLUSIONS and NUMCHANGED count if
        % uniquefication suceeds (i.e. uniqueName is different from source)
        if canMakeUnique
            strings{i} = uniqueName;
            exclusion{end+1} = uniqueName; %#ok<AGROW>
            numChangedInThisPass = numChangedInThisPass + 1;
            needChangeInThisPass(i) = false;
        end
    end
    
    % If none of the duplicates is changed after the uniquefication pass,
    % the input set is impossible to make unique by this algorithm
    if isequal(numChangedInThisPass,0)
        throwAsCaller(MException(message('MATLAB:makeUniqueStrings:CannotMakeUnique')));
    end
end

% un-sort and reshape the now unique STRINGS and MODIFIED to match how STRINGS was input
strings = reshape(strings(inverseSortIdx),szStrings);
modified = reshape(needChange(inverseSortIdx),szStrings);
end

function strings = truncateString(strings, maxStringLength)
% Truncate elements of STRINGS to MAXSTRINGLENGTH
for i = 1:numel(strings)
    strings{i}(maxStringLength+1:end)='';
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  INPUT PARSING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strings, exclStrOrElemToChk, maxStringLength] = parseInputs(strings, varargin)

% Helper
isRowOrEmpty = @(x)isrow(x) || isequal(x,'');
isVectorOrEmpty = @(x)isvector(x) || isempty(x);
isIntegerValue = @(x)~any(mod(x,1));
isSingleString = @(x)ischar(x) && isRowOrEmpty(x);
isCellArrayOfStrings = @(x)iscellstr(x) && all(cellfun(isRowOrEmpty,x(:)));

    function validateInputStrings(inputStr)
        % Validate STRINGS
        if ~( isSingleString(inputStr) || (isVectorOrEmpty(inputStr) && isCellArrayOfStrings(inputStr)) )
            error(message('MATLAB:makeUniqueStrings:InvalidInputStrings'))
        end
    end

    function exclStrOrElemToChk = validateExclStrOrElemToChk(exclStrOrElemToChk)
        % Validate EXCLUDEDSTRINGS or ELEMENTSTOCHECK
        if isSingleString(exclStrOrElemToChk)
            % exclStrOrElemToChk is a single (potentially empty) string
            exclStrOrElemToChk = {exclStrOrElemToChk};
        elseif isnumeric(exclStrOrElemToChk) && isIntegerValue(exclStrOrElemToChk)
            % assume exclStrOrElemToChk is checkElements intended to be a range or
            % linear indices into STRINGS
            if isempty(exclStrOrElemToChk) % empty numeric means check none for uniqueness
                exclStrOrElemToChk = false(size(strings));
            elseif max(exclStrOrElemToChk)>length(strings)
                % checkElements exceed the range of STRINGS number of elements
                error(message('MATLAB:makeUniqueStrings:OutOfBoundRange'));
            elseif min(exclStrOrElemToChk)<=0 || any(isnan(exclStrOrElemToChk))
                % elements of the range must be positive
                error(message('MATLAB:makeUniqueStrings:NonPositiveRange'));                
            end
        elseif islogical(exclStrOrElemToChk)
            % assume exclStrOrElemToChk is checkElements when exclStrOrElemToChk is a logical array;
            % the logical indices array must be the same length as STRINGS
            if ~isequal(length(exclStrOrElemToChk),length(strings))
                error(message('MATLAB:makeUniqueStrings:BadLengthLogicalMask'));
            end
        elseif ~( isCellArrayOfStrings(exclStrOrElemToChk) && isVectorOrEmpty(exclStrOrElemToChk) )
            % exclStrOrElemToChk must be a cell array of strings if it comes to here
            error(message('MATLAB:makeUniqueStrings:InvalidFirstOptionalArg'));
        end
    end

    function maxStringLength = validateMaxStringLength(maxStringLength)
        % Validate MAXSTRINGLENGTH
        if ~( isnumeric(maxStringLength) && isscalar(maxStringLength) && isIntegerValue(maxStringLength) && maxStringLength>=0 )
            % MAXSTRINGLENGTH must be a scalar, non-negative integer
            error(message('MATLAB:makeUniqueStrings:BadMaxStringLength'));
        end
        
        % Cap maxStringLength at maxArraySize, unless specified as NaN               
        if ~isnan(maxStringLength)
            maxStringLength = min(maxStringLength, maxArraySize);
        end
    end

% Validate number of inputs
narginchk(1, 3);

% Parse and set EXCLSTRORELEMTOCHK & MAXSTRINGLENGTH
[~, maxArraySize] = computer;
exclStrOrElemToChk = {}; % Default to NULL excluded strings
maxStringLength = maxArraySize; % MAXSTRINGLENGTH default to maxArraySize

if nargin >= 2
    exclStrOrElemToChk = varargin{1};    
    if isequal(nargin,3) % MAXSTRINGLENGTH is specified by user input
        maxStringLength = varargin{2};                
    end
end

% Validate STRINGS, EXCLSTRORELEMTOCHK & MAXSTRINGLENGTH
try % try-catch to throwAsCaller & avoid call stacks in error
    validateInputStrings(strings);
    exclStrOrElemToChk = validateExclStrOrElemToChk(exclStrOrElemToChk);
    maxStringLength = validateMaxStringLength(maxStringLength);
catch ME
    throwAsCaller(ME);
end
end