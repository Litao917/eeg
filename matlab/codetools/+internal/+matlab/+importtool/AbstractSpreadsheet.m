% Copyright 2011-2013 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version.

classdef AbstractSpreadsheet < handle & JavaVisible
    properties(SetAccess = protected)
        FileName;
        WorksheetStructure;
    end
    
    
    properties (Hidden=true, SetAccess = protected)
        HasFile = false;
        ErrorOccurred = false;
    end
    
    properties(SetAccess = protected, GetAccess = public)
        DstWorkspace = 'caller';
    end
     
    methods 
        function setDstWorkspace(obj,newWksp)
            obj.DstWorkspace = newWksp;
        end
        
        function [data,raw] = ImportDataBlock(obj, sheetname, range, selectedExcludedColumns, useValue2)
            import com.mathworks.mlwidgets.importtool.*;
            
            if nargin<=3
                [data,raw,dateData] = Read(obj, sheetname, range);
            else
                [data,raw,dateData] = Read(obj, sheetname, range, useValue2);
            end
            
            % Non empty data must be converted to DateCells.
            if useValue2 && ~isempty(dateData)
                if ~isempty(selectedExcludedColumns)                   
                    % Exclude cell array columns from data conversion
                    raw = reshape(raw,size(data));
                    rawNumeric = raw(:,~selectedExcludedColumns);
                    dateDataNumeric = dateData(:,~selectedExcludedColumns);
                    if ~isempty(dateDataNumeric) && ~isempty(rawNumeric)
                         rawNumeric  = cell(com.mathworks.mlwidgets.importtool.DateCell.addDateCells(rawNumeric(:),dateDataNumeric(:)));
                    end
                    % Overwrite raw data with converted dates in numeric
                    % columns.
                    raw(:,~selectedExcludedColumns) = reshape(rawNumeric,size(raw(:,~selectedExcludedColumns)));
                    raw = raw(:);
                else
                    raw = cell(com.mathworks.mlwidgets.importtool.DateCell.addDateCells(raw(:),dateData(:)));
                end
            end            
        end
        
        function [raw,data,varNames,columnTargetTypes,columnVarNames] = ImportSheetData(obj, ...
                varNames, sheetname, range, rules, columnTargetTypes, columnVarNames)
            %IMPORTSHEETDATA
            %
            import com.mathworks.mlwidgets.importtool.*;
            
            % Create default excluded column arrays for range blocks
            haveColumnTypeData = ~isempty(columnTargetTypes);
            if ~haveColumnTypeData
                columnTargetTypes = repmat({repmat({''},size(range{1}))},size(range));
            end

            % ImportData returns the names of variables and their sizes
            % which have not been excluded as a result of the application
            % of a column exclusion rule.
           
            useValue2 = false;
            if ~isempty(rules)
                for k=1:length(rules)
                    if rules{k}.codeGenUsesDates
                        useValue2 = true;
                        break
                    end
                end      
            end
            % The Read method and xlsread only work on one contiguous 
            % block. Loop through each contiguous block in the range 
            % cell array building up the combined arrays "data" and "raw"
            excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes{1}{1},'CELL_ARRAY');
            [blockData,blockRaw]  = ImportDataBlock(obj, sheetname, ...
                char(range{1}{1}),excludedColumns,useValue2);
            blockRaw = reshape(blockRaw,size(blockData)); 
            for colBlock = 2:length(range{1})
                %excludedColumns = strcmp(columnTargetTypes{1}{colBlock},'targettype.cellarrays');
                excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes{1}{colBlock},'CELL_ARRAY');
                 [blockData_,blockRaw_]  = ImportDataBlock(obj, sheetname, ...
                    char(range{1}{colBlock}),excludedColumns,useValue2);
                  blockRaw_ = reshape(blockRaw_,size(blockData_));
                  blockData = [blockData blockData_]; %#ok<AGROW>
                  blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
            end
            data = blockData;
            raw = blockRaw;            
            for rowBlock = 2:length(range)
                %excludedColumns = strcmp(columnTargetTypes{rowBlock}{1},'targettype.cellarrays');
                excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes{rowBlock}{1},'CELL_ARRAY');
                [blockData,blockRaw]  = ImportDataBlock(obj, sheetname, ...
                    char(range{rowBlock}{1}),excludedColumns,useValue2);
                blockRaw = reshape(blockRaw,size(blockData)); 
                for colBlock = 2:length(range{1})
                    %excludedColumns = strcmp(columnTargetTypes{rowBlock}{colBlock},'targettype.cellarrays');
                    excludedColumns = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                        columnTargetTypes{rowBlock}{colBlock},'CELL_ARRAY');
                     [blockData_,blockRaw_]  = ImportDataBlock(obj, sheetname, ...
                        char(range{rowBlock}{colBlock}),excludedColumns,useValue2);
                      blockRaw_ = reshape(blockRaw_,size(blockData_));
                      blockData = [blockData blockData_]; %#ok<AGROW>
                      blockRaw = [blockRaw blockRaw_]; %#ok<AGROW>
                end
                data = [data;blockData]; %#ok<AGROW>
                raw = [raw;blockRaw]; %#ok<AGROW>
            end
            
            %Apply post-processing rules to columns.
            %
            %Check columns for cell arrays that must be excluded from rule
            %processing.
            columnTargetTypes = [columnTargetTypes{1}{:}]; % Columns from top line of contiguous blocks
            %cols = strcmp(cols,'targettype.cellarrays');
            cols = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                columnTargetTypes,'CELL_ARRAY');
            if any(cols) % Column exclusion input defined
                raw = reshape(raw,size(data));
                if ~isempty(columnVarNames)
                    [rawPostRules,~,ruleExcludedRows,ruleExcludedColumns] = internal.matlab.importtool.AbstractSpreadsheet.applyRules(...
                        rules,raw(:,~cols),data(:,~cols),columnVarNames(~cols));
                else
                    [rawPostRules,~,ruleExcludedRows,ruleExcludedColumns] = internal.matlab.importtool.AbstractSpreadsheet.applyRules(...
                        rules,raw(:,~cols),data(:,~cols),varNames(~cols));
                end
                raw(ruleExcludedRows,:) = [];
                
                % If columns are excluded as a result of applying a
                % column exclusion rule, remove those columns from the
                % raw array and varNames
                if any(ruleExcludedColumns)
                    I = find(~cols); % Indices of numeric cols
                    % I(ruleExcludedColumns) - indices of cols excluded by rules
                    
                    %Remove excluded columns from variable name lists
                    if ~isempty(columnVarNames)
                        if(isequal(columnVarNames, varNames))
                            %Happens when importing variables per column 
                            varNames(I(ruleExcludedColumns)) = [];
                        end
                        columnVarNames(I(ruleExcludedColumns)) = [];
                    elseif iscell(varNames)
                        varNames(I(ruleExcludedColumns)) = [];
                    end
                    
                    %Remove excluded columns from column target type list
                    columnTargetTypes(I(ruleExcludedColumns)) = [];
                    
                    %Remove excluded columns from the data
                    data(:,I(ruleExcludedColumns)) = [];
                    raw(:,I(~ruleExcludedColumns)) = rawPostRules;
                    raw(:,I(ruleExcludedColumns)) = [];
                else
                    raw(:,~cols) = rawPostRules;
                end
            else
                [raw,varNames] = internal.matlab.importtool.AbstractSpreadsheet.applyRules(rules,raw,data,varNames);
            end
        end
        
        function [varNames,varSizes] = ImportData(obj, varNames, allocationFcn, sheetname, range, rules, columnTargetTypes, columnVarNames)
            %IMPORTDATA
            %
            
            try
                %Extract the data from the sheet and apply any rules
                [raw,data,varNames,columnTargetTypes,columnVarNames] = ImportSheetData(obj,varNames, sheetname, range, rules, columnTargetTypes, columnVarNames);
                                
                % Allocate the data to variables of the requested type
                if ischar(allocationFcn)
                    allocationFcn = str2func(allocationFcn);
                end
                outputVars = feval(allocationFcn,raw,data,columnTargetTypes,columnVarNames);
                
                %Assign the imported data to workspace variables
                varSizes = cell(length(varNames),1);
                for k=1:length(varNames)
                    % Convert any java objects (probably a result of DateCells) to strings
                    if iscell(outputVars{k})
                        I = cellfun(@(x) isjava(x),outputVars{k});
                        outputVars{k}(I) = cellfun(@(x) char(x.toString()),...
                            outputVars{k}(I),'UniformOutput',false);
                    end
                    assignin(obj.DstWorkspace,varNames{k},outputVars{k});
                    varSizes{k,1} = size(outputVars{k});
                end
            catch me
                internal.matlab.importtool.AbstractSpreadsheet.manageImportErrors(me);
            end
        end
        
        function headerRow = GetDefaultHeaderRow(this,sheetname)
           cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
           if ~cachedWorksheetStructExists 
               this.init(sheetname);
           end
           headerRow = this.WorksheetStructure.(genvarname(sheetname)).HeaderRow;  
        end
        
        function numericContainerColumns = GetNumericContainerColumns(this,sheetname)
           % Use a subset of sheet data to define defaults for which columns 
           % in a column vector import should be stored in numeric column
           % vectors (vs. cell vectors)
           cachedWorksheetStructExists = ~isempty(this.WorksheetStructure) && isfield(this.WorksheetStructure,sheetname);
           if ~cachedWorksheetStructExists 
               this.init(sheetname);
           end
           numericContainerColumns = this.WorksheetStructure.(genvarname(sheetname)).NumericContainerColumns;  
        end        
        
        % Return the recommended initial selection for the sheet.
        function initialSelection = GetInitialSelection(obj,sheetname)
            if isempty(obj.WorksheetStructure) || ~isfield(obj.WorksheetStructure,genvarname(sheetname))
                obj.init(sheetname);
            end    
            initialSelection = obj.WorksheetStructure.(genvarname(sheetname)).InitialSelection;                   
        end
    end
    
    methods (Static, Access = public)
        function obj = createSpreadsheet
            % If there is no ActiveX Excel server on this machine,
            % use BasicMode where the spreadsheet data is loaded inside
            % the BasicSheetData property by calling xlsread
            
            if ~internal.matlab.importtool.AbstractSpreadsheet.alwaysUseBasicMode
                try
                    application = actxserver('excel.application');              
                    application.DisplayAlerts = 0;
                    obj = internal.matlab.importtool.COMSpreadsheet(application);
                    obj.Workbook = [];
                catch me %#ok<NASGU>
                    obj = internal.matlab.importtool.InMemSpreadsheet;
                end
            else
                obj = internal.matlab.importtool.InMemSpreadsheet;
            end
        end
        
        function state = alwaysUseBasicMode(state)
            persistent staticAlwaysUseBasicMode;
            
            if nargin>=1
               staticAlwaysUseBasicMode = state;
            elseif isempty(staticAlwaysUseBasicMode)
               staticAlwaysUseBasicMode = false;
            end
            state = staticAlwaysUseBasicMode;
            
        end
               
        function manageImportErrors(err)
            %MANAGEIMPORTERRORS
            %
            
            rethrowErrList = {...
                'MATLAB:timeseries:tsChkTime:matrixtime'; ...
                'MATLAB:timeseries:tsChkTime:inftime'; ...
                'MATLAB:timeseries:tsChkTime:realtime'};
            if any(strcmp(err.identifier,rethrowErrList))
                err = MException(message('MATLAB:codetools:errImport_SpecificImportError',err.message));
            else
                err = MException(message('MATLAB:codetools:errImport_GenericImportError'));
            end
            throw(err)
        end
    end
    
    methods (Abstract)
      init(obj,sheetname)
      [data,raw,dateData] = Read(obj, sheetname, range)
      dimensions = GetSheetDimensions(obj,sheetname)
      Open(obj, filename)
      [message, description, format] = GetInfo(obj)
      columnNames = getDefaultColumnNames(this,sheetname,row,ncols,avoidShadow)
      Close(obj)
    end
    
    methods (Static, Access = protected)
        function data = parse_data(data)
            % PARSE_DATA parse data from raw cell array into a numeric array and a text
            % cell array.
            %
            %==========================================================================
            
            if isempty(data)
                return
            end
            
            % Ensure data is in cell array
            if ischar(data)
                data = cellstr(data);
            elseif isnumeric(data) || islogical(data)
                data = num2cell(data);
            end
            
            % Find non-numeric entries in data cell array
            vIsText = cellfun('isclass',data,'char');
            
            
            % Place NaN in empty numeric cells
            vIsNaN = strcmpi(data,'nan') | vIsText;
            if any(vIsNaN(:))
                data(vIsNaN) = {NaN};
            end
            
            % Extract numeric data
            rows = size(data,1);
            m = cell(rows,1);
            % Concatenate each row first
            for n=1:rows
                m{n} = cat(2,data{n,:});
            end
            % Now concatenate the single column of cells into a matrix
            data = cat(1,m{:});
            
        end
        
        function b = findColumnTargetTypes(columnTypes,cType)
            %FINDCOLUMNTARGETTYPES
            %
        
            switch cType
                case 'CELL_ARRAY'
                    b = cellfun(@(x) x.isCellArray, columnTypes);
                case 'NUMERIC_ARRAY'
                    b = cellfun(@(x) x.isNumericArray, columnTypes);
                case 'TIME_ARRAY'
                    b = cellfun(@(x) x.isTimeArray, columnTypes);
                otherwise
                    error('id:id','Unknown column type');
            end
        end
    end
    
    methods (Static)
        % NonNumericReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [replaceArray,replaceIndexes] = nonNumericReplaceFcn(rule,data,raw)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            replaceIndexes = isnan(data(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x),raw(:));
            replaceArray(replaceIndexes) = rule.getReplacementNumber();
            replaceArray = replaceArray(:);
        end

        
        % StringReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [replaceArray,replaceIndexes] = stringReplaceFcn(rule,~,rawData)
            targetStr = char(rule.getTargetString);
            % If the target string contains a wildcard, convert the string
            % to a regular expression and use regular expression matching.
            targetStrRegesp = regexptranslate('wildcard',targetStr);
            if strcmp(targetStr,targetStrRegesp)
                replaceIndexes = cellfun(@(x) ischar(x) && strcmp(x,targetStr),rawData);
            else
                replaceIndexes = cellfun(@(x) ischar(x) && ...
                    isequal(regexp(x,targetStrRegesp,'once'),1),rawData);
            end
            replaceArray(replaceIndexes) = rule.getReplacementNumber();
            replaceArray = replaceArray(:);
        end
        
        % BlankReplacementRule applyFnc. WorksheetRule of RuleType 
        % REPLACE must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [replaceArray,replaceIndexes] = blankReplaceFcn(rule,~,rawData)
            replaceIndexes = findBlankCells(rawData);
            replaceArray(replaceIndexes) = rule.getReplacementNumber();
            replaceArray = replaceArray(:);
        end
        
        % ExcelDateFunction applyFcn. WorksheetRule of RuleType 
        % CONVERT must return a double array (replaceArray)
        % containing replaced content and a boolean array (replaceIndexes)
        % identifying the location of replaced content. Both these arrays
        % must be the same size as the data input. replaceArray may also
        % contain non-replaced content, which will be ignored.
        function [replaceArray,replaceIndexes] = excelDateFunctionFcn(~,~,rawData)
            dateNumArray = NaN(size(rawData));
            replaceIndexes = cellfun('isclass',rawData,'com.mathworks.mlwidgets.importtool.DateCell');
            ind = find(replaceIndexes);
            for k=1:length(ind)
                dateNumArray(ind(k)) = rawData{ind(k)}.getDateNum;
            end
            replaceArray = dateNumArray(:);          
        end

        % NonNumericRowExclusionRule applyFnc. WorksheetRule of RuleType 
        % ROWEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % row to be excluded. excludeIndexes must be the same size as the
        % data input.
        function excludeIndexes = excludeRowFcn(~,data,raw)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            replaceIndexes = isnan(data(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x),raw(:));
            excludeIndexes(replaceIndexes) = true;
        end

        % NonNumericColumnExclusionRule applyFnc. WorksheetRule of RuleType 
        % COLUMNEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function excludeIndexes = excludeColumnFcn(~,data,raw)
            % Do not stomp on cells that have been converted to NaN
            % (g716691)
            replaceIndexes = isnan(data(:)) & ...
                cellfun(@(x) isempty(x) || ~isnumeric(x) || ~isnan(x),raw(:));
            excludeIndexes(replaceIndexes) = true;
        end
 
        % BlankExcludeColumnRule applyFnc. WorksheetRule of RuleType 
        % COLUMNEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function excludeIndexes = blankExcludeColumnFcn(~,~,rawData)
            I = findBlankCells(rawData);
            excludeIndexes(I) = true;
            J=~I & cellfun('isclass',rawData,'char');
            excludeIndexes(J) = cellfun(@(x) all(x==' '),rawData(J));
        end
        
        % BlankExcludeRowRule applyFnc. WorksheetRule of RuleType 
        % ROWEXCLUDE must return a boolean array (excludeIndexes)
        % identifying the location of cells which will cause the corresponding
        % column to be excluded. excludeIndexes must be the same size as the
        % data input.
        function excludeIndexes = blankExcludeRowFcn(~,~,rawData)
            I = findBlankCells(rawData);
            excludeIndexes(I) = true;
            J=~I & cellfun('isclass',rawData,'char');
            excludeIndexes(J) = cellfun(@(x) all(x==' '),rawData(J));
        end
        
        % HeaderRowExcludeRule applyFnc. NoOp just to keep in model. 
        function excludeIndexes = headerExcludeRowFcn(~,~,~)
            excludeIndexes = [];
        end
        
        % Convert an Excel range string of the form "*:*" to MATLAB row and column
        % arrays.        
        function [rows,cols] = excelRangeToMatlab(range)
            colon = strfind(range,':');
            block1 = range(1:colon-1);
            block2 = range(colon+1:end);
            rows = str2double(block1(regexp(block1,'\d'))):str2double(block2(regexp(block2,'\d')));
            cols = base27dec(block1(regexp(block1,'\D'))):base27dec(block2(regexp(block2,'\D')));
        end
        
        
        
        function [raw,varNames,excludedRows,excludedColumns] = applyRules(rules,raw,data,varNames)
            
            matrixDims = size(raw);
            includedRows = 1:size(raw,1);
            includedColumns = 1:size(raw,2);
            excludedRows = true(size(raw,1),1);
            excludedColumns = true(size(raw,2),1);
            raw = raw(:);

            
            % Loop through each of the rules, successively replacing and excluding data
            % from the arrays "raw" and "data"
            for k=1:length(rules)
                if rules{k}.isRowExcludeType
                    excludeIndexes = false(size(raw));
                    excludeIndexes(feval(char(rules{k}.getApplyFcn),rules{k},data,raw)) = true;
                    shapedRawMatrix = reshape(raw,matrixDims);
                    shapedExcludeIndexes = reshape(excludeIndexes,matrixDims);
                    I = any(shapedExcludeIndexes,2);
                    shapedRawMatrix(I,:) = [];
                    data(I,:) = [];
                    matrixDims(1) = matrixDims(1)-sum(any(shapedExcludeIndexes,2));
                    raw = shapedRawMatrix(:);
                    includedRows(I) = [];
                elseif rules{k}.isColumnExcludeType
                    excludeIndexes = false(size(raw));
                    excludeIndexes(feval(char(rules{k}.getApplyFcn),rules{k},data,raw)) = true;
                    shapedRawMatrix = reshape(raw,matrixDims);
                    shapedExcludeIndexes = reshape(excludeIndexes,matrixDims);
                    % Remove excluded columns from the list of variable names
                    I = any(shapedExcludeIndexes,1);
                    if size(data,2)==length(varNames)
                        varNames(I) = [];
                    end
                    shapedRawMatrix(:,I) = [];
                    data(:,I) = [];
                    matrixDims(2) = matrixDims(2)-sum(any(shapedExcludeIndexes,1));
                    raw = shapedRawMatrix(:);
                    includedColumns(I) = [];
                else
                    [replaceArray,replaceIndexes] = feval(char(rules{k}.getApplyFcn),rules{k},data,raw);
                    raw(replaceIndexes) = num2cell(replaceArray(replaceIndexes));
                    data(replaceIndexes) = replaceArray(replaceIndexes);
                    
                end
            end
            raw = reshape(raw,matrixDims);
            excludedRows(includedRows) = false;
            excludedColumns(includedColumns) = false;
        end
        
        
        function outputVars = columnVectorAllocationFcn(raw,~,columnTargetTypes,~)
            %COLUMNVECTORALLOCATIONFCN
            %
            outputVars = cell(1,size(raw,2));
            for col=1:length(outputVars)
                if columnTargetTypes{col}.isCellArray
                    outputVars{col} = raw(:,col);
                else
                    outputVars{col} = cell2mat(raw(:,col));
                end
            end
        end
           
        function outputVars = datasetAllocationFcn(raw,data,columnTargetTypes,columnVarNames)
            %DATASETALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,data,columnTargetTypes,columnVarNames);
            outputVars = {dataset(columnData{:},'VarNames',columnVarNames)};
        end

        function outputVars = tableAllocationFcn(raw,data,columnTargetTypes,columnVarNames)
            %TABLEALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,data,columnTargetTypes,columnVarNames);
            outputVars = {table(columnData{:},'VariableNames',columnVarNames)};
        end
        
        function outputVars = timeseriesAllocationFcn(raw,data,columnTargetTypes,columnVarNames)
            %TIMESERIESALLOCATIONFCN
            %
            columnData = internal.matlab.importtool.AbstractSpreadsheet.columnVectorAllocationFcn(raw,data,columnTargetTypes);
            idxT = internal.matlab.importtool.AbstractSpreadsheet.findColumnTargetTypes(...
                    columnTargetTypes,'TIME_ARRAY');
            if any(idxT)
                ts = timeseries(cell2mat(columnData(~idxT)),cell2mat(columnData(idxT)));
            else
                ts = timeseries(cell2mat(columnData(~idxT)));
           end
            ts.DataInfo.UserData = struct('ChannelNames', {columnVarNames(~idxT)});
            outputVars = {ts};
        end

        function outputVars = matrixAllocationFcn(raw,~,~,~)
            %MATRIXALLOCATIONFCN
            %            
            outputVars = {cell2mat(raw)};
        end

        function outputVars = cellArrayAllocationFcn(raw,~,~,~)
            %CELLARRACYALLOCATIONFCN
            %
            outputVars = {raw};
        end
        
        % Estimate the location of the default header row from a raw cell
        % array and an optional data array
        function headerrow = getHeaderRowFromData(raw,data)
            firstColumnWithData = find(any(~cellfun('isempty',raw),1),1,'first');
            if isempty(firstColumnWithData)
                headerrow = 1;
                return
            end
            raw = raw(:,firstColumnWithData:end);
            if nargin>=2 && ~isempty(data)
                data = data(:,firstColumnWithData:end);
                stringRows = find(all(isnan(data) & cellfun('isclass',raw,'char'),2));
            else
                Inumeric = cellfun('isclass',raw,'double');
                Inonnumeric = cellfun('isclass',raw,'char') | (Inumeric & cellfun(@(x) isscalar(x) && isnan(x),raw));
                stringRows = find(all(Inonnumeric,2));
            end

            if isempty(stringRows)
                headerrow = 1;
                return
            end
            % TO Explain logic below
            titleRow = find(sum(cellfun(@(x) ischar(x) && ~isempty(regexp(x,'^[a-zA-Z].*','once')),...
                     raw(stringRows,:)),2)>size(raw,2)/2,1,'first');

            if isempty(titleRow)
                headerrow = stringRows(1);
            else  
                headerrow = stringRows(titleRow);
            end
        end
            
        function numericContainerColumns = getNumericContainerColumnsFromData(raw,data,dateData)
            % Use a subset of sheet data to define defaults for which columns
            % in a column vector import should be stored in numeric column
            % vectors (vs. cell vectors)
            if nargin>=3 && ~isempty(data) && ~isempty(dateData)
                % Numeric columns have at least one number or date
                numericContainerColumns = sum(~isnan(data)|~isnan(dateData),1)>=1;
            elseif nargin>=2 && ~isempty(data)
                % Numeric columns have at least one number
                numericContainerColumns = sum(~isnan(data),1)>=1;
            else
                % Numeric columns have at least one number
                Inumeric = cellfun('isclass',raw,'double');
                numericContainerColumns = sum(Inumeric,1)>size(raw,1)/2;
            end
        end
    end 
end

function d = base27dec(s)
    %   BASE27DEC(S) returns the decimal of string S which represents a number in
    %   base 27, expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is
    %   no zero so strictly we have hybrid base26, base27 number system.
    %
    %   Examples
    %       base27dec('A') returns 1
    %       base27dec('Z') returns 26
    %       base27dec('IV') returns 256
    %-----------------------------------------------------------------------------

    s = upper(s);
    if length(s) == 1
        d = s(1) -'A' + 1;
    else
        cumulative = 0;
        for i = 1:numel(s)-1
            cumulative = cumulative + 26.^i;
        end
        indexes_fliped = 1 + s - 'A';
        indexes = fliplr(indexes_fliped);
        indexes_in_cells = num2cell(indexes);
        d = cumulative + sub2ind(repmat(26, 1,numel(s)), indexes_in_cells{:});
    end
end

function blankIndices = findBlankCells(rawData)
        
    blankIndices = cellfun('isempty',rawData);
    Iblank = find(cellfun('isclass',rawData,'char'));
    if ~isempty(Iblank)
        Iblank(cellfun(@(x) ~all(x==' '),rawData(Iblank))) = [];
        blankIndices(Iblank) = true;
    end
end
