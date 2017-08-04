function varargout = workspacefunc(whichcall, varargin)
%WORKSPACEFUNC  Support function for Workspace browser component.

% Copyright 1984-2013 The MathWorks, Inc.

% make sure this function does not clear
mlock 

persistent defaultWorkspaceID simulinkLoaded
if isempty(defaultWorkspaceID)
    defaultWorkspaceID = getDefaultWorkspaceID;
end
if isempty(simulinkLoaded)
    simulinkLoaded = false;
end

% throttle workspace updates if any simulations are running
% let the first one go then reset the long delay after the 
% next event
if simulinkLoaded || inmem('-isloaded','simulink')
    simulinkLoaded = true;
    % simulink is loaded - are any systems open and running?
    statuses = get_param(find_system(0,'type','block_diagram'),'SimulationStatus');
    if ~isempty(statuses)
        if iscell(statuses)
            running = any(cellfun(@(x)~isempty(x),strfind(statuses,'running')));
        else
            running = isequal(statuses,'running');
        end
        com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.setSimulationRunning(running);
    end
end

% Special handling for some of the updated APIs
switch whichcall
    case 'getdefaultworkspaceid',
        varargout{1} = defaultWorkspaceID;
        return

    case {'getworkspace','getworkspaceid','getwhosinformation'}
        swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
        cleaner = getCleanupHandler(swl); %#ok<NASGU>
        try
            switch whichcall
                case 'getworkspace'
                    varargout{1} = getWorkspace(varargin{1});
                    return
                    
                case 'getworkspaceid'
                    varargout{1} = setWorkspace(varargin{1});
                    return
                    
                case 'getwhosinformation',
                    varargout = {getWhosInformation(varargin{1})};
                    return
            end
        catch e
            showError(whichcall, e)
            varargout{1} = [];
            return
        end
end

if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
    swl = com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(true);
    cleaner = getCleanupHandler(swl); %#ok<NASGU>
end

% some callers expect to handle errors as strings in varargout
returnError = false;

% some callers expect to handle errors as thrown errors
throwError = true;

% some callers require the VariableEditor to refresh.
requireUpdate = false;

if nargin > 1 && isa(varargin{1},'com.mathworks.mlservices.WorkspaceVariable') && length(varargin{1}) == 1
    % Note: the length() == 1 test is for 'save'.
    variable = varargin{1};
    variableName = char(variable.getVariableName);
    workspaceID = variable.getWorkspaceID;
    theWorkspace = workspacefunc('getworkspace', workspaceID);
    
    % always check for base name
    baseVariableName = arrayviewfunc('getBaseVariableName',variableName);
    exists = logical(evalin(theWorkspace, ['exist( ''' baseVariableName ''' , ''var'')']));
    
    if exists
        try
            baseValue = evalin(theWorkspace, baseVariableName);
            currentValue = evalin(theWorkspace, variableName);
        catch e
            showError(whichcall, e)
            currentValue = [];
        end
    else
        currentValue = [];
    end
end

try
    
switch whichcall
    case 'getcopyname',
        varargout = {getCopyName(varargin{1}, varargin{2})};
    case 'getnewname',
        varargout = {getNewName(varargin{1})};
    case 'getshortvalue',
        varargout = {getShortValue(varargin{1})};
    case 'getshortvalues',
        getShortValues(varargin{1});
    case 'getshortvalueserror',
        getShortValuesError(varargin{1});
    case 'getshortvalueobjectj',
        varargout = {getShortValueObjectJ(varargin{1}, varargin{2:end})};
    case 'num2complex',
        varargout = {num2complex(varargin{1}, varargin{2:end})};
    case 'getshortvalueobjectsj',
        varargout = {getShortValueObjectsJ(varargin{1})};
    case 'getabstractvaluesummariesj',
        varargout = {getAbstractValueSummariesJ(varargin{1})};
    case 'getstatobjectm',
        varargout = {getStatObjectM(varargin{1}, varargin{2}, varargin{3})};
    case 'getstatobjectsj',
        varargout = {getStatObjectsJ(varargin{1}, varargin{2}, varargin{3}, varargin{4})};
    case 'getshortvalueerrorobjects',
        varargout = {getShortValueErrorObjects(varargin{1})};
    case 'areAnyVariablesReadOnly',
        varargout = {areAnyVariablesReadOnly(varargin{1}, varargin{2})};

    % New APIs begin here
    case 'getExist'
        throwError = false;

        varargout{1} = exists;
        
    case 'save'
        returnError = true;
        
        variables = varargin{1};
        fullPath = char(varargin{2});
        doAppend = varargin{3};
        if isempty(variables)
            workspaceID = getDefaultWorkspaceID;
            variableNames = '';
        else
            workspaceID = variables{1}.getWorkspaceID;
            variableNames = char(variables{1}.getVariableName);
            for i = 2:length(variables)
                if (variables{i} ~= workspaceID)
                    error(message('MATLAB:codetools:workspacefunc:AllVariablesMustHaveSameID'));
                end
                variableNames = [variableNames ' ' char(variables{1}.getVariableName)]; %#ok<AGROW>
            end
        end
        
        appendStr = '';
        if doAppend
            appendStr = ' -append';
        end
        
        evalin(getWorkspace(workspaceID), ['save ' fullPath ' ' variableNames appendStr]);
        
    case 'whos'
        throwError = false;

        evalin(getWorkspace(varargin{1}), 'builtin(''whos'')')
        
    case 'getshortvalueobjects',
        throwError = true;

        workspaceID = varargin{1};
        varargin = varargin(2:end);
        
        values = varargin{1};
        for i = 1:length(values)
            values{i} = evalin(getWorkspace(workspaceID),values{i});
        end
        varargout = {getShortValueObjectsJ(values)};
        
    case 'getabstractvaluesummaries',
        throwError = true;

        varargout = {getAbstractValueSummariesJ({currentValue})};
        
    case 'getvariablestatobjects',
        throwError = true;

        workspaceID = varargin{1};
        theWorkspace = getWorkspace(workspaceID);
        
        values = varargin{2};
        for i = 1:length(values)
            variableName = values{i};
            currentValue = evalin(theWorkspace, variableName);
            values{i} = currentValue;
        end
        varargin = varargin(3:end);
        varargout = {getStatObjectsJ(values, varargin{1}, varargin{2}, varargin{3})};
        
    case 'whosinformation',
        throwError = false;
        if varargin{1} == getDefaultWorkspaceID
            error(message('MATLAB:codetools:workspacefunc:GettingVariablesfromDefaultWorkspaceNotImplemented'));
        end
        varargout = {getWhosInformation(evalin(getWorkspace(varargin{1}),'builtin(''whos'')'))};
        
    case 'readonly',
        throwError = false;

        theWorkspace = getWorkspace(varargin{1});
        variableName = varargin{2};
        
        exists = logical(evalin(theWorkspace, ['exist( ''' variableName ''', ''var'')']));
        if ~exists
            varargout{1} = false;
            return
        end
        
        varargin = varargin(2:end);
        names = varargin{2};
        values = varargin{2};
        for i = 1:length(values)
            variableName = values{i};
            currentValue = evalin(theWorkspace, variableName);
            values{i} = currentValue;
        end
        varargout = {areAnyVariablesReadOnly(values, names)};
        
    case 'rmfield'
        throwError = false;

        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName ' = rmfield(' variableName ','''...
            varargin{2} ''');'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
        
    case 'renamefield',
        throwError = false;
        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName ' = renameStructField(' variableName ','''...
            varargin{2} ''',''' varargin{3} ''');'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
        
    case 'createUniqueField',
        % Create new field in scalar struct, struct array, or nested
        % structs.
        throwError = false;
        
        %
        % Uniquely named field (unnamed#) is added at the end, and assigned
        % a value of 0.
        %
        fields = evalin(theWorkspace,['fieldnames(' variableName ')']);
        fieldLength = length(fields) + 1;
        newName = getNewName(fields);
        
        %
        % determine the new order of the fields, if a 'insert before' field
        % isn't specified, insert it at the beginning
        %
        if (numel(varargin) == 2) 
            insertBefore = varargin{2};
            index = find(strcmp(insertBefore, fields));
        else
            index = [];
        end
        
        %
        % create the strings that will define the new field order - note
        % that arrays aren't used so as to minimize the length of the input
        % string to evalin below
        %
        if (~isempty(index))
            % fieldOrder = [1:index-1 fieldLength index:fieldLength-1];
            fieldOrder = sprintf('[1:%d %d %d:%d]', index-1, fieldLength, index, fieldLength-1);
        else
            % fieldOrder = [1:fieldLength];
            fieldOrder = sprintf('[1:%d]', fieldLength);
        end
        
        % first add a field
        evalin(theWorkspace,sprintf('[%s.(''%s'')]=deal(0);', variableName, newName));
        
        % now reorder them (get rid of any indexing at the end as it is illegal
        % to modify an element of a struct array with disimilarly structured
        % elements
        variableName = regexprep(variableName,'\(.+\)$','');
        evalin(theWorkspace,sprintf('%s=orderfields(%s,%s);', variableName, variableName, fieldOrder));

        requireUpdate = true;
        
    case 'duplicateField',
        throwError = false;

        fields = fieldnames(currentValue);
        newName = getCopyName(varargin{2}, fields);
        % cannot use assignin because variable name can itself
        % be a struct field
        expr = [variableName '.' newName ' = ' variableName '.' ...
            varargin{2} ';'];
        evalin(theWorkspace, expr);
        requireUpdate = true;
 
    case 'createVariable'
        throwError = false;

        expression = varargin{2};
        newValue = evalin(theWorkspace,expression);
        whoOutput = evalin(theWorkspace,'who');
        newName = getNewName(whoOutput);
        assignin(theWorkspace, newName, newValue)
        requireUpdate = true;
        
    case 'assignVariable'
        throwError = false;

        returnError = true;
        expression = varargin{2};
        newExpression = evalin(theWorkspace,expression);
        newValue = setVariableValue(baseVariableName, baseValue, variableName, newExpression);
        assignin(theWorkspace, baseVariableName, newValue)
        requireUpdate = true;
            
    otherwise
        error(message('MATLAB:workspacefunc:unknownOption'));
end

    if requireUpdate
        com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.reportWSChange();
    end
    
catch e
    if returnError
        varargout{1} = e.message;
    elseif throwError
        rethrow(e)
    else
        showError(whichcall, e)
        varargout{1}=[]; % to suppress hard error message display on command window
    end
end

%********************************************************************
function out = setVariableValue(baseVariableName,baseValue,lhs,rhs) %#ok
% Use a function to this value so we don't add unexpected variables
% to the caller's workspace.
eval([baseVariableName '= baseValue;']);
eval([lhs ' =  rhs;']);
out = eval(baseVariableName);

%********************************************************************
function yesno = isValidWorkspace(arg)
yesno = isa(arg,'handle') && isscalar(arg) && ismethod(arg,'evalin') && ismethod(arg,'assignin');

%********************************************************************
function out = getWorkspace(arg)
out = getWorkspaceID('-get',arg);

%********************************************************************
function out = setWorkspace(arg)
out = getWorkspaceID('-set',arg);

%********************************************************************
function out = getDefaultWorkspaceID
out = com.mathworks.mlservices.WorkspaceVariable.DEFAULT_ID;

%********************************************************************
function out = getWorkspaceID(request, arg)
persistent savedWorkspaces;
persistent defaultID;
persistent defaultWS;
if isempty(savedWorkspaces)
    savedWorkspaces = cell(1,10);
end
if isempty(defaultID)
    defaultID = getDefaultWorkspaceID;
end
if isempty(defaultWS)
    defaultWS = 'default';
end

switch request
    case '-get'
        if isempty(arg)
            error(message('MATLAB:codetools:workspacefunc:ArgumentToGetWorkspaceIDCannotBeEmpty'));
        end
        
        if isequal(arg,defaultID)
            out = 'caller';
            return
        end
        
        if arg > length(savedWorkspaces) || ~isnumeric(arg) || ...
                isempty(savedWorkspaces{arg}) || isequal(savedWorkspaces{arg},0)
            error(message('MATLAB:codetools:unknownid'));
        end
        
        out = savedWorkspaces{arg};
    
    case '-set'
        if isempty(arg)
            arg = defaultWS;
        end

        if isequal(arg,defaultWS)
            out = defaultID;
            return
        end
        
        if ~isValidWorkspace(arg)
            error(message('MATLAB:codetools:invalid'));
        end
        
        locations = cellfun(@(candidate)isequal(candidate,arg), savedWorkspaces);
        if any(locations)
            index = find(locations);
            if length(index) > 1
                error(message('MATLAB:codetools:workspacefunc:WorkspaceStorageErrorTooManyWorkspacesFound'));
            end
        else
            indexes = find(cellfun('isempty',savedWorkspaces));
            if isempty(indexes)
                % grow the array
                savedWorkspaces{end+1} = arg;
                index = length(savedWorkspaces);
            else
                index = min(indexes);
                savedWorkspaces{index} = arg;
            end
        end
        out = index;

    otherwise
        error(message('MATLAB:codetools:workspacefunc:UnexpectedInput', request));

end

%********************************************************************
function new = getCopyName(orig, who_output)

counter = 0;
new_base = [orig 'Copy'];
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function new = getNewName(who_output)

counter = 0;
new_base = 'unnamed';
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function getShortValues(vars)

w = warning('off', 'all');
fprintf(char(10));
for i=1:length(vars)
    % Escape any backslashes.
    % Do it here rather than in the getShortValue code, since the
    % fact that Java is picking them up for interpretation is a
    % function of how they're being displayed.
    val = getShortValue(vars{i});
    val = strrep(val, '\', '\\');
    val = strrep(val, '%', '%%');
    fprintf([val 13 10]);
end
warning(w);

%********************************************************************
function retstr = getShortValue(var)

retstr = '';
if isempty(var)
    if builtin('isnumeric', var)
        % Insert a space for enhanced readability.
        retstr = '[ ]';
    end
    if ischar(var)
        retstr = '''''';
    end
end

if isempty(retstr)
    try
        if ~isempty(var)
            if builtin('isnumeric',var) && (numel(var) < 11) && (ndims(var) < 3)
                % Show small numeric arrays.
                if isempty(strfind(get(0, 'format'), 'long'))
                    retstr = mat2str(var, 5);
                else
                    retstr = mat2str(var);
                end
            elseif islogical(var) && (numel(var) == 1)
                if var
                    retstr = 'true';
                else
                    retstr = 'false';
                end
            elseif (ischar(var) && (ndims(var) == 2) && (size(var, 1) == 1))
                % Show "single-line" char arrays, while establishing a reasonable
                % truncation point.
                if isempty(strfind(var, char(10))) && ...
                        isempty(strfind(var, char(13))) && ...
                        isempty(strfind(var, char(0)))
                    limit = 128;
                    if numel(var) <= limit
                        retstr = ['''' var ''''];
                    else
%                         retstr = ['''' var(1:limit) '...'' ' ...
%                             getString(message('MATLAB:codetools:workspacefunc:cellstr_PreviewTruncatedAt')) num2str(limit) ' characters>'];
                          strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(limit)));
                          retstr = ['''' var(1:limit) '...'' ' ...
                            strPreviewTruncated];
                    end
                end
            elseif isa(var, 'function_handle') && numel(var) == 1
                retstr = strtrim(evalc('disp(var)'));
            end
        end
        
        % Don't call mat2str on an empty array, since that winds up being the
        % char array "''".  That looks wrong.
        if isempty(retstr)
            s = size(var);
            D = numel(s);
            if D == 1
                % This can happen when objects that have overridden SIZE (such as
                % a javax.swing.JFrame) return another object as their "size."
                % In that case, it's a scalar.
                theSize = '1x1';
            elseif D == 2
                theSize = [num2str(s(1)), 'x', num2str(s(2))];
            elseif D == 3
                theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
                    num2str(s(3))];
            else
                theSize = [num2str(D) '-D'];
            end
            classinfo = [' ' getclass(var,true)];
            retstr = ['<', theSize, classinfo, '>'];
        end
    catch err %#ok<NASGU>
        retstr = getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue'));
    end
end

%********************************************************************
function result = localAlreadyExists(name, who_output)
result = false;
counter = 1;
while ~result && counter <= length(who_output)
    result = strcmp(name, who_output{counter});
    counter = counter + 1;
end

%********************************************************************
function getShortValuesError(numberOfVars)

fprintf(char(10));
for i=1:numberOfVars
    fprintf([getString(message('MATLAB:codetools:workspacefunc:ErrorRetrievingValue')) 13 10]);
end

%********************************************************************
function retval = getShortValueObjectJ(var, varargin)
if isempty(var)
    if builtin('isnumeric', var)
        retval = num2complex(var);
        return;
    end
    if ischar(var)
        retval = num2complex(var);
        return;
    end
end

try
    % Start by assuming that we won't get anything back.
    retval = '';
    if ~isempty(var)
        if islogical(var)
            retval = num2complex(var);
        end
    end

    if (ischar(var) && (ndims(var) == 2) && (size(var, 1) == 1))
        % Show "single-line" char arrays, while establishing a reasonable
        % truncation point.
        if isempty(strfind(var, char(10))) && ...
                isempty(strfind(var, char(13))) && ...
                isempty(strfind(var, char(0)))
            quoteStrings = true;
            limit = 128;
            optargin = size(varargin,2);
            if (optargin > 0) 
                quoteStrings = varargin{1};
            end
            if (optargin > 1) 
                limit = varargin{2};
            end
            if numel(var) <= limit
                if (quoteStrings)
                    retval = java.lang.String(['''' var '''']);
                else
                    retval = java.lang.String(['' var '']);
                end
            else
                strPreviewTruncated = getString(message('MATLAB:codetools:workspacefunc:PreviewTruncatedAtCharacters',num2str(limit)));
                retval = java.lang.String(...
                    sprintf('''%s...'' %s', ...
                    var(1:limit), strPreviewTruncated));
            end
        end
    end

    if isa(var, 'function_handle') && numel(var) == 1
        retval = java.lang.String(strtrim(evalc('disp(var)')));
    end

    % Don't call mat2str on an empty array, since that winds up being the
    % char array "''".  That looks wrong.
    if isempty(retval)
        retval = num2complex(var);
    end
catch err %#ok<NASGU>
    retval = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
end

%********************************************************************
function outVal = num2complex(in)
if builtin('isnumeric', in)
    if isscalar(in)
        outVal = createComplexScalar(in);
    elseif isempty(in)
        % Use this to get the special "empty" handling of the
        % ValueSummaryFactory class.
        clazz = class(in);
        outVal = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            cast(0, clazz), size(in), ...	 
            ~dataviewerhelper('isUnsignedIntegralType', in), isreal(in));
    elseif numel(size(in)) > 2 || numel(in) > 10
        outVal = getAbstractValueSummaryJ(in);
    else
        outVal = createComplexVector(in);
    end
else
    if islogical(in)
        if isscalar(in)
            if (in)
                outVal = java.lang.Boolean.TRUE;
            else
                outVal = java.lang.Boolean.FALSE;
            end
        else
            % Let it drop to the class-handling code.
            outVal = getAbstractValueSummaryJ(in);
        end
    else
        outVal = getAbstractValueSummaryJ(in);
    end
end

%********************************************************************
function outVal = createComplexScalar(in)
import com.mathworks.widgets.spreadsheet.data.ComplexScalarFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(toReport, signed);
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(double(toReport));
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function outVal = createComplexVector(in)
import com.mathworks.widgets.spreadsheet.data.ComplexArrayFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if isreal(in)
        outVal = ComplexArrayFactory.valueOf(toReport, signed);
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if isreal(in)
        outVal = ComplexArrayFactory.valueOf(double(toReport));
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function ret = getAbstractValueSummariesJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getAbstractValueSummaryJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
    end
end
warning(w);

%********************************************************************
function clazz = getclass(in,include_attributes)
if ~isa(in, 'timeseries') || numel(in)~=1
    w = whos('in');
    clazz = w.class;
    if include_attributes
        if w.complex
            clazz = ['complex ' clazz]; % not translated in MATLAB
        end
        if w.sparse
            clazz = ['sparse ' clazz]; % not translated in MATLAB
        end
        if w.global
            clazz = ['global ' clazz]; % not translated in MATLAB
        end
    end
else
    clazz = [class(in.Data) ' ' class(in)];
end

%********************************************************************
function vs = getAbstractValueSummaryJ(in)

w = whos('in');
vs = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(...
            getclass(in,false), w.size);
if w.complex
    vs.setIsReal(false);
end
if w.global
    vs.setIsGlobal(true);
end
if w.sparse
    vs.setIsSparse(true);
end
if strcmp(w.class, 'struct')
    f = fieldnames(in);
    vs.setNumFields(length(f));
end

%********************************************************************
function ret = getShortValueObjectsJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getShortValueObjectJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorDisplayingValue')));
    end
end
warning(w);

%********************************************************************
function retval = getStatObjectM(var, baseFunction, showNaNs)

underlyingVar = var;
% First handle timeseries, since they aren't numeric.
isTimeseries = false;
if isa(var, 'timeseries')
    underlyingVar = get(var, 'Data');
    isTimeseries = true;
end
    
if ~builtin('isnumeric', underlyingVar) || isempty(underlyingVar) || issparse(underlyingVar)
    retval = '';
    return;
end

if isinteger(underlyingVar) && ~strcmp(baseFunction, 'max') && ...
        ~strcmp(baseFunction, 'min') && ~strcmp(baseFunction, 'range')
    retval = '';
    return;
end

if isTimeseries
    if strcmp(baseFunction, 'range')
        retval = local_ts_range(var);
    else
        retval = fevalPossibleMethod(baseFunction, var);
    end
else
    if (showNaNs)
        switch(baseFunction)
            case 'min'
                fun = @local_min;
            case 'max'
                fun = @local_max;
            case 'range'
                fun = @local_range;
            case 'mode'
                fun = @local_mode;
            otherwise
                fun = baseFunction;
        end
    else
        switch(baseFunction)
            case 'range'
                fun = @local_nanrange;
            case 'mean'
                fun = @local_nanmean;
            case 'median'
                fun = @local_nanmedian;
            case 'mode'
                fun = @local_mode;
            case 'std'
                fun = @local_nanstd;
            otherwise
                fun = baseFunction;
        end
    end
    % Scalar Objects do not need to be indexed as it is already handled
    % by basefunctions (Min,Max,etc)
    if ~isscalar(var)
        var = var(:);
    end
    
    retval = feval(fun, var);
end

%********************************************************************
function retval = getStatObjectJ(var, baseFunction, showNaNs)
retval = num2complex(getStatObjectM(var, baseFunction, showNaNs));

%********************************************************************
function ret = getStatObjectsJ(vars, baseFunction, showNaNs, numelLimit)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    var = vars{i};
    if numel(var) > numelLimit
        ret(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:TooManyElements')));
    else
        try
            ret(i) = getStatObjectJ(var, baseFunction, showNaNs);
        catch err %#ok<NASGU>
            clazz = builtin('class', var);
            if strcmp(clazz, 'int64') || strcmp(clazz, 'uint64')
                ret(i) = num2complex('');
            else
                % Excluded the <ErrorDisplayingValue> to not display this
                % error and display a blank  instead. 
                ret(i) = java.lang.String('');
            end
        end
    end
end
warning(w);

%********************************************************************
function out = fevalPossibleMethod(baseFunction, var)
if ismethod(var, baseFunction)
    out = feval(baseFunction, var);
else
    out = '';
end

%********************************************************************
function out = getShortValueErrorObjects(numberOfVars)

out = javaArray('java.lang.String', length(numberOfVars));
for i=1:numberOfVars
    out(i) = java.lang.String(getString(message('MATLAB:codetools:workspacefunc:ErrorRetrievingValue')));
end

%********************************************************************
function m = local_min(x)
if isfloat(x)
    if any(isnan(x))
        m = cast(NaN, class(x));
    else
        m = min(x);
    end
else
    m = min(x);
end
%********************************************************************
function m = local_max(x)

%Handling the input objects of subclass of Numeric classes with properties
% Modified  the implementation same as Min 
if isfloat(x)
    if any(isnan(x))
        m = cast(NaN, class(x));
    else
        m = max(x);
    end
else
    m = max(x);
end

%********************************************************************
function m = local_range(x)
lm = local_max(x);
if isnan(lm)
    m = cast(NaN, class(x));
else
    m = lm-local_min(x);
end

%********************************************************************
function m = local_ts_range(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanrange(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanmean(x)
% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

% Count up non-NaNs.
n = sum(~nans);
n(n==0) = NaN; % prevent divideByZero warnings
% Sum up non-NaNs, and divide by the number of non-NaNs.
m = sum(x) ./ n;

%********************************************************************
function y = local_nanmedian(x)

% If X is empty, return all NaNs.
if isempty(x)
    y = nan(1, 1, class(x));
else
    x = sort(x,1);
    nonnans = ~isnan(x);

    % If there are no NaNs, do all cols at once.
    if all(nonnans(:))
        n = length(x);
        if rem(n,2) % n is odd
            y = x((n+1)/2,:);
        else        % n is even
            y = (x(n/2,:) + x(n/2+1,:))/2;
        end

    % If there are NaNs, work on each column separately.
    else
        % Get percentiles of the non-NaN values in each column.
        y = nan(1, 1, class(x));
        nj = find(nonnans(:,1),1,'last');
        if nj > 0
            if rem(nj,2) % nj is odd
                y(:,1) = x((nj+1)/2,1);
            else         % nj is even
                y(:,1) = (x(nj/2,1) + x(nj/2+1,1))/2;
            end
        end
    end
end

%********************************************************************
function y = local_nanstd(varargin)
y = sqrt(local_nanvar(varargin{:}));

%********************************************************************
function y = local_nanvar(x)

% The output size for [] is a special case when DIM is not given.
if isequal(x,[]), y = NaN(class(x)); return; end

% Need to tile the mean of X to center it.
tile = ones(size(size(x)));
tile(1) = length(x);

% Count up non-NaNs.
n = sum(~isnan(x),1);

% The unbiased estimator: divide by (n-1).  Can't do this when
% n == 0 or 1, so n==1 => we'll return zeros
denom = max(n-1, 1);
denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

x0 = x - repmat(local_nanmean(x), tile);
y = local_nansum(abs(x0).^2) ./ denom; % abs guarantees a real result

%********************************************************************
function y = local_nansum(x)
x(isnan(x)) = 0;
y = sum(x);

%********************************************************************
function y = local_mode(x)

y = mode(x);

%********************************************************************
function out = getWhosInformation(in)

if numel(in) == 0
    out = com.mathworks.mlwidgets.workspace.WhosInformation.getInstance;
else
    % Prune the dataset to only include the deepest nesting level - this
    % is relevant for nested functions when debugging. The desired behavior
    % is to only show the variables in the deepest workspace.
    nesting = [in.nesting];
    level = [nesting.level];
    prunedWhosInformation = in(level == max(level));

    % Perform a case insensitive sort since "whos" returns the variables
    % sorted in case sensitive order. Since this case sensitive order
    % puts capital letters ahead of lower case, reverse it first, so that
    % the sort resolves matching lower case names with capital letters
    % after lower case. This ensures that the variables are sorted with an
    % order that matches the details pane of CSH (944091)
    names = {prunedWhosInformation.name};
    [~,I] = sort(lower(names(end:-1:1)));
    I = length(names)-I+1;
    sortedWhosInformation = prunedWhosInformation(I);

    siz = {sortedWhosInformation.size}';
    names = {sortedWhosInformation.name};
    inbytes = [sortedWhosInformation.bytes];
    inclass = {sortedWhosInformation.class};
    incomplex = [sortedWhosInformation.complex];
    insparse = [sortedWhosInformation.sparse];
    inglobal = [sortedWhosInformation.global];
    
    out = com.mathworks.mlwidgets.workspace.WhosInformation(names, ...
        siz, inbytes, inclass, incomplex, insparse, inglobal);
end

%********************************************************************
function isReadOnly = areAnyVariablesReadOnly(values, valueNames)
values = fliplr(values);
valueNames = fliplr(valueNames);
isReadOnly = false;
for i = 1:length(valueNames)-1
    thisFullValue = values{i};
    if ~isstruct(thisFullValue)
        thisFullValueName = valueNames{i};
        nextFullValueName = valueNames{i+1};
        delim = nextFullValueName(length(thisFullValueName)+1);
        if delim == '.'
            nextShortIdentifier = nextFullValueName(length(thisFullValueName)+2:end);
            metaclassInfo = metaclass(values{i});
            properties = metaclassInfo.Properties;
            for j = 1:length(properties)
                thisProp = properties{j};
                if strcmp(thisProp.Name, nextShortIdentifier)
                    if ~strcmp(thisProp.SetAccess, 'public')
                        isReadOnly = true;
                        return;
                    end
                end
            end
        end
    end
end

function cleaner = getCleanupHandler(swl)
cleaner = onCleanup(@(~,~) com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.swl(swl));

function showError(whichcall, e)
msg = e.message;
stack = e.stack;
[~,file] = fileparts(stack(1).file);
line = num2str(stack(1).line);
com.mathworks.mlwidgets.array.ArrayDialog.showErrorDialog([whichcall 10 msg 10 file 10 line])
