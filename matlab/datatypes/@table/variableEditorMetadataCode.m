function [metadataCode,warnmsg] = variableEditorMetadataCode(this,varName,index,propertyName,propertyString)
%   This function is undocumented and will change in a future release

% Generate MATLAB command to modify table metadata at positions defined
% by index input. 

%   Copyright 2011-2013 The MathWorks, Inc.

warnmsg = '';
if strcmpi('VariableNames',propertyName)
    % Validation
    if ~isvarname(propertyString)
         error(message('MATLAB:codetools:InvalidVariableName',propertyString));
    end
    if any(strcmp(this.Properties.VariableNames,propertyString))
        error(message('MATLAB:table:DuplicateVarNames',propertyString));
    end
    metadataCode = [varName '.Properties.VariableNames{' num2str(index) '} = ''' fixquote(propertyString) ''';'];
elseif strcmpi('VariableUnits',propertyName) || strcmpi('VariableDescriptions',propertyName)
    metadataCode = [varName '.Properties.' propertyName '{' num2str(index) '} = ''' fixquote(propertyString) ''';'];
end



