classdef IssuesWarnings < matlab.unittest.internal.constraints.WarningQualificationConstraint & ...
                          matlab.unittest.internal.constraints.RespectingSetMixin & ...
                          matlab.unittest.internal.constraints.RespectingCountMixin & ...
                          matlab.unittest.internal.constraints.RespectingOrderMixin & ...
                          matlab.unittest.internal.constraints.ExactlyMixin & ...
                          matlab.unittest.internal.constraints.ConciseDiagnosticMixin
    % IssuesWarnings -  Constraint specifying a function that issues an expected warning profile
    %   The IssuesWarnings constraint produces a qualification failure for any
    %   value that is not a function handle that issues a specific set of
    %   warnings. The warnings are specified and compared using warning
    %   identifiers.
    %
    %   By default, the constraint only confirms that the set of warnings
    %   specified were issued, but is agnostic to the number of times they are
    %   issued, in what order they are issued, and whether or not any
    %   unspecified warnings were issued. However, through additional
    %   parameters one can respect the order, count, and the warning set.
    %   Additionally, one can simply specify that the warning profile must
    %   match exactly. See the constructor documentation and/or the examples
    %   below in order to see how this is done.
    %
    %   The FunctionOutputs property provides access to the output arguments
    %   produced when invoking the function handle. The Nargout property
    %   specifies the number of output arguments to be returned.
    %
    %   IssuesWarnings methods:
    %       IssuesWarnings - Class constructor
    %
    %   IssuesWarnings properties:
    %       ExpectedWarnings - cell array of expected warning identifiers
    %       FunctionOutputs - cell array of outputs produced when invoking the
    %           supplied function handle
    %       Nargout - specifies the number of outputs this instance should supply
    %       Exact - specifies whether this instance performs exact comparisons
    %       RespectSet - specifies whether this instance respects set elements
    %       RespectOrder - specifies whether this instance respects the order of elements
    %       RespectCount - specifies whether this instance respects element counts
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IssuesWarnings;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Helper anonymous function to aid in examples
    %       issueWarnings = @(idCell) cellfun(@(id) warning(id,'Message'), idCell);
    %
    %       % Create some ids for the examples
    %       firstID =   'first:id';
    %       secondID =  'second:id';
    %       thirdID =   'third:id';
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % Simple case
    %       testCase.verifyThat(@() issueWarnings({firstID}), IssuesWarnings({firstID}));
    %
    %       % Specifying number of outputs to use when invoking the function
    %       testCase.verifyThat(@() issueWarnings({firstID}), ...
    %           IssuesWarnings({firstID}, 'WhenNargoutIs', 0));
    %
    %       % Ignores count, warning set, and order
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID, secondID}));
    %
    %       % Respects warning set
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID, secondID, thirdID}, 'RespectingSet', true));
    %
    %       % Respects warning count
    %       testCase.verifyThat(@() issueWarnings({secondID, firstID, thirdID, secondID}), ...
    %           IssuesWarnings({firstID, secondID, secondID}, 'RespectingCount', true));
    %
    %       % Respects warning order
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID, secondID, thirdID}), ...
    %           IssuesWarnings({firstID, secondID}, 'RespectingOrder', true));
    %
    %       % Requires an exact match to the expected warning profile
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID, secondID, thirdID}), ...
    %           IssuesWarnings({firstID, secondID, secondID, thirdID}, ...
    %               'Exactly', true));
    %
    %       % Access the outputs returned by the function handle
    %       issuesWarningsConstraint = IssuesWarnings({'first:id'}, 'WhenNargoutIs', 2);
    %       testCase.verifyThat(@warnWithOutput, issuesWarningsConstraint); %warnWithOutput defined below
    %       [actualOut1, actualOut2] = issuesWarningsConstraint.FunctionOutputs{:};
    %       function varargout = warnWithOutput()
    %          warning('first:id','Message');
    %          varargout = {123, 'abc'};
    %       end
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.fatalAssertThat(5, IssuesWarnings({firstID}));
    %
    %       % does not issue any warning
    %       testCase.assumeThat(@why, IssuesWarnings({firstID}));
    %
    %       % wrong id
    %       testCase.verifyThat(@() issueWarnings({firstID}), IssuesWarnings({secondID}));
    %
    %       % Ignores count, warning set, and order, but missing an ID
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID}));
    %
    %       % Respects warning set
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID}), ...
    %           IssuesWarnings({firstID}, 'RespectingSet', true));
    %
    %       % Respects warning count
    %       testCase.verifyThat(@() issueWarnings({firstID, firstID}), ...
    %           IssuesWarnings({firstID}, 'RespectingCount', true));
    %
    %       % Respects warning order
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID}), ...
    %           IssuesWarnings({secondID, firstID}, 'RespectingOrder', true));
    %
    %       % Requires an exact match to the expected warning profile
    %       testCase.verifyThat(@() issueWarnings({firstID, firstID, secondID, firstID}), ...
    %           IssuesWarnings({firstID,  secondID, firstID, firstID }, ...
    %               'Exactly', true));
    %
    %   See also
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.IssuesNoWarnings
    %       matlab.unittest.constraints.Throws
    %       warning
    
    
    %  Copyright 2011-2013 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % ExpectedWarnings - cell array of expected warning identifiers
        %   
        %   The ExpectedWarnings property contains a cell array of strings
        %   that describe the expected warning profile that should be issued by a
        %   supplied function handle. This profile can be interpreted in different
        %   ways depending on other properties defined on this instance
        %
        %   This property is read only and can only be set through the constructor.
        %
        %   See also:
        %       Exact, RespectSet, RespectOrder, RespectCount
        ExpectedWarnings
    end
    
    properties(Access=private)
        HasIssuedExpectedWarningProfile
        FunctionHandleOutputLog
    end
    
    properties(Dependent,Access=private)
        HasIssuedWarningsWithExpectedFrequency
        HasIssuedWarningsInExpectedOrder
        MissingWarnings
        ExtraWarnings
    end
    
    
    properties(Hidden, Constant, GetAccess=private)
        ExpectedWarningsParser = createExpectedWarningsParser;
    end
    
    
    
    methods
        function constraint = IssuesWarnings(warnings, varargin)
            % IssuesWarnings - Class constructor
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS) creates a
            %   constraint that is able to determine whether any value is a function
            %   handle that issues a particular set of MATLAB warnings when invoked,
            %   and produces an appropriate qualification failure if it does
            %   not. WARNINGS is specified as a cell array of warning IDs that should
            %   be produced upon invocation of the function handle. An MException is
            %   produced upon construction if WARNINGS is empty.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS, ...
            %   'WhenNargoutIs',NUMOUTPUTS) creates a constraint that is able to
            %   determine whether a value is a function handle that issues a particular
            %   set of MATLAB warnings when invoked with NUMOUTPUTS number of output
            %   arguments.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS, ...
            %   'RespectingSet',true) creates a constraint that is able to determine
            %   whether a value is a function handle that issues a particular set of
            %   MATLAB warnings. In addition to ensuring that all of the warnings
            %   specified were issued, this instance will also produce a qualification
            %   failure if any extra, unspecified warnings were issued.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS, ...
            %   'RespectingCount',true) creates a constraint that is able to determine
            %   whether a value is a function handle that issues a particular set of
            %   MATLAB warnings. In addition to ensuring that all of the warnings
            %   specified were issued, this instance will also produce a qualification
            %   failure if the number of times that a particular warning is issues
            %   differs from the number of times that warning is specified in WARNINGS.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS, ...
            %   'RespectingOrder',true) creates a constraint that is able to determine
            %   whether a value is a function handle that issues a particular set of
            %   MATLAB warnings. In addition to ensuring that all of the warnings
            %   specified were issued, this instance will also produce a qualification
            %   failure if the order of the issued warnings differs from the order the
            %   warnings are specified in WARNINGS. The order of a given set of
            %   warnings is determined by trimming the warning profiles to a profile
            %   with no repeated warnings. For example, the following warning profile:
            %
            %       {id:A, id:A, id:B, id:C, id:C, id:C, id:A, id:A, id:A} 
            %
            %   is trimmed to become:
            %
            %       {id:A, id:B, id:C, id:A}
            %
            %   This trimmed profile represents the order of a given warning profile,
            %   and when this constraint RespectsOrder the order of the warnings that
            %   were both issued and expected must match the order of the expected
            %   warning profile. Warnings issued that are not listed somewhere in the
            %   ExpectedWarnings are ignored when determining order.
            %
            %   CONSTRAINT = matlab.unittest.constraints.IssuesWarnings(WARNINGS, ...
            %   'Exactly',true) creates a constraint that is able to determine whether
            %   a value is a function handle that issues an expected warning profile
            %   exactly.
            %
            %   See also:
            %       ExpectedWarnings, Nargout, Exact, RespectSet, RespectOrder, RespectCount
            
            constraint.ExpectedWarnings = warnings;
            constraint = constraint.parse(varargin{:});
            
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.issuesExpectedWarnings(actual);
            
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.getDiagnosticFor@matlab.unittest.internal.constraints.FunctionHandleConstraint(actual);
                return
            end
            
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never issued any warnings
            if ~constraint.HasIssuedSomeWarnings
                diag = constraint.createNoWarningsIssuedDiagnostic;
                return
            end
            
            
            conditions = ConstraintDiagnostic.empty;
            % Diagnostic for failure related to missing or extra warnings
            if ~constraint.HasIssuedExpectedWarningProfile
                if constraint.Exact
                    conditions(end+1) = getString(message('MATLAB:unittest:IssuesWarnings:NotExactProfile'));
                else
                    conditions(end+1) = constraint.createWrongWarningSetDiagnostic;
                end
            end
            
            % Respect warning count
            if ~constraint.HasIssuedWarningsWithExpectedFrequency
                conditions(end+1) = constraint.createWrongWarningCountDiagnostic;
            end
            
            % Respect warning order
            if ~constraint.HasIssuedWarningsInExpectedOrder
                conditions(end+1) = constraint.createWrongWarningOrderDiagnostic;
            end
            
            if ~isempty(conditions)
                subDiag = constraint.createIncorrectWarningProfileDiagnostic;
                for ct = 1:numel(conditions)
                    subDiag.addCondition(conditions(ct));
                end
                diag = constraint.generateFcnDiagnostic(subDiag);
            else
                % If we've made it this far and we have no conditions then we have passed
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            end
        end
                
        function set.ExpectedWarnings(constraint, warnings)
            
            validateattributes(warnings,{'cell'}, {'row'}, '', 'warnings');
            constraint.ExpectedWarningsParser.parse(warnings);
            
            constraint.ExpectedWarnings = warnings;
        end
        
        function tf = get.HasIssuedWarningsWithExpectedFrequency(constraint)
            tf = true;
            if constraint.RespectCount
                
                for ct = 1:numel(unique(constraint.ExpectedWarnings))
                    thisWarning = constraint.ExpectedWarnings{ct};
                    expCount = sum(strcmp(thisWarning, constraint.ExpectedWarnings));
                    actCount = sum(strcmp(thisWarning, constraint.ActualWarnings));
                    if ~isequal(actCount, expCount);
                        tf = false;
                        return
                    end
                end
            end
        end
        
        function tf = get.HasIssuedWarningsInExpectedOrder(constraint)
            tf = true;
            if constraint.RespectOrder
                % To fail an order check, we only look at the intersection of the actual &
                % expected. Let other methods produce the failure if they are not correct
                % enough in other aspects
                expectedAndIssued =  intersect(constraint.ActualWarnings,constraint.ExpectedWarnings);
                
                % Find which locations of warnings in the intersection
                actMask = ismember(constraint.ActualWarnings,expectedAndIssued);
                expMask = ismember(constraint.ExpectedWarnings,expectedAndIssued);
                
                % Trim to observe relative order
                trimIssued = trimRepeatedElements(constraint.ActualWarnings(actMask));
                trimExpected = trimRepeatedElements(constraint.ExpectedWarnings(expMask));
                
                tf = isequal(trimIssued,trimExpected);
            end
        end
        
        
        function missing = get.MissingWarnings(constraint)
            missing = setdiff(constraint.ExpectedWarnings, constraint.ActualWarnings);
        end
        function extra = get.ExtraWarnings(constraint)
            extra = setdiff(constraint.ActualWarnings, constraint.ExpectedWarnings);
        end
    end
    
    methods (Hidden)
        function diag = getConciseDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return
            end
            
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never issued any warnings
            if ~constraint.HasIssuedSomeWarnings
                subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, ...
                    [], ...
                    constraint.convertToDisplayableList(constraint.ExpectedWarnings));
                subDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:NoWarningsIssued'));
                subDiag.DisplayActVal = false;
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedWarning'));
                diag = constraint.generateFcnDiagnostic(subDiag);
                return
            end
            
            % Diagnostic for failure related to missing or extra warnings
            if ~constraint.HasIssuedExpectedWarningProfile
                subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, ...
                    constraint.convertToDisplayableList(constraint.ActualWarnings), ...
                    constraint.convertToDisplayableList(constraint.ExpectedWarnings));
                subDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:UnexpectedWarning'));
                subDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualWarnings'));
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedWarning'));
                diag = constraint.generateFcnDiagnostic(subDiag);
            else
                % If we've made it this far and we have no conditions then we have passed
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive);
            end
        end
    end
    
    methods(Hidden,Access=protected)
        
        function invoke(constraint, fcn)  %#ok<INUSD> evalc
            % Evalc's the super classes invocation of the
            % function to prevent expected warnings from being seen at the
            % command prompt.
            constraint.FunctionHandleOutputLog = evalc('constraint.invoke@matlab.unittest.internal.constraints.WarningQualificationConstraint(fcn)');
        end
        
        
        function processWarnings(constraint)
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            
            if constraint.Exact
                passed = isequal(constraint.ActualWarnings,constraint.ExpectedWarnings);
                % Account for all warnings
                warningsAccountedFor = constraint.ActualWarningsIssued;
            else
                
                passed = isempty(constraint.MissingWarnings);
                if constraint.RespectSet
                    % if all expected warnings were issued and we are respecting set, we check
                    % if any extra warnings were issued and fail if so. however, we do account
                    % for all warnings thrown in this scenario
                    
                    % Fail if any warnings were issued that were not specified
                    passed = passed && isempty(constraint.ExtraWarnings);
                    
                    % Account for all warnings
                    warningsAccountedFor = constraint.ActualWarningsIssued;
                else
                    if passed
                        % We only account for the expected warnings
                        mask = ismember(constraint.ActualWarnings, constraint.ExpectedWarnings);
                        warningsAccountedFor = constraint.ActualWarningsIssued(mask);
                    else
                        warningsAccountedFor = constraint.ActualWarningsIssued;
                    end
                end
            end
            
            constraint.HasIssuedExpectedWarningProfile = passed;
            
            % Broadcast which warnings were accounted for via this constraint. Warnings
            % not accounted for may be picked up by external tooling. However, expected
            % warnings and warnings that already are caught through a failure of this
            % tool are regarded as accounted for.
            ExpectedWarningsNotifier.notifyExpectedWarnings(warningsAccountedFor);
        end
    end
    
    methods(Access=private)
        function tf = issuesExpectedWarnings(constraint, actual)
            constraint.invoke(actual);
            
            tf = ...
                constraint.HasIssuedSomeWarnings && ...
                constraint.HasIssuedExpectedWarningProfile && ...
                constraint.HasIssuedWarningsWithExpectedFrequency && ...
                constraint.HasIssuedWarningsInExpectedOrder;
            
            % Print the function output if a failure has been encountered.
            if ~tf
                fprintf('%s', constraint.FunctionHandleOutputLog);
            end
            
        end
        
        function diag = createNoWarningsIssuedDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            subDiag = constraint.createIncorrectWarningProfileDiagnostic;
            subDiag.DisplayActVal = false;
            
            subDiag.addCondition(message('MATLAB:unittest:IssuesWarnings:NoWarningsIssued'));
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
        function diag = createIncorrectWarningProfileDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                                constraint, DiagnosticSense.Positive, ...
                                constraint.convertToDisplayableList(constraint.ActualWarnings),...
                                constraint.convertToDisplayableList(constraint.ExpectedWarnings));
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningProfile'));
            diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualProfile'));
            diag.ExpValHeader = sprintf(getString(message('MATLAB:unittest:IssuesWarnings:ExpectedProfile')));            
            
            % add the qualifiers
            if constraint.Exact
                qualifiers = getString(message('MATLAB:unittest:IssuesWarnings:MustMatchExactly'));
            else
                qualifiers = constraint.buildRespectAndIgnoreQualifierString;
            end            
            diag.Description = sprintf('%s\n%s', diag.Description, qualifiers);
            
        end

        function repectIgnoreStr = buildRespectAndIgnoreQualifierString(constraint)
            respectList = {};
            ignoreList = {};
            setStr = getString(message('MATLAB:unittest:IssuesWarnings:Set'));
            if (constraint.RespectSet)
                respectList{end+1} = setStr;
            else
                ignoreList{end+1} = setStr;
            end
            
            countStr = getString(message('MATLAB:unittest:IssuesWarnings:Count'));
            if (constraint.RespectCount)
                respectList{end+1} = countStr;
            else
                ignoreList{end+1} = countStr;
            end
            
            orderStr = getString(message('MATLAB:unittest:IssuesWarnings:Order'));
            if (constraint.RespectOrder)
                respectList{end+1} = orderStr;
            else
                ignoreList{end+1} = orderStr;
            end
            
            
            respectStr = '';
            if ~isempty(respectList)
                respectStr = getString(message('MATLAB:unittest:IssuesWarnings:ProfileRespects'));
                respectListStr = sprintf('\n  %s',respectList{:});
                respectStr = sprintf('%s%s\n', respectStr, respectListStr);
            end
            
            ignoreStr = '';
            if ~isempty(ignoreList)
                ignoreStr = getString(message('MATLAB:unittest:IssuesWarnings:ProfileIgnores'));
                ignoreListStr = sprintf('\n  %s',ignoreList{:});
                ignoreStr = sprintf('%s%s\n', ignoreStr, ignoreListStr);
            end
            
            repectIgnoreStr = [respectStr ignoreStr];
        end
        
        
        function diag = createWrongWarningOrderDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningOrder'));
            
            
            diag.DisplayActVal = true;
            diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualOrder'));

            expectedAndIssued =  intersect(constraint.ActualWarnings,constraint.ExpectedWarnings);           
                      
            % when looking at the order of the actual list, the only relevant
            % warnings were those specified as expected, operate on a sublist of the
            % warnings that were actually thrown and were expected
            actMask = ismember(constraint.ActualWarnings,expectedAndIssued);
            actualOrder = trimRepeatedElements(constraint.ActualWarnings(actMask));
            diag.ActVal = constraint.convertToDisplayableList(actualOrder);
            
            
            diag.DisplayExpVal = true;
            diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedOrder'));
            expectedOrder = trimRepeatedElements(constraint.ExpectedWarnings);
            diag.ExpVal = constraint.convertToDisplayableList(expectedOrder);
            
            
        end
        
        function diag = createWrongWarningCountDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningCount'));
            diag.DisplayConditions = true;
            uniqueExpectedWarnings = unique(constraint.ExpectedWarnings);
            for ct = 1:numel(uniqueExpectedWarnings)
                thisWarning = uniqueExpectedWarnings{ct};
                expCount = sum(strcmp(thisWarning, constraint.ExpectedWarnings));
                actCount = sum(strcmp(thisWarning, constraint.ActualWarnings));
                if actCount > 0 && ~isequal(actCount, expCount);
                    countDiag = ConstraintDiagnostic;
                    countDiag.DisplayDescription = true;
                    countDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:Identifier', thisWarning));
                    countDiag.DisplayConditions = true;
                    
                    % show the actual count
                    countDiag.DisplayActVal = true;
                    countDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualCount', thisWarning));
                    countDiag.ActVal = actCount;
                    
                    % Show the expected count
                    countDiag.DisplayExpVal = true;
                    countDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedCount', thisWarning));
                    countDiag.ExpVal = expCount;
                    
                    diag.addCondition(countDiag);
                    
                end
            end
            
            
            
        end
        
        
        
        function diag = createWrongWarningSetDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningSet'));
            % Use ActVal for missing warnings and ExpVal for extra warnings.
            missing = constraint.MissingWarnings;
            if ~isempty(missing)
                diag.DisplayActVal = true;
                diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:MissingWarnings'));
                diag.ActVal = constraint.convertToDisplayableList(missing);
            end
            
            
            if constraint.RespectSet
                extra = constraint.ExtraWarnings;
                diag.DisplayExpVal = true;
                diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExtraWarnings'));
                diag.ExpVal = constraint.convertToDisplayableList(extra);
            end
        end       
        
    end
    
end

function ids = trimRepeatedElements(ids)
% Simple helper to trim the repeated elements in a cell array of strings (e.g.
% warning IDs). This is useful when looking at order. It is somewhat like a
% "local" unique operation that doesn't sort and allows for non-unique
% entries as long as they're not contiguous.


% repeats are those where the next is the same as the previous. By
% convention the first is never a repeat
first = false;
repeats = [first strcmp(ids(1:end-1), ids(2:end))];
ids(repeats) = [];

end


function p = createExpectedWarningsParser
% parser only needs to be created once at class initialization time
p = inputParser;
p.addRequired('warnings',@iscellstr);
end

% LocalWords:  abc Evalc's sublist
