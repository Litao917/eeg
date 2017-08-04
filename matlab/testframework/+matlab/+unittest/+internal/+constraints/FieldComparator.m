classdef FieldComparator < matlab.unittest.internal.constraints.ContainerComparator
    % This class is undocumented.
    
    %  Copyright 2013 The MathWorks, Inc.
    
    properties (Abstract, Constant, Access=protected)
        Catalog;
    end
    
    methods (Abstract, Hidden, Access=protected)
        [bool, comparator] = haveAlreadyCompared(comparator, actVal, expVal)
    end
    
    methods
        function comp = FieldComparator(varargin)
            comp = comp@matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
        end
        
        function bool = satisfiedBy(comparator, actVal, expVal)
            comparator.validateSupports(expVal);
            
            bool = haveSameClass(actVal, expVal) && ...
                haveSameSize(actVal, expVal) && ...
                haveSameNumberOfFields(actVal, expVal) && ...
                actValHasAllFieldsInExpVal(actVal, expVal) && ...
                comparator.fieldsHaveSameContents(actVal, expVal);
        end
        
        function diag = getDiagnosticFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            comparator.validateSupports(expVal);
            
            if ~haveSameClass(actVal, expVal)
                diag = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
                
            elseif ~haveSameSize(actVal, expVal)
                diag = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(comparator, ...
                    DiagnosticSense.Positive, actVal, expVal);
                
            elseif ~haveSameNumberOfFields(actVal, expVal)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(comparator, ...
                    DiagnosticSense.Positive, fieldnames(actVal), fieldnames(expVal));
                diag.addCondition(comparator.Catalog.getString('FieldCountMismatch'));
                diag.ActValHeader = comparator.Catalog.getString('ActualFields');
                diag.ExpValHeader = comparator.Catalog.getString('ExpectedFields');
                
            elseif ~actValHasAllFieldsInExpVal(actVal, expVal)
                missing = findFirstMissingField(actVal, expVal);
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(comparator, ...
                    DiagnosticSense.Positive, [], sprintf('''%s''', missing));
                diag.addCondition(comparator.Catalog.getString('MissingField'));
                diag.ExpValHeader = comparator.Catalog.getString('ExpectedField');
                diag.DisplayActVal = false;
                
            else
                [bool, subsrefPath, actField, expField, comp] = findFirstDifferingField(comparator, actVal, expVal);
                
                if bool
                    diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(comparator, ...
                        DiagnosticSense.Positive);
                else
                    diag = comp.getDiagnosticFor(actField, expField);
                    diag.pushOnRecursivePath(subsrefPath);
                end
            end
        end
    end
    
    methods (Access=private)
        function validateSupports(comparator, expVal)
            % The comparator must support the expected value.
            if ~comparator.supports(expVal)
                mnemonic = 'UnsupportedType';
                error(sprintf('%s:%s',comparator.Catalog.Identifier, mnemonic), ...
                    comparator.Catalog.getString(mnemonic));
            end
        end
        
        function bool = fieldsHaveSameContents(comparator, actVal, expVal)
            bool = comparator.findFirstDifferingField(actVal, expVal);
        end
        
        function [bool, subsrefPath, actField, expField, comp] = findFirstDifferingField(comparator, actVal, expVal)
            % Finds the first pair of mismatching fields, the subsref path
            % to get there, and the comparator to use on the dereferenced
            % fields. If all fields match, return all empty matrices.
            
            bool = true;
            
            subsrefPath = '';
            actField = [];
            expField = [];
            comp = [];
            
            if isscalar(expVal)
                % Check for cycles where the actual and expected values
                % have already been examined in recursion
                [alreadyCompared, comparator] = comparator.haveAlreadyCompared(actVal, expVal);
                if alreadyCompared
                    return;
                end
                
                % Scalar objects
                fields = fieldnames(expVal);
                for n = 1:length(fields)
                    actField = actVal.(fields{n});
                    expField = expVal.(fields{n});
                    comp = comparator.getComparatorFor(expField);
                    bool = comp.satisfiedBy(actField, expField);
                    if ~bool
                        subsrefPath = strcat('.', fields{n});
                        return;
                    end
                end
            else
                % Array of objects
                for n = 1:numel(expVal)
                    actField = actVal(n);
                    expField = expVal(n);
                    bool = comparator.fieldsHaveSameContents(actField, expField);
                    if ~bool
                        comp = comparator;
                        subsrefPath = sprintf('(%d)', n);
                        return;
                    end
                end
            end
        end
    end
end

function result = haveSameClass(actVal, expVal)
result = strcmp(class(actVal), class(expVal));
end

function result = haveSameSize(actVal, expVal)
result = isequal(size(expVal), size(actVal));
end

function result = haveSameNumberOfFields(actVal, expVal)
result = isequal(numel(fieldnames(actVal)), numel(fieldnames(expVal)));
end

function result = actValHasAllFieldsInExpVal(actVal, expVal)
result = isempty(findFirstMissingField(actVal, expVal));
end

function missingField = findFirstMissingField(actVal, expVal)
% Find the name of the first field that is in expVal but not in actVal. If
% actVal contains all fields that exist in actVal, return an empty string.

actValFields = fieldnames(actVal);
expValFields = fieldnames(expVal);

diff = setdiff(expValFields, actValFields);
if isempty(diff)
    missingField = '';
else
    missingField = diff{1};
end
end