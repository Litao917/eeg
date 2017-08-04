classdef ConstraintDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % ConstraintDiagnostic - Diagnostics specific to matlab.unittest constraints.
    %
    %   The ConstraintDiagnostic class provides various textual fields that are
    %   common to most constraints. These fields may be turned on or off
    %   depending on applicability.
    %
    %   A constraint diagnostic should not be instantiated directly. Instead,
    %   the ConstraintDiagnosticFactory should be used to create new constraint
    %   diagnostics. There are several factory methods available for creating
    %   constraint diagnostics for different situations. See
    %   ConstraintDiagnosticFactory for more information.
    %
    %   Constraint diagnostics consist of the following fields, displayed in
    %   the specified order:
    %
    %       * Description    - String containing general diagnostic
    %                          information.
    %       * Conditions     - String consisting of a list of any number of
    %                          conditions describing the causes of the failure.
    %                          Each item in the list is indented and preceded
    %                          by an arrow '--> ' marker.
    %       * Actual Value   - the actual value from the associated constraint.
    %                          The raw value may be specified, and any
    %                          truncation or formatting necessary for display
    %                          will be performed.
    %       * Expected Value - The expected value from the associated
    %                          constraint (if applicable). If the constraint
    %                          does not have an expected value, this field may
    %                          be turned off.
    %
    %   Each of the fields (except for the description) has an associated
    %   header that is displayed directly above the field. The header provides
    %   an opportunity to customize an explanation of the field. Default
    %   headers are provided, but may be overridden.
    %
    %   All constraints are required to return ConstraintDiagnostics from the
    %   getDiagnosticFor method. This is not strictly enforced through the
    %   class structure, but will result in additional error diagnostics when
    %   used with boolean constraints or actual value proxies, which expect
    %   constraint diagnostics.
    %
    %   ConstraintDiagnostic properties:
    %       DisplayDescription - boolean controlling display of description field
    %       Description        - string containing general diagnostic information
    %       DisplayConditions  - boolean controlling display of conditions field
    %       ConditionsCount    - number of conditions in the condition list
    %       Conditions         - string containing formatted condition list
    %       DisplayActVal      - boolean controlling display of actual value field
    %       ActValHeader       - string containing header information for the actual value
    %       ActVal             - string containing the actual value
    %       DisplayExpVal      - boolean controlling display of expected value field
    %       ExpValHeader       - string containing header information for the expected value
    %       ExpVal             - string containing the expected value (if applicable)
    %
    %   ConstraintDiagnostic methods:
    %       addCondition             - method to add a condition to the condition list
    %       addConditionsFrom        - method to add conditions from another ConstraintDiagnostic
    %       diagnose                 - execute diagnostic action for the instance
    %       getDisplayableString     - utility method used to truncate the display of large arrays
    %       getPreDescriptionString  - hook method for adding fields prior to Description field
    %       getPostDescriptionString - hook method for adding fields subsequent to Description field
    %       getPostConditionsString  - hook method for adding fields subsequent to Conditions field
    %       getPostActValString      - hook method for adding fields subsequent to ActVal field
    %       getPostExpValString      - hook method for adding fields subsequent to ExpVal field
    %
    %   See also
    %       Diagnostic
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2010-2012 The MathWorks, Inc.
    
    properties (Access=private)
        ConditionsList = {};
    end
    
    properties(Constant, Access=private)
        INDENT = '    ';
    end
    
    properties
        % DisplayDescription - boolean controlling display of description field
        %
        %   By default, the description is not displayed and the value of this property
        %   is false.
        DisplayDescription = false;
        
        % Description - string containing general diagnostic information
        Description;
        
        % DisplayConditions - boolean controlling display of conditions field
        %
        %   By default, the conditions are not displayed and the value of this property
        %   is false. Note that even if DisplayConditions is set to true, if there are
        %   no conditions on the conditions list, neither the conditions header or the
        %   conditions list will be displayed.
        DisplayConditions = false;
        
        % DisplayActVal - boolean controlling display of actual value field
        %
        %   By default, the actual value is not displayed and the value of this property
        %   is false.
        DisplayActVal = false;
        
        % ActValHeader - string containing header information for the actual value
        %
        %   Contains the following default header:
        %   'Actual Value:'
        ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualValue'));
        
        % ActVal - string containing the actual value
        ActVal;
        
        % DisplayExpVal - boolean controlling display of expected value field
        %
        %   By default, the expected value is not displayed and the value of this
        %   property is false.
        DisplayExpVal = false;
        
        % ExpValHeader - string containing header information for the expected value
        %
        %   Contains the following default header:
        %   'Expected Value:'
        ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedValue'));
        
        % ExpVal - string containing the expected value (if applicable)
        %
        %   This field my be turned off if the associated constraint does not
        %   contain an expected value.
        ExpVal;
    end
    
    properties (Dependent, SetAccess=private)
        % Conditions - string containing formatted condition list
        %
        %   The string consists of a list of conditions from the conditions list.
        %   Each condition starts on a new line and begins with an arrow '--> '
        %   delimiter.
        %
        %   See also
        %       addCondition
        Conditions;
        
        % ConditionsCount - number of conditions in the condition list
        %
        %   See also
        %       Conditions
        %       addCondition
        ConditionsCount;
    end
    
    methods (Static, Access=private)
        
        function conditionText = prepareConditionText(conditionText)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            validateattributes(conditionText, ...
                {'char'}, ...
                {}, ...
                '', ...
                'conditionText');
            
            conditionText = ConstraintDiagnostic.trimNewlines(conditionText);
            
            % Indent to align with '--> ' offset
            conditionText = ConstraintDiagnostic.indentAfterNewlines(conditionText);
        end
        
        function text = indentAfterNewlines(text)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            % Replace all newlines with indentations
            text = regexprep(text, '\n', ['\n'  ConstraintDiagnostic.INDENT]);
        end
        
        function text = indentText(text)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            % first place one indentation at the start
            text = sprintf('%s%s', ConstraintDiagnostic.INDENT, text);
            text = ConstraintDiagnostic.indentAfterNewlines(text);
        end
        
        function displayRespectingHotlinks(value,shouldHotLink)
            % Method to get a displayable string for actual/expected values.
            % Performs any necessary truncation and enables/disables hotlinks as necessary.
            
            feature('hotlinks', shouldHotLink);
            display(value);
        end
        
    end
    
    methods (Static, Access=protected)
        function str = trimNewlines(str)
            % trimNewlines - Utility method to remove newlines before/after a string
            validateattributes(str, ...
                {'char'}, ...
                {}, ...
                '', ...
                'str');
            str = regexprep(str, ...
                {'^\n+' '\n+$'}, ...
                {''     ''});
        end
        
    end
    
    methods (Static)
        
        function str = getDisplayableString(value)
            % getDisplayableString - Utility method for converting any object to a string in displayable format
            %
            %   This method is used to prepare any arbitrary object for display in a
            %   diagnostic result. This includes dealing with hotlinks and any truncation
            %   necessary for large numeric or cell arrays.
            %
            %   It provides a consistent method for truncating large arrays. The method is
            %   utilized internally when displaying the actual and expected value fields,
            %   but may also provide value externally when displaying failed indices, for
            %   example. Array truncation is performed by calling evalc on the displayed
            %   value, and returning some maximum number of characters.
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            if (ischar(value) && ~isempty(value))
                str = ConstraintDiagnostic.indentText(value);
                return;
            end
            
            % Array & buffer limits
            maxPrintedElems = 100;
            maxEvaledElems  = 5000;
            maxPrintedChars = 20 * maxPrintedElems;
            
            startingFormat = get(0,'Format');
            cl = onCleanup(@() set(0,'Format', startingFormat));
            set(0,'Format','long');
            
            if (numel(value) < maxEvaledElems)
                
                shouldHotLink = matlab.unittest.internal.diagnostics.shouldHyperLink; %#ok<NASGU> % evalc'ed below
                str = ConstraintDiagnostic.trimNewlines(evalc(...
                    'ConstraintDiagnostic.displayRespectingHotlinks(value, shouldHotLink)'));
                str = regexprep(str, 'value =(\s*[\f\r\n]|[ \t\v]*)','');
                
                if isempty(str)
                    str = getString(message('MATLAB:unittest:ConstraintDiagnostic:NoDisplayedOutput', ...
                        class(value), int2str(size(value))));
                elseif (length(str) > maxPrintedChars)
                    str = sprintf('%s\n\n%s', str(1:maxPrintedChars), ...
                        getString(message('MATLAB:unittest:ConstraintDiagnostic:TruncatedString')));
                
                end
            else
                % Preventing evalc output from prohibitive memory usage due to large array length
                str = sprintf('%s\n%s', getString(message('MATLAB:unittest:ConstraintDiagnostic:TruncatedArray', ...
                    int2str(size(value)), ...
                    maxEvaledElems, ...
                    maxPrintedElems)), ...
                    ConstraintDiagnostic.getDisplayableString(value(1:maxPrintedElems)));
            end
            str = ConstraintDiagnostic.indentText(str);
        end
        
    end
    
    methods (Hidden)
        function diag = ConstraintDiagnostic()
            % Hidden constructor because ConstraintDiagnosticFactory should generally
            % be used for creation of ConstraintDiagnostics.
        end
        
        function condition = getConditionAt(diag, index)
            condition = diag.ConditionsList{index};
        end
    end
    
    methods (Sealed)
        function diagnose(diag)
            % diagnose - Template method used to construct the diagnostic result.
            %
            %   The diagnose method utilizes the template method pattern in order to build
            %   the diagnostic result string from its fields. The fields are displayed in the
            %   following order:
            %
            %       * Description
            %       * Conditions
            %       * Actual Value
            %       * Expected Value
            %
            %   Sub classes may add fields in any location by overriding the following
            %   task methods:
            %
            %       * getPreDescriptionString
            %       * getPostDescriptionString
            %       * getPostConditionsString
            %       * getPostActValString
            %       * getPostExpValString
            %
            %   These methods are called by the diagnose method to obtain strings that are
            %   injected into the diagnostic result at the location indicated by the method
            %   name. These methods return an empty string unless overridden.
            %
            %   This pattern may be continued in ConstraintDiagnostic subclasses, allowing
            %   class developers to add additional fields performing the following steps:
            %
            %   * Override the appropriate task method (and optionally seal the new
            %     implementation)
            %   * Create two new task methods that bracket the overridden task method and
            %     simply return empty strings.
            %   * Call the new task methods in the overridden task method at the appropriate
            %     locations.
            %
            %   An example of creating a new constraint diagnostic class with an additional
            %   field is given below:
            %   (Note, the new field is added after the Conditions field)
            %
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   % Example Constraint Diagnostic
            %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   classdef MyConstraintDiagnostic < ConstraintDiagnostic
            %
            %       properties
            %           DisplayMyNewProp = false;
            %           MyNewProp;
            %           MyNewPropHeader = 'MyNewProp Value:';
            %       end
            %
            %       methods (Access = protected)
            %       % The following protected methods allow subclasses to add additional fields
            %       % before or after the MyNewProp field.
            %           function str = getMyNewPropString(obj)
            %               str = '';
            %           end
            %           function str = getPostMyNewPropString(obj)
            %               str = '';
            %           end
            %       end
            %
            %       methods
            %           function set.MyNewPropHeader(obj, str)
            %               MyNewPropHeader = obj.trimNewlines(str);
            %           end
            %           function set.MyNewProp(obj, str)
            %               MyNewProp = obj.trimNewlines(str);
            %           end
            %           function s = getPostConditionsString(obj)
            %           % Overriding base class implementation in order to inject new field.
            %
            %               s = obj.getPreMyNewPropString();
            %               if (~isempty(s))
            %                   s = sprintf('%s\n\n', ...
            %                               obj.trimNewlines(s));
            %               end
            %
            %               if (DisplayMyNewProp)
            %                   s = sprintf('%s%s\n%s\n\n', ...
            %                               s, ...
            %                               obj.MyNewPropHeader, ...
            %                               obj.MyNewProp);
            %               end
            %
            %               str = obj.getPostMyNewPropString();
            %               if (~isempty(str))
            %                   s = sprintf('%s%s', ...
            %                               s, ...
            %                               str);
            %
            %               s = obj.trimNewlines(s);
            %           end
            %       end
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            s = diag.getPreDescriptionString();
            if (~isempty(s))
                s = sprintf('%s\n', ...
                    ConstraintDiagnostic.trimNewlines(s));
            end
            
            % Description
            if (diag.DisplayDescription)
                s = sprintf('%s%s\n', ...
                    s, ...
                    diag.Description);
            end
            
            str = diag.getPostDescriptionString();
            if (~isempty(str))
                s = sprintf('%s%s\n', ...
                    s, ...
                    ConstraintDiagnostic.trimNewlines(str));
            end
            
            % Conditions
            if (diag.DisplayConditions && ...
                    diag.ConditionsCount > 0)
                s = sprintf('%s%s\n', ...
                    s, ...
                    ConstraintDiagnostic.trimNewlines(diag.Conditions));
            end
            
            str = diag.getPostConditionsString();
            if (~isempty(str))
                s = sprintf('%s%s\n', ...
                    s, ...
                    ConstraintDiagnostic.trimNewlines(str));
            end
            
            % Add a newline
            s = sprintf('%s\n', s);
            
            % Actual Value
            if (diag.DisplayActVal)
                actVal = diag.ActVal;
                actValText = ConstraintDiagnostic.getDisplayableString(actVal);
                s = sprintf('%s%s\n%s\n', ...
                    s, ...
                    diag.ActValHeader, ...
                    actValText);
            end
            
            str = diag.getPostActValString();
            if (~isempty(str))
                s = sprintf('%s%s\n', ...
                    s, ...
                    ConstraintDiagnostic.trimNewlines(str));
            end
            
            % Expected Value
            if (diag.DisplayExpVal)
                expVal = diag.ExpVal;
                expValText = ConstraintDiagnostic.getDisplayableString(expVal);
                s = sprintf('%s%s\n%s\n', ...
                    s, ...
                    diag.ExpValHeader, ...
                    expValText);
            end
            
            str = diag.getPostExpValString();
            if (~isempty(str))
                s = sprintf('%s%s\n', ...
                    s, ...
                    str);
            end
            
            % Add a newline
            s = sprintf('%s\n', s);
            
            diag.DiagnosticResult = ConstraintDiagnostic.trimNewlines(s);
        end
    end
    
    methods (Access=protected)
        function str = getPreDescriptionString(~)
            % getPreDescriptionString - returns text to be displayed prior to the description
            %
            %   This overridable method can be used to inject fields prior to the
            %   Description field.
            str = '';
        end
        
        function str = getPostDescriptionString(~)
            % getPostDescriptionString - returns text to be displayed after the description
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   Description field.
            %   Note: The location of this text is tied to the Description field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostConditionsString(~)
            % getPostConditionsString - returns text to be displayed after the conditions list
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   Conditions field
            %   Note: The location of this text is tied to the Conditions field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostActValString(~)
            % getPostActValString - returns text to be displayed after the actual value
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   ActVal field
            %   Note: The location of this text is tied to the ActVal field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
        
        function str = getPostExpValString(~)
            % getPostExpValString - returns text to be displayed after the expected value
            %
            %   This overridable method can be used to inject fields subsequent to the
            %   ExpVal field
            %   Note: The location of this text is tied to the ExpVal field.
            %         The placement relative to other fields is not guaranteed.
            str = '';
        end
    end
    
    methods
        
        function set.Description(diag, desc)
            diag.Description = diag.trimNewlines(desc);
        end
        
        function addConditionsFrom(diag, otherDiag)
            % addConditionsFrom - add conditions from another ConstraintDiagnostic
            %
            % DIAG.addConditionsFrom(OTHER) takes all of the conditions from the
            % ConstraintDiagnostic OTHER and adds them to the condition list of DIAG.
            % This is primarily useful when a Constraint composes another constraint,
            % and would like to use the conditions produced in the diagnostics of the
            % composed constraint.
            %
            %   Example:
            %
            %       % This demonstrates a constraint that composes another constraint
            %       % and uses the addConditionsFrom method to utilize the conditions
            %       % from the composed ConstraintDiagnostic.
            %       classdef IsDouble < matlab.unittest.constraints.Constraint
            %
            %           properties(Constant, GetAccess=private)
            %               DoubleConstraint = matlab.unittest.constraints.IsInstanceOf(?double)
            %           end
            %
            %           methods
            %               function tf = satisfiedBy(constraint, actual)
            %                   tf = constraint.DoubleConstraint.satisfiedBy(actual);
            %               end
            %               function diag = getDiagnosticFor(constraint, actual)
            %                       diag = ConstraintDiagnostic;
            %
            %                       % Now add conditions from the IsInstanceOf
            %                       % Diagnostic
            %                       otherDiag = constraint.DoubleConstraint.getDiagnosticFor(actual);
            %                       diag.addConditionsFrom(otherDiag);
            %
            %                       % ...
            %                   end
            %               end
            %           end
            %       end
            %
            %
            
            
            
            validateattributes(otherDiag, {'matlab.unittest.diagnostics.ConstraintDiagnostic'}, ...
                {'scalar'},'', 'otherDiag');
            
            diag.ConditionsList = [diag.ConditionsList otherDiag.ConditionsList];
        end
        
        function addCondition(diag, condition)
            % addCondition - Method to add a condition to the condition list.
            %
            % A condition is a string containing information specific to the cause of
            % the constraint failure. It can also be a diagnostic instance. When the
            % condition list is displayed, each condition is preceded by an arrow '-->'
            % and indented. Any number of conditions may be specified.
            
            validateattributes(condition,{'char','message','matlab.unittest.diagnostics.Diagnostic'},...
                {},'','condition');
            diag.ConditionsList{end+1} = condition;
        end
        
        function c = get.Conditions(diag)
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            if (isempty(diag.ConditionsList))
                c = '';
                return;
            end
            
            nonStringIndices = ~cellfun(@ischar,diag.ConditionsList);
            textOnlyConditionsList = diag.ConditionsList;
            textOnlyConditionsList(nonStringIndices) = cellfun(@convertNonStringConditionsToText,...
                diag.ConditionsList(nonStringIndices),'UniformOutput', false);
            conditionText = cellfun(@ConstraintDiagnostic.prepareConditionText,...
                textOnlyConditionsList,'UniformOutput', false);
            c = sprintf('--> %s\n', conditionText{:});
        end
        
        
        function count = get.ConditionsCount(diag)
            count = numel(diag.ConditionsList);
        end
        
        function set.ActValHeader(diag, header)
            diag.ActValHeader = diag.trimNewlines(header);
        end
        
        function set.ExpValHeader(diag, header)
            diag.ExpValHeader = diag.trimNewlines(header);
        end
        
    end
end

function condition = convertNonStringConditionsToText(diag)
objClass = metaclass(diag);
if objClass <= ?matlab.unittest.diagnostics.Diagnostic
    diag.diagnose;
    condition = diag.DiagnosticResult;
elseif objClass <= ?message
    condition = diag.getString;
end
end

% LocalWords:  overridable
