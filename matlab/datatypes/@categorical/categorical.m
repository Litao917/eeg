classdef (AllowedSubclasses = {?nominal, ?ordinal}, InferiorClasses = getCategoricalInferiorClasses) categorical
%CATEGORICAL Arrays for categorical data.
%   Categorical arrays are used to store discrete non-numeric values.  A
%   categorical array provides efficient storage and convenient manipulation of
%   such data, while also maintaining meaningful names for the values.
%   Categorical arrays can be subscripted, concatenated, reshaped, etc. just
%   like ordinary numeric arrays.  You can make comparisons between the values
%   in categorical arrays, or between a categorical array and one or more
%   strings representing categorical values.  Categorical arrays are often used
%   as "grouping variables" in a table to define groups of rows.
%
%   Use the CATEGORICAL constructor to create a categorical array from strings
%   or from integer or logical values.  Use the HISTC function to create a
%   categorical array by discretizing continuous numeric values.
%
%   Each categorical array carries along the set of possible values that it can
%   store, known as its categories.  The categories are defined when you create
%   a categorical array, and you can access them using the CATEGORIES method, or
%   modify them using the ADDCATS, RENAMECATS, MERGECATS, or REMOVECATS methods.
%   Assignment to a categorical array can also automatically add new categories
%   if the values assigned are not already categories of the array.
%
%   You may specify that a categorical array's categories have a mathematical
%   ordering -- such an array is said to be "ordinal".  An ordinal array
%   provides a complete set of relational comparisons between values in the
%   array.  Specify the order when you create the categorical array.  Change the
%   ordering of a categorical array's categories using the REORDERCATS method.
%   Arrays whose categories do not have a mathematical ordering only allow
%   comparing for equality between values -- such an array is said to be
%   "nominal".
%
%   CATEGORICAL methods and functions:
%     Construction and conversion:
%       categorical        - Create a categorical array.
%     Size and shape:
%       iscategorical      - True for categorical arrays.
%       size               - Size of a categorical array.
%       length             - Length of a categorical vector.
%       ndims              - Number of dimensions of a categorical array.
%       numel              - Number of elements in a categorical array.
%       cat                - Concatenate categorical arrays.
%       horzcat            - Horizontal concatenation for categorical arrays.
%       vertcat            - Vertical concatenation for categorical arrays.
%     Categories:
%       categories         - Get a list of a categorical array's categories.
%       iscategory         - Test for categorical array categories.
%       addcats            - Add categories to a categorical array.
%       mergecats          - Merge categories of a categorical array.
%       removecats         - Remove categories from a categorical array.
%       renamecats         - Rename the categories of a categorical array.
%       reordercats        - Reorder the categories in a categorical array.
%       isordinal          - True if the categories of a categorical array have a mathematical ordering.
%       isprotected        - True if the categories of a categorical array are protected.
%     Comparison:
%       eq                 - Equality for categorical arrays.
%       ne                 - Not equal for categorical arrays.
%       lt                 - Less than for ordinal categorical arrays.
%       le                 - Less than or equal for ordinal categorical arrays.
%       ge                 - Greater than or equal for ordinal categorical arrays.
%       gt                 - Greater than for ordinal categorical arrays.
%       min                - Smallest element in an ordinal categorical array.
%       max                - Largest element in an ordinal categorical array.
%     Set membership:
%       intersect          - Find elements common to two categorical arrays.
%       ismember           - Find elements in one categorical array that occur in another.
%       setdiff            - Find elements that occur in one categorical array but not in another.
%       setxor             - Find elements that occur in one or the other of two categorical arrays, but not both.
%       unique             - Find unique elements in a categorical array.
%       union              - Find elements that occur in either of two categorical arrays.
%     Data methods:
%       summary            - Print summary of a categorical array.
%       countcats          - Count occurrences of categories in a categorical array's elements.
%       hist               - Histogram of a categorical array.
%       sort               - Sort a categorical array.
%       sortrows           - Sort rows of a categorical array.
%       issorted           - True for sorted categorical array.
%       isundefined        - True for elements of a categorical array that are undefined.
%       times              - Create a categorical array as the cartesian product of existing categories.
%       isequal            - True if categorical arrays are equal.
%       isequaln           - True if categorical arrays are equal, treating undefined elements as equal.
%   Conversion:
%       double             - Convert categorical array to DOUBLE array.
%       single             - Convert categorical array to SINGLE array.
%       int8               - Convert categorical array to INT8 array.
%       int16              - Convert categorical array to INT16 array.
%       int32              - Convert categorical array to INT32 array.
%       int64              - Convert categorical array to INT64 array.
%       uint8              - Convert categorical array to UINT8 array.
%       uint16             - Convert categorical array to UINT16 array.
%       uint32             - Convert categorical array to UINT32 array.
%       uint64             - Convert categorical array to UINT64 array.
%       char               - Convert categorical array to character array.
%       cellstr            - Convert categorical array to cell array of strings.
%
%   Examples:
%      % Create a categorical array from string data in a cell array
%      colors = categorical({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'}, ...
%                           {'r' 'g' 'b'},{'red' 'green' 'blue'})
%
%      % Find elements meeting a criterion
%      colors == 'red'
%      ismember(colors,{'red' 'blue'})
%
%      % Compare two categorical arrays
%      colors2 = fliplr(colors)
%      colors == colors2
%
%      % Create a categorical array by binning continuous data
%      x = rand(100,1);
%      [~,bin] = histc(x,[0 .25 .75 1]);
%      y = categorical(bin,1:3,{'small' 'medium' 'large'},'Ordinal',true);
%      hist(y)
%
%   See also CATEGORICAL, TABLE

%   Copyright 2013 The MathWorks, Inc.
    
    properties(Constant, GetAccess='protected')
        % Class for the codes property
        codesClass = 'uint16';
        
        % Internal code for undefined elements.
        undefCode = zeros(1,categorical.codesClass);
        
        % Invalid code larger than all valid internal codes.
        invalidCode = intmax(categorical.codesClass);
    end

    properties(GetAccess='protected', SetAccess='protected')
        categoryNames = {};
        codes = zeros(0,categorical.codesClass);
        isProtected = false;
        isOrdinal = false;
    end
    properties(Hidden, Constant, GetAccess='public')
        % Text label for displaying undefined elements.
        undefLabel = '<undefined>';
        
        % Maximum number of categories.
        maxNumCategories = categorical.invalidCode - 1;
    end
    
    methods(Access='public')
        function b = categorical(inputData,varargin)
%CATEGORICAL Create a categorical array.
%   C = CATEGORICAL(DATA) creates a categorical array from DATA.  DATA is a
%   numeric, logical, categorical array, or a cell array of strings. CATEGORICAL
%   creates categories in C from the sorted unique values in DATA.
%
%   C = CATEGORICAL(DATA,VALUESET) creates a categorical array from DATA, with
%   one category for each value in VALUESET.  VALUESET is a vector containing
%   unique values that can be compared to those in DATA using the equality
%   operator. VALUESET often contains values not present in DATA.  If DATA
%   contains any values not present in VALUESET, the corresponding elements of
%   C are undefined.
%
%   C = CATEGORICAL(DATA,VALUESET,CATEGORYNAMES) creates a categorical array
%   from DATA, naming the categories in C using CATEGORYNAMES.  CATEGORYNAMES is
%   a cell array of strings.  CATEGORICAL assigns the names to C's categories in
%   order according to the values in VALUESET.
%
%   To merge multiple distinct values in DATA into a single category in C,
%   provide duplicate names corresponding to those values.
%
%   C = CATEGORICAL(DATA, ..., 'Ordinal',ORD) specifies whether C is ordinal,
%   that is, if its categories have a mathematical ordering.  If ORD is true,
%   the values in C can be compared with the complete set of relational
%   comparisons. If ORD is false (the default), the values in C can only be
%   compared for equality.  Discrete non-numeric data that are not ordinal are
%   often referred to as "nominal" data.
%
%   C = CATEGORICAL(DATA, ..., 'Protected',PROTECT) specifies whether or not C's
%   categories are protected.  If PROTECT is false (the default), new categories
%   in C can be created automatically by assigning to C, and C (if it is not
%   ordinal) can be combined with arrays that have different categories.  If
%   PROTECT is true, new categories in C must be added using the ADDCATS method,
%   and C can not be combined with arrays that have different categories.
%   Ordinal arrays are always protected.
%
%   By default, an element of C is undefined if the corresponding element of
%   DATA is NaN (when DATA is numeric), the empty string (when DATA contains
%   strings), or undefined (when DATA is categorical).  CATEGORICAL treats such
%   elements as "undefined" or "missing" and C does not include a category that
%   they belong to.  To create an explicit category for those elements instead
%   of treating them as undefined, you must include NaN, the empty string, or an
%   undefined element in VALUESET.
%
%   Examples:
%      % Create a categorical array from strings
%      colors1 = categorical({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'})
%
%      colors2 = categorical({'r' 'b' 'g'; 'g' 'r' 'b'; 'b' 'r' 'g'}, ...
%                            {'r' 'g' 'b' 'p'},{'red' 'green' 'blue' 'purple'})
%
%      % Create a categorical array from integer values
%      sizes = categorical(randi([1 3],5,2),1:3,{'child' 'adult' 'senior'},'Ordinal',true)
%
%      % Create a categorical array by binning continuous data
%      x = rand(100,1);
%      [~,bin] = histc(x,[0 .25 .75 1]);
%      y = categorical(bin,1:3,{'small' 'medium' 'large'},'Ordinal',true);
%      hist(y)
%
%   See also NOMINAL, ORDINAL, HISTC.

        import matlab.internal.tableUtils.hasMissingVal
        import matlab.internal.tableUtils.validateLogical
        
        codesClass = class(b.codes);

        if nargin == 0
            % Nothing to do
            return
        end
        
        % Pull out optional positional inputs, which cannot be char
        if (nargin < 2) || ischar(varargin{1})
            % categorical(inputData) or categorical(inputData,Name,Value,...)
            suppliedValueSet = false;
            suppliedCategoryNames = false;
        elseif (nargin < 3) || ischar(varargin{2})
            % categorical(inputData,valueSet) or categorical(inputData,valueSet,Name,Value,...)
            suppliedValueSet = true;
            valueSet = varargin{1};
            suppliedCategoryNames = false;
            varargin = varargin(2:end);
        else
            % categorical(inputData,valueSet,categoryNames) or categorical(inputData,valueSet,categoryNames,Name,Value,...)
            suppliedValueSet = true;
            valueSet = varargin{1};
            suppliedCategoryNames = true;
            categoryNames = varargin{2};
            varargin = varargin(3:end);
        end
            
        pnames = {'Ordinal' 'Protected'};
        dflts =  {   false       false };
        [isOrdinal,isProtected,supplied] = ...
            matlab.internal.table.parseArgs(pnames, dflts, varargin{:}); %#ok<*PROP>
        isOrdinal = validateLogical(isOrdinal,'Ordinal');
        isProtected = validateLogical(isProtected,'Protected');
        if isOrdinal
            if supplied.Protected
               if ~isProtected
                   error(message('MATLAB:categorical:UnprotectedOrdinal'));
               end
            else
                isProtected = true;
            end
        end
        b.isOrdinal = isOrdinal;
        b.isProtected = isProtected;
        
        iscellstrInput = iscellstr(inputData);
        
        % Remove spaces from strings
        if ischar(inputData)
            error(message('MATLAB:categorical:CharData'));
        elseif istable(inputData)
            error(message('MATLAB:categorical:TableData'));            
        elseif iscellstrInput
            inputData = strtrim(inputData);
        end
        
        % Input data set given explicitly, do not reorder them
        if suppliedValueSet
            % input set can never be char, char is recognized as a param name
            iscellstrValueSet = iscellstr(valueSet);
            if iscellstrValueSet
                valueSet = strtrim(valueSet(:));
                % unique will remove duplicate empty strings
            elseif isa(valueSet,'categorical')
                % If both inputData and valueSet are ordinal, their categories must match,
                % although the elements of valueSet might be a subset or reorderng of that.
                if isa(inputData,'categorical') && valueSet.isOrdinal
                    if ~isequal(inputData.categoryNames,valueSet.categoryNames)
                        error(message('MATLAB:categorical:ValuesetOrdinalCategoriesMismatch'));
                    end
                end
                valueSet.codes = valueSet.codes(:);
                if sum(isundefined(valueSet)) > 1
                    error(message('MATLAB:categorical:MultipleUndefinedInValueset'));
                end
            elseif isfloat(valueSet)
                valueSet = valueSet(:);
                if sum(isnan(valueSet)) > 1
                    error(message('MATLAB:categorical:MultipleNaNsInValueset'));
                end
            else
                valueSet = valueSet(:);
            end
            
            try
                uvalueSet = unique(valueSet);
            catch ME
                m = message('MATLAB:categorical:UniqueMethodFailedValueset');
                throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
            end
            if length(uvalueSet) < length(valueSet)
                error(message('MATLAB:categorical:DuplicatedValues'));
            end
            
        % Infer categories from categorical data's categories
        elseif isa(inputData,'categorical')
            valueSet = categories(inputData);
            icats = double(inputData.codes);
            iscellstrValueSet = true;
            
        % Infer categories from the data, they are first sorted
        else % ~suppliedValueSet
            % Numeric, logical, cellstr, or anything else that has a unique
            % method, except char (already weeded out).  Cellstr has already had
            % leading/trailing spaces removed. Save the index vector for later.
            try
                [valueSet,~,icats] = unique(inputData(:));
            catch ME
                m = message('MATLAB:categorical:UniqueMethodFailedData');
                throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
            end
            
            % '' or NaN or <undefined> all become <undefined> by default, remove
            % those from the list of categories.
            iscellstrValueSet = iscellstrInput;
            if iscellstrValueSet
                [valueSet,icats] = removeUtil(valueSet,icats,cellfun('isempty',valueSet));
            elseif isfloat(valueSet)
                [valueSet,icats] = removeUtil(valueSet,icats,isnan(valueSet));
            elseif isa(valueSet,'categorical')
                % can't use categorical subscripting on valueSet, go directly to the codes
                [valueSet.codes,icats] = removeUtil(valueSet.codes,icats,isundefined(valueSet));
            end
        end
        if length(valueSet) > categorical.maxNumCategories
            error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
        end
        
        % valueSet is a column vector at this point

        % Category names given explicitly, do not reorder them
        mergingCategories = false;
        if suppliedCategoryNames
            categoryNames = checkCategoryNames(categoryNames,0); % error if '', or '<undefined>', but allow duplicates
            if length(categoryNames) ~= length(valueSet)
                if suppliedValueSet
                    error(message('MATLAB:categorical:WrongNumCategoryNamesValueset'));
                else
                    error(message('MATLAB:categorical:WrongNumCategoryNames'));
                end
            end
            
            % If the category names contain duplicates, those will be merged
            % into identical categories.  Remove the duplicate names, put the
            % categories corresponding to those names at the end so they'll
            % be easier to remove, and create a map from categories to the
            % ultimate internal codes.
            [unames,i,j] = unique(categoryNames,'first');
            mergingCategories = (length(unames) < length(categoryNames));
            if mergingCategories
                [i,iord] = sort(i);
                iordinv(iord) = 1:length(iord); j = iordinv(j);
                dups = setdiff(1:length(categoryNames),i);
                categoryNames = categoryNames(i(:));
                ord = [i(:); dups(:)];
                valueSet = valueSet(ord);
                mergeConvert(2:(length(ord)+1)) = j(ord);
            end
            
            b.categoryNames = categoryNames;
            
        % Infer category names from the input data set, which in turn may be
        % inferred from the input data.  The value set has already been unique'd
        % and turned into a column vector
        elseif ~isempty(valueSet) % if valueSet is empty, no need to create names
            if isnumeric(valueSet)
                if isfloat(valueSet) && any(valueSet ~= round(valueSet))
                    % Create names using 5 digits. If that fails to create
                    % unique names, the caller will have to provide names.
                    b.categoryNames = strtrim(cellstr(num2str(valueSet,'%-0.5g')));
                else
                    % Create names that preserve all digits of integers and
                    % (up to 16 digits of) flints.
                    b.categoryNames = strtrim(cellstr(num2str(valueSet)));
                end
                if length(unique(b.categoryNames)) < length(b.categoryNames)
                    error(message('MATLAB:categorical:CantCreateCategoryNames'));
                end
            elseif islogical(valueSet)
                categoryNames = {'false'; 'true'};
                b.categoryNames = categoryNames(valueSet+1);
                % elseif ischar(valueSet)
                % Char valueSet is not possible
            elseif iscellstrValueSet
                % These may be specifying character values, or they may be
                % specifying categorical values via their names.
                
                % We will not attempt to create a name for the empty string or
                % the undefined categorical label.  Names must given explicitly.
                if any(strcmp(categorical.undefLabel,valueSet))
                    error(message('MATLAB:categorical:UndefinedLabelCategoryName', categorical.undefLabel));
                elseif any(strcmp('',valueSet))
                    error(message('MATLAB:categorical:EmptyCategoryName'));
                end
                % Don't try to make names out of things that aren't strings.
                if ~all(cellfun('size',valueSet,1) == 1)
                    error(message('MATLAB:categorical:CantCreateCategoryNames'));
                end
                b.categoryNames = valueSet(:);
            elseif isa(valueSet,'categorical')
                % We will not attempt to create a name for an undefined
                % categorical element.  Names must given explicitly.
                if any(isundefined(valueSet))
                    error(message('MATLAB:categorical:UndefinedInValueset'));
                end
                bnames = cellstr(valueSet);  % can't use categorical subscripting to
                b.categoryNames = bnames(:); % get a col, force the cellstr instead
            else
                % Anything else that has a char method
                try
                    charcats = char(valueSet); % valueSet a column vector
                catch ME
                    if suppliedValueSet
                        m = message('MATLAB:categorical:CharMethodFailedValueset');
                    else
                        m = message('MATLAB:categorical:CharMethodFailedData');
                    end
                    throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
                end
                if ~ischar(charcats) || (size(charcats,1) ~= numel(valueSet))
                    if suppliedValueSet
                        error(message('MATLAB:categorical:CharMethodFailedValuesetNumRows'));
                    else
                        error(message('MATLAB:categorical:CharMethodFailedDataNumRows'));
                    end
                end
                b.categoryNames = strtrim(cellstr(charcats));
            end
        end
        
        % Assign category codes to each element of output
        b.codes = zeros(size(inputData),codesClass);
        if ~suppliedValueSet
            % If we already have indices into categories because it was created by
            % calling unique(inputData), use those and save a call to ismember.
            b.codes(:) = icats(:);
        else
            if isnumeric(inputData)
                if ~isnumeric(valueSet)
                    error(message('MATLAB:categorical:NumericTypeMismatchValueSet'));
                end
                [~,b.codes(:)] = ismember(inputData,valueSet);
                % NaN may have been given explicitly as a category, but there's
                % at most one by now
                if any(isnan(valueSet))
                    b.codes(isnan(inputData)) = find(isnan(valueSet));
                end
            elseif islogical(inputData)
                if islogical(valueSet)
                    % OK, nothing to do
                elseif isnumeric(valueSet)
                    valueSet = logical(valueSet);
                else
                    error(message('MATLAB:categorical:TypeMismatchValueset'));
                end
                trueCode = find(valueSet);
                falseCode = find(~valueSet);
                % Already checked that valueSet contains unique values, but
                % still need to make sure it has at most one non-zero.
                if length(trueCode) > 1
                    error(message('MATLAB:categorical:DuplicatedLogicalValueset'));
                end
                if ~isempty(trueCode),  b.codes(inputData)  = trueCode;  end
                if ~isempty(falseCode), b.codes(~inputData) = falseCode; end
            elseif iscellstrInput
                if ~iscellstrValueSet
                    error(message('MATLAB:categorical:TypeMismatchValueset'));
                end
                % inputData and valueSet have already had leading/trailing spaces removed
                [~,b.codes(:)] = ismember(inputData,valueSet);
            elseif isa(inputData,'categorical')
                % This could be done in the generic case that follows, but this
                % should be faster.
                convert = zeros(1,length(inputData.categoryNames)+1,codesClass);
                if isa(valueSet,class(inputData))
                    undef = find(isundefined(valueSet)); % at most 1 by now
                    if ~isempty(undef), convert(1) = undef(1); end
                    valueSet = cellstr(valueSet); iscellstrValueSet = true;  %#ok<NASGU>
                elseif iscellstrValueSet
                    % Leave them alone
                else
                    error(message('MATLAB:categorical:TypeMismatchValueset'));
                end
                [~,convert(2:end)] = ismember(inputData.categoryNames,valueSet);
                b.codes(:) = reshape(convert(inputData.codes+1), size(inputData.codes));
            else % anything else that has an eq method, except char (already weeded out)
                if  ~isa(valueSet,class(inputData))
                    error(message('MATLAB:categorical:TypeMismatchValueset'));
                end
                try
                    for i = 1:length(valueSet)
                        b.codes(inputData==valueSet(i)) = i;
                    end
                catch ME
                    m = message('MATLAB:categorical:EQMethodFailedDataValueset');
                    throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
                end
            end
        end
        
        % Merge categories that were given identical names.
        if mergingCategories
            b.codes = reshape(mergeConvert(b.codes+1),size(b.codes));
        end

        end % categorical constructor
        
        function t = isprotected(a)
            %ISPROTECTED True if the categories in a categorical array are protected.
            %   TF = ISPROTECTED(A) returns logical 1 (true) if the categorical array A's
            %   categories are protected, and logical 0 (false) otherwise. The categories of
            %   an ordinal categorical array are always protected.
            %
            %   When you assign values to elements of a protected categorical array, the
            %   values must belong to one of the array's existing categories. Similarly, you
            %   can only combine protected arrays that have the same categories. Use ADDCATS
            %   to add new categories to a protected array before assigning new values.
            %
            %   When you assign values to elements of a categorical array that is not
            %   protected, and the values do not belong to one of the array's existing
            %   categories, new categories are automatically added to the array. Similarly,
            %   you can combine arrays that are not protected even if they do not have the
            %   same categories.
            %
            %   See also CATEGORICAL.
            t = a.isProtected;
        end
        
        function t = isordinal(a)
            %ISORDINAL True if the categories in a categorical array have a mathematical ordering.
            %   TF = ISORDINAL(A) returns logical 1 (true) if the categorical array A was
            %   created with categories that are mathematically ordered, and logical 0
            %   (false) otherwise.
            %
            %   All categorical arrays allow comparing the elements for equality and
            %   inequality.  A categorical array that is ordinal also allows relational
            %   tests of less than, less than or equal, greater than or equal, and greater
            %   than.
            %
            %   See also CATEGORIES.
            t = a.isOrdinal;
        end
    end % methods block

    methods(Access='protected')
        function b = getIndices(a)
            %GETINDICES Get the category indices of a categorical array.
            b = a.codes;
        end
        
        function b = strings2categorical(s,a)
            %STRINGS2CATEGORICAL Create a categorical array "like" another from strings
            [is,us] = strings2codes(s);
            b = a;
            b.isOrdinal = a.isOrdinal;
            b.isProtected = a.isProtected;
            [b.codes,b.categoryNames] = convertCodes(is,us,a.categoryNames);
        end
    end % protected methods block
    
    methods(Static = true, Access='protected')
        [bins,binNames] = discretize(inputData,edges)
    end % static protected methods block
    
    methods(Hidden = true)
        % The default properties method works as desired
    
        % Methods that we inherit, but do not want
        function a = fields(varargin), throwUndefinedError; end %#ok<STOUT>
        function a = fieldnames(varargin), throwUndefinedError; end %#ok<STOUT>
        
        % Methods we don't want to clutter things up with
        disp(a)
        display(a)
        e = end(a,k,n)
        [varargout] = subsref(a,s)
        a = subsasgn(a,s,b)
        i = subsindex(a)
        
        % Variable Editor methods
        out = variableEditorPaste(this,rows,columns,data)
        out = variableEditorInsert(this,orientation,row,col,data)
        [out,warnmsg] = variableEditorColumnDeleteCode(~,varName,colIntervals)
        [out,warnmsg] = variableEditorRowDeleteCode(~,varName,rowIntervals)
        [str,msg] = variableEditorSetDataCode(a,varname,row,col,rhs)
        [sortCode,msg] = variableEditorSortCode(~,varName,columnIndexStrings,direction)
        [out,warnmsg] = variableEditorClearDataCode(a,varname,rows,cols)
    end
    
    methods(Hidden = true, Static = true)
        function a = empty(varargin)
            %EMPTY Create an empty categorical array.
            %   C = categorical.empty() creates a 0x0 categorical array.  C's
            %   set of categories is empty.
            %
            %   C = categorical.empty(M,N,...) or C = categorical.empty([M,N,...]) creates
            %   an M-by-N-by-... categorical array.  At least one of M,N,... must be zero.
            %
            %   See also CATEGORICAL, ISEMPTY.
            if nargin == 0
                acodes = [];
            else
                acodes = zeros(varargin{:});
                if ~isempty(acodes)
                    error(message('MATLAB:categorical:empty:EmptyMustBeZero'));
                end
            end
            a = categorical(acodes);
        end
    end
end % classdef


function throwUndefinedError
st = dbstack;
name = regexp(st(2).name,'\.','split');
m = message('MATLAB:categorical:UndefinedFunction',name{2},'categorical');
throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end


function [c,ic] = removeUtil(c,ic,t)
% Remove elements from c, and update ic's indices into c -- zero out the ones
% that point to elements being removed from c, and shift down the remaining
% ones to point into the reduced version of c
if any(t)
    q = find(~t);
    convert = zeros(size(c)); convert(q) = 1:length(q);
    ic = convert(ic);
    c = c(q);
end
end

% The following function is required by the compiler because the inferior
% class depends on it.
%#function handle_graphicsrc
