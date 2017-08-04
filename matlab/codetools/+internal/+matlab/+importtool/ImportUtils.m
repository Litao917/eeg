% Copyright 2012-2013 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version. 

classdef ImportUtils
    methods (Static)
        function columnNames = getDefaultColumnNames(wsVarNames,data,ncols,avoidShadow)
            if nargin<=2 || ncols==-1
                ncols = size(data,2);
            end
            columnNames = cell(1,ncols-1);
            derivedColumnNames = {};
            for col=1:ncols
                if ~isempty(data{1,col}) && ischar(data{1,col})
                    cellData = regexprep(data{1,col},'''|"|,|\s|\n|\r','');
                else 
                    cellData = [];
                end
                stringHeader = ~isempty(cellData) && ((cellData(1)>=char('a') && cellData(1)<=char('z')) || ...
                       (cellData(1)>=char('A') && cellData(1)<=char('z')));
                if stringHeader
                   I = (cellData>=char('a') & cellData<=char('z')) | ...
                       (cellData>=char('A') & cellData<=char('Z')) | ...
                       (cellData>=char('0') & cellData<=char('9')) | ...
                       cellData=='_';
                   cellData(~I) = [];
                   colName = cellData;
                else
                   colName = sprintf('VarName%d',col);
                end
                if length(colName)>namelengthmax
                    varName = colName(1:namelengthmax);
                else
                    varName  = colName;
                end 
                % The exist function (below) is used to ensure that 
                % default variable names do not conflict with MATLAB
                % functions, classes, builtins etc. Note, that we do
                % not care about exist(varName)==1 because conflicts with
                % variables in this workspace are not important.
                if avoidShadow && (internal.matlab.importtool.ImportUtils.variableExists(varName)>1 ...
                        || any(strcmp(varName,[wsVarNames(:); derivedColumnNames])))
                   numericSuffixStart = regexp(varName,'\d*$','once');
                   if ~isempty(numericSuffixStart)
                       varNameRoot = varName(1:numericSuffixStart-1);
                   else
                       varNameRoot = varName;
                   end
                   suffixDigit = 1;
                   while internal.matlab.importtool.ImportUtils.variableExists([varNameRoot num2str(suffixDigit)])>1 || ...
                           any(strcmp([varNameRoot num2str(suffixDigit)],[wsVarNames(:); columnNames(:)]))
                       suffixDigit=suffixDigit+1;
                   end
                   varName = [varNameRoot num2str(suffixDigit)];
                end
                columnNames{col}  = varName;
                if stringHeader
                    derivedColumnNames =  [derivedColumnNames;{varName}]; %#ok<AGROW>
                end
            end 
        end
        
        function val = variableExists(varName)
            val = 0;
            if exist(varName, 'var') % Check for variables
                val = 1;
            else
                whichVarName = which(varName);
                
                if ~isempty(whichVarName)
                    if ~isempty(regexp(whichVarName, ...
                            ['(.*[\\/]' varName '\.m)'], 'match'))
                        val = 2;
                    elseif ~isempty(regexp(whichVarName, ...
                            ['(.*[\\/]' varName '\))'], 'match'))
                        val = 3;
                    end
                    
                    if (val > 0) && ~isempty(strfind(whichVarName, '@'))
                        % The varName only exists as a function within a
                        % Matlab class folder.  Don't consider this as an
                        % existing variable, since it can't be called
                        % directly on the command line.
                        val = 0;
                    end
                end
            end
        end
    end
end