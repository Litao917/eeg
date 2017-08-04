function t = readTextFile(file,args)
%READFILE Read in a delimited text file and create a table.

%   Copyright 2012-2013 The MathWorks, Inc.

import matlab.internal.tableUtils.validateLogical

pnames = {'ReadVariableNames' 'ReadRowNames' 'Delimiter' 'Format' 'TreatAsEmpty' 'HeaderLines'};
dflts =  {               true          false     'comma'       []             {}            0 };
[readVarNames,readRowNames,delimiter,format,treatAsEmpty,headerLines,supplied,otherArgs] ...
                   = matlab.internal.table.parseArgs(pnames, dflts, args{:});

readRowNames = validateLogical(readRowNames,'ReadRowNames');
readVarNames = validateLogical(readVarNames,'ReadVariableNames');

inferFormat = ~supplied.Format;

tab = sprintf('\t');
lf = sprintf('\n');

% Set the delimiter, recognizing aliases
if ischar(delimiter)
    whiteSpace = sprintf(' \b\t');
    switch delimiter
    case {'tab', '\t', tab}
        delimiter = tab;
        whiteSpace = sprintf(' \b');
    case {'space',' '}
        delimiter = ' ';
        whiteSpace = sprintf('\b\t');
    case {'comma', ','}
        delimiter = ',';
    case {'semi', ';'}
        delimiter = ';';
    case {'bar', '|'}
        delimiter = '|';
    otherwise
        if ~isscalar(delimiter)
            error(message('MATLAB:readtable:InvalidDelimiter'));
        end
    end
else
    error(message('MATLAB:readtable:InvalidDelimiter'));
end

if isempty(treatAsEmpty)
    treatAsEmpty = {};
elseif ischar(treatAsEmpty) && ~isrow(treatAsEmpty)
    % textscan does something a little obscure when treatAsEmpty is char but
    % not a row vector, disallow that here.
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
elseif ischar(treatAsEmpty) || iscellstr(treatAsEmpty)
    % TreatAsEmpty is only ever applied to numeric fields in the file, and
    % textscan ignores leading/trailing whitespace for those fields, so trim
    % insignificant whitespace.
    treatAsEmpty = strtrim(treatAsEmpty);
    if any(~isnan(str2double(treatAsEmpty))) || any(strcmpi('nan',treatAsEmpty))
        error(message('MATLAB:readtable:NumericTreatAsEmpty'));
    end
else
    error(message('MATLAB:readtable:InvalidTreatAsEmpty'));
end

if ~isscalar(headerLines) || ~isnumeric(headerLines) || ...
                (headerLines < 0) || (round(headerLines) ~= headerLines)
    error(message('MATLAB:readtable:InvalidHeaderLines'));
end
tdfreadHeaderLines = headerLines + readVarNames; % the tdfread local never reads var names

% textscan has many parameters that the local fread-based function does not
% support. If a format is not specified, may end up falling back to that code,
% so can't accept those params unless a forrmat is provided.
if inferFormat && ~isempty(otherArgs)
    try
        % Give error based on whether we have a textscan param, or something
        % completely unknown.
        textscan('a','%s',otherArgs{:});
    catch ME
        if strcmp(ME.identifier,'MATLAB:textscan:UnknownOption')
            error(message('MATLAB:table:parseArgs:BadParamName',otherArgs{1}));
        end
    end
    error(message('MATLAB:readtable:MustProvideFormat',otherArgs{1}));
end

numNonDataLines = headerLines + readVarNames;

% Open the file.
fid = fopen(file,'rt'); % text mode: CRLF -> LF on windows (no-op on linux)
if fid == -1
    % Try again with default extension if there wasn't one
    [~,~,fx] = fileparts(file);
    if isempty(fx)
        fid = fopen([file '.txt'],'rt'); % text mode: CRLF -> LF on windows (no-op on linux)
    end
end
if fid == -1
    error(message('MATLAB:readtable:OpenFailed',file));
end
cleanFid = onCleanup(@()fclose(fid));

if readVarNames
    % Read in the first line of var names as a single string, skipping any leading
    % blank lines.
    raw = textscan(fid,'%s',1,'whitespace',lf,'headerlines',headerLines,otherArgs{:});
    headerLines = 0; % just skipped them
    if isempty(raw{1}) || isempty(raw{1}{1})
        if inferFormat
            t = table.empty(0,0);
            return
        else
            vnline = ' '; % whitespace
        end
    else
        vnline = raw{1}{1};
    end
end

% Guess at a format string for the data, based on the first line of data.
if inferFormat
    % Read in the first line of data as a single string, skipping any leading
    % blank lines.  Then back up.
    startDataPosn = ftell(fid);
    raw = textscan(fid,'%s',1,'whitespace',lf,'headerlines',headerLines);
    fseek(fid,startDataPosn,'bof');
    if isempty(raw{1}) || isempty(raw{1}{1})
        if readVarNames
            nvars = length(find(vnline==delimiter)) + 1;
        else
            nvars = 0;
        end
        if nvars > 0
            format = repmat('%f',1,nvars);
        else
            format = '%*s'; % textscan does not accept an empty format
        end
    else
        % Determine how many data columns there are.
        line1 = raw{1}{1};
        nvars = length(find(line1==delimiter)) + 1;

        % Read the values in the first line of data as strings, then try to
        % convert each one to numeric.  No point in using %q here to remove
        % quotes, because %f won't be able to do that with the rest of the
        % lines. Quoted numbers will end up as strings.
        strs = textscan(line1,repmat('%s',1,nvars),1,'delimiter',delimiter,'whitespace',whiteSpace);
        format = repmat('%f',1,nvars);
        for i = 1:nvars
            cstr = strs{i};
            if isempty(cstr)
                str = '';
            else
                str = cstr{1};
            end
            num = str2double(str);
            if isnan(num)
                % If the result was NaN, figure out why.
                if isempty(str) || strcmpi(str,'nan') || any(strcmp(str,treatAsEmpty))
                    % NaN came from a nan string, and empty field, or one of the
                    % treatAsEmpty strings, treat this column as numeric.  Note that
                    % because we check str against treatAsEmpty, the latter only works
                    % on numeric columns.  That is what textscan does.
                    format(2*i) = 'f';
                else
                    % NaN must have come from a failed conversion, treat this column
                    % as (possibly double-quoted) strings.
                    format(2*i) = 'q';
                end
            else
                % Otherwise the conversion succeeded, treat this column as numeric.
                format(2*i) = 'f';
            end
        end
    end
end

% Read in the data using the guessed-at or specified format.  textscan
% automatically skips blank lines.  Even if there's nothing left in the file,
% textscan will return the right types in raw.
raw = textscan(fid,format,'delimiter',delimiter,'whitespace',whiteSpace, ...
    'headerlines',headerLines,'treatasempty',treatAsEmpty,otherArgs{:});
atEOF = feof(fid);

if ~atEOF
    % textscan failed because some column had the "wrong" value in it, i.e.,
    % not the same type as in that column in the first data line.  If no
    % format was given, fall back to the slower but more forgiving TDFREAD.
    % Otherwise, give up.
    if inferFormat
        raw = tdfread(file,delimiter,tdfreadHeaderLines,treatAsEmpty);
    else
        m = message('MATLAB:readtable:CouldNotReadEntireFileWithFormat');
        baseME = MException(m.Identifier,'%s',getString(m));
        % If all the cells in raw are the same length, textscan stopped at the
        % start of a line.  If the first few cells have length L, and the rest
        % L-1, then textscan stopped mid-line.  We can be helpful here.
        varlens = cellfun(@(x)size(x,1),raw);
        dvarlens = diff(varlens);
        locs = find(dvarlens);
        if isempty(locs) || (isscalar(locs) && dvarlens(locs)==-1)
            errLine = min(varlens) + 1 + numNonDataLines;
            m = message('MATLAB:readtable:ReadErrorOnLine',errLine);
            throw(addCause(baseME,MException(m.Identifier,'%s',getString(m))));
        % Otherwise, something else happened for which we have no specific advice.
        else
            throw(baseME);
        end
    end
end

if readVarNames
    % Search for any of the allowable conversions: a '%', followed
    % optionally by '*', followed optionally by 'nnn' or by 'nnn.nnn',
    % followed by one of the type specifiers or a character list or a
    % negative character list.  Keep the '%' and the '*' if it's there,
    % but replace everything else with the 'q' type specifier.
    specifiers = '(n|d8|d16|d32|d64|d|u8|u16|u32|u64|u|f32|f64|f|s|q|c|\[\^?[^\[\%]*\])';
    vnformat = regexprep(format,['\%([*]?)([0-9]+(.[0-9]+)?)?' specifiers],'%$1q');
    % Append a delimiter in case the last varname is missing, so we get a cell
    % containing an empty string, not an empty cell.
    vnline(end+1) = delimiter;
    varNames = textscan(vnline,vnformat,1,'delimiter',delimiter,'whitespace',whiteSpace,otherArgs{:});
    % If textscan was unable to read a varname, the corresponding cell
    % contains an empty cell.  Remove those.  This happens when trying to
    % put delimiters in the format string instead of using the 'Delimiter'
    % input, because they're just read as part of the string.  This is
    % different than if there is no var name -- in that case, the cell will
    % contain the empty string and be left alone.  setvarnames fixes those
    % later on.
    varNames = varNames(~cellfun('isempty',varNames));
    % Each cell in varnames contains another 1x1 cell containing a string,
    % get those out.  textscan ignores leading whitespace, remove trailing
    % whitspace here.
    varNames = deblank(cellfun(@(c) c{1}, varNames,'UniformOutput',false));
    
    if numel(varNames) ~= length(raw)
        error(message('MATLAB:readtable:ReadVarNamesFailed',file,length(raw),numel(varNames)));
    end
else
    % If reading row names, number remaining columns beginning from 1, we'll drop Var0 below.
    varNames = matlab.internal.table.dfltVarNames((1:length(raw))-readRowNames);
end
    
if isempty(raw) % i.e., if the file had no data
    t_data = cell(length(raw));
else
    varlen = unique(cellfun(@(x)size(x,1),raw));
    if ~isscalar(varlen)
        if inferFormat
            error(message('MATLAB:readtable:UnequalVarLengthsFromFileNoFormat'));
        else
            error(message('MATLAB:readtable:UnequalVarLengthsFromFileWithFormat'));
        end
    end
    
    if readRowNames
        rowNames = raw{1};
        if ischar(rowNames)
            rowNames = cellstr(rowNames);
        elseif isnumeric(rowNames)
            rowNames = cellstr(num2str(rowNames));
        elseif ~iscellstr(rowNames)
            error(message('MATLAB:readtable:RowNamesVarNotString', class(rowNames)));
        end
        raw(1) = [];
        dimNames = matlab.internal.table.dfltDimNames;
        if readVarNames, dimNames{1} = varNames{1}; end
        varNames(1) = [];
    end
    t_data = raw(:)';
end

t = table(t_data{:});

% Set the var names.  These will be modified to make them valid, and the
% original strings saved in the VariableDescriptions property.  Fix up
% duplicate or empty names.
t = setVarNames(t,varNames(:)',[],true,true,true);

if ~isempty(raw) && readRowNames
    t = setRowNames(t,rowNames,[],true,true); % Fix up duplicate or empty names
    t = setDimNames(t,dimNames,true,true); % Fix up duplicate or empty names
end


%-----------------------------------------------------------------------------
function raw = tdfread(file,delimiter,skip,treatAsEmpty)
%TDFREAD Read in text and numeric data from delimited file.

tab = sprintf('\t');
lf = sprintf('\n');
cr = sprintf('\r');
crlf = sprintf('\r\n');

% open file
fid = fopen(file,'rt'); % text mode: CRLF -> LF on windows (no-op on linux)
if fid == -1
    error(message('MATLAB:readtable:OpenFailed', file));
end
cleanFid = onCleanup(@()fclose(fid));

% now read in the data
[bigM,count] = fread(fid,Inf);
if count == 0
    raw = cell(1,0);
    return
elseif bigM(count) ~= lf
   bigM = [bigM; lf];
end
bigM = char(bigM(:)');

% replace CRLF with LF (for reading DOS files on linux, where text mode is a
% no-op). Replace CR with LF (for reading Mac files).
if ~ispc
    bigM = strrep(bigM,crlf,lf);
end
bigM = strrep(bigM,cr,lf);

% Skip header lines, before removing empty lines below.
if skip > 0
    i = find(bigM == lf,skip,'first');
    bigM(1:i(end)) = [];
end

% replace multiple embedded whitespace with a single whitespace, and multiple
% line breaks with one (removes empty lines in the middle and allows empty
% lines at the end).  remove insignificant whitespace before and after
% delimiters or line breaks.  remove leading empty line.
if delimiter == tab
%    matchexpr = {'([ \n])\1+' ' *(\n|\t) *' '^\n'};
   matchexpr = {'([\n])\1+' ' *(\n|\t) *' '^\n'};
elseif delimiter == ' '
%    matchexpr = {'([\t\n])\1+' '\t*(\n| )\t*' '^\n'};
   matchexpr = {'([\n])\1+' '\t*(\n| )\t*' '^\n'};
else
%    matchexpr = {'([\t\n])\1+' '\t*(\n| )\t*' '^\n'};
   matchexpr = {'([\n])\1+' ['[ \t]*(\n|\' delimiter ')[ \t]*'] '^\n'};
end
replexpr = {'$1' '$1' ''};
bigM = regexprep(bigM,matchexpr,replexpr);
delimitidx = find(bigM == delimiter);

% find out how many lines are there.
newlines = find(bigM == lf)';
nrows = length(newlines);

% find out how many data columns there are.
line1 = bigM(1:newlines(1)-1);
nvars = length(find(line1==delimiter)) + 1;

% check the size validation
if length(delimitidx) ~= nrows*(nvars-1)
   error(message('MATLAB:readtable:BadFileFormat'));
end
if nvars > 1
   delimitidx = (reshape(delimitidx,nvars-1,nrows))';
end

startlines = [zeros(nrows>0,1); newlines(1:nrows-1)];
delimitidx = [startlines, delimitidx, newlines];
fieldlengths = diff(delimitidx,[],2) - 1; fieldlengths = fieldlengths(:);
if any(fieldlengths < 0)
   error(message('MATLAB:readtable:BadFileFormat'));
end
maxlength = max(fieldlengths);
raw = cell(1,nvars);
for vars = 1:nvars
   xstr = repmat(' ',nrows,maxlength);
   x = NaN(nrows,1);
   xNumeric = true;
   for k = 1:nrows
       str = bigM(delimitidx(k,vars)+1:delimitidx(k,vars+1)-1);
       xstr(k,1:length(str)) = str;
       if xNumeric % numeric so far, anyways
           num = str2double(str);
           if isnan(num)
               % If the result was NaN, figure out why.  Note that because we
               % leave xstr alone, TreatAsEmpty only works on numeric columns.
               % That is what textscan does.
               if isempty(str) || strcmpi(str,'nan') || any(strcmp(str,treatAsEmpty))
                   % Leave x(k) alone, it has a NaN already.  We won't decide
                   % if this column is numeric or not based on this value.
               else
                   % NaN must have come from a failed conversion, treat this
                   % column as strings.
                   xNumeric = false;
               end
           else
               % Otherwise accept the numeric value.  Numeric literals in
               % TreatAsEmpty, such as "-99", have already been disallowed, so
               % it's OK to accept any numeric literal here.  Numeric literals
               % cannot be used with TreatAsEmpty.  That is what textscan
               % does.
               x(k) = num;
           end
       end
   end
   if ~xNumeric
       x = cellstr(xstr);
       x = regexprep(x,'^"(.*)"$','$1'); % remove enclosing double quotes like %q
   end
   raw{vars} = x;
end
