classdef QualificationDelegate < matlab.mixin.Copyable
    
    % Copyright 2011-2013 The MathWorks, Inc.
    
    properties(Abstract, Constant, Access=protected)
        Type
 
        % This private Constant property is for use in qualifyTrue, which should be
        % as performant as possible, and thus cannot pay the overhead of
        % constructing a new instance for every call. Note each subclass needs one since
        % the IsTrue constraints need different constraint alias (verifyTrue/assertTrue/etc).
        IsTrueConstraint
    end
    
    methods(Abstract)
        doFail(delegate, diagnosticData);
    end

    methods(Static, Access=protected)

        function constraint = generateIsTrueConstraint(type)
            import matlab.unittest.internal.constraints.AliasDecorator
            
            alias = ['matlab.unittest.TestCase.', type, 'True'];
            constraint = AliasDecorator(matlab.unittest.constraints.IsTrue, alias);
        end
    end
    
    methods(Sealed)
        
        function pass(~, callback, actual, constraint, varargin)            
            import matlab.unittest.qualifications.QualificationEventData;
            
            stack = dbstack('-completenames');
            eventData = QualificationEventData(stack, actual, constraint, varargin{:});
            callback(eventData);
        end
        
        function fail(delegate, callback, actual, constraint, varargin)            
            import matlab.unittest.qualifications.QualificationEventData;
            
            stack = dbstack('-completenames');
            eventData = QualificationEventData(stack, actual, constraint, varargin{:});
            callback(eventData);
            delegate.doFail();
        end        
    end

    methods             

        function qualifyThat(delegate, passCallback, failCallback, actual, constraint, varargin)
            
            narginchk(5,6);
            
            if isa(actual, 'matlab.unittest.constraints.ActualValueProxy')
                result = actual.satisfiedBy(constraint);
            elseif isa(constraint, 'matlab.unittest.constraints.Constraint')
                result = constraint.satisfiedBy(actual);
            else
                validateattributes(constraint, {'matlab.unittest.constraints.Constraint'},{},'', 'constraint');
            end
            
            if islogical(result) && isscalar(result) && result
                delegate.pass(passCallback, actual, constraint, varargin{:});
            else
                delegate.fail(failCallback, actual, constraint, varargin{:});
            end
            
        end

        function qualifyFail(delegate, passCallback, failCallback, varargin)
            import matlab.unittest.internal.constraints.FailingConstraint;      
            fail = delegate.decorateConstraintAlias(FailingConstraint, 'Fail');
            delegate.qualifyThat(passCallback, failCallback, [], fail, varargin{:});
        end
        
        function qualifyTrue(delegate, passCallback, failCallback, actual, varargin)
            delegate.qualifyThat(passCallback, failCallback, actual, delegate.IsTrueConstraint, varargin{:});
        end
        
        function qualifyFalse(delegate, passCallback, failCallback, actual, varargin)
            import matlab.unittest.constraints.IsFalse;
            isFalse = delegate.decorateConstraintAlias(IsFalse, 'False');
            delegate.qualifyThat(passCallback, failCallback, actual, isFalse, varargin{:});
        end
        
        function qualifyEqual(delegate, passCallback, failCallback, actual, expected, varargin)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.internal.constraints.ConciseDiagnosticDecorator
            
            % We allow optional name/value pairs plus an optional
            % diagnostic argument. Assume the last argument is a diagnostic
            % if there are an even number of inputs. This diagnostic needs
            % to be handled separately, outside of inputParser.
            diag = {};
            if mod(nargin, 2) == 0
                diag = varargin(end);
                varargin(end) = [];
            end
            
            % Tolerance constructors handle input validation; none needed here
            p = inputParser;
            p.addParameter('AbsTol',[]);
            p.addParameter('RelTol',[]);
            p.parse(varargin{:});
            
            absTolSpecified = ~any(strcmp('AbsTol', p.UsingDefaults));
            relTolSpecified = ~any(strcmp('RelTol', p.UsingDefaults));                        
            
            constraint = IsEqualTo(expected);            
            if absTolSpecified && relTolSpecified
                % AbsoluteTolerance "or" RelativeTolerance
                constraint = constraint.within(AbsoluteTolerance(p.Results.AbsTol) | ...
                    RelativeTolerance(p.Results.RelTol));
            elseif relTolSpecified
                % RelativeTolerance only
                constraint = constraint.within(RelativeTolerance(p.Results.RelTol));
            elseif absTolSpecified
                % AbsoluteTolerance only
                constraint = constraint.within(AbsoluteTolerance(p.Results.AbsTol));
            end
            
            constraint = delegate.decorateConstraintAlias(ConciseDiagnosticDecorator(constraint), 'Equal');            
            delegate.qualifyThat(passCallback, failCallback, actual, constraint, diag{:});
        end
        
        function qualifyNotEqual(delegate, passCallback, failCallback, actual, notExpected, varargin)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.internal.constraints.ConciseDiagnosticDecorator
            
            isNotEqualTo = delegate.decorateConstraintAlias(ConciseDiagnosticDecorator(~IsEqualTo(notExpected)), 'NotEqual');
            delegate.qualifyThat(passCallback, failCallback, actual, isNotEqualTo, varargin{:});
        end
        
        function qualifySameHandle(delegate, passCallback, failCallback, actual, expectedHandle, varargin)
            import matlab.unittest.constraints.IsSameHandleAs;
            
            isSameHandleAs = delegate.decorateConstraintAlias(IsSameHandleAs(expectedHandle), 'SameHandle');
            delegate.qualifyThat(passCallback, failCallback, actual, isSameHandleAs, varargin{:});
        end
        
        function qualifyNotSameHandle(delegate, passCallback, failCallback, actual, notExpectedHandle, varargin)
            import matlab.unittest.constraints.IsSameHandleAs;
            isNotSameHandleAs = delegate.decorateConstraintAlias(~IsSameHandleAs(notExpectedHandle), 'NotSameHandle');
            delegate.qualifyThat(passCallback, failCallback, actual, isNotSameHandleAs, varargin{:});
        end
        
        function qualifyError(delegate, passCallback, failCallback, actual, errorClassOrID, varargin)
            import matlab.unittest.constraints.Throws;
            throws = delegate.decorateConstraintAlias(Throws(errorClassOrID),'Error');
            delegate.qualifyThat(passCallback, failCallback, actual, throws, varargin{:});
        end
        
        function varargout = qualifyWarning(delegate, passCallback, failCallback, actual, warningID, varargin)
            import matlab.unittest.constraints.IssuesWarnings;
            import matlab.unittest.internal.constraints.ConciseDiagnosticDecorator;
            
            issuesWarningsWithOutputs = IssuesWarnings({warningID}, 'WhenNargoutIs',nargout);
            issuesWarningsWithOutputs = delegate.decorateConstraintAlias(ConciseDiagnosticDecorator(issuesWarningsWithOutputs), 'Warning');
            delegate.qualifyThat(passCallback, failCallback, actual, issuesWarningsWithOutputs, varargin{:});
            varargout = issuesWarningsWithOutputs.RootConstraint.FunctionOutputs;
        end
        
        function varargout = qualifyWarningFree(delegate, passCallback, failCallback, actual, varargin)
            import matlab.unittest.constraints.IssuesNoWarnings;
            issuesNoWarningsWithOutputs = IssuesNoWarnings('WhenNargoutIs',nargout);
            issuesNoWarningsWithOutputs = delegate.decorateConstraintAlias(issuesNoWarningsWithOutputs, 'WarningFree');
            delegate.qualifyThat(passCallback, failCallback, actual, issuesNoWarningsWithOutputs, varargin{:});
            varargout = issuesNoWarningsWithOutputs.RootConstraint.FunctionOutputs;
        end
        
        function qualifyEmpty(delegate, passCallback, failCallback, actual, varargin)
            import matlab.unittest.constraints.IsEmpty;
            isEmpty = delegate.decorateConstraintAlias(IsEmpty, 'Empty');
            delegate.qualifyThat(passCallback, failCallback, actual, isEmpty, varargin{:});
        end
        
        function qualifyNotEmpty(delegate, passCallback, failCallback, actual, varargin)
            import matlab.unittest.constraints.IsEmpty;
            isNotEmpty = delegate.decorateConstraintAlias(~IsEmpty, 'NotEmpty');
            delegate.qualifyThat(passCallback, failCallback, actual, isNotEmpty, varargin{:});
        end
        
        function qualifySize(delegate, passCallback, failCallback, actual, expectedSize, varargin)
            import matlab.unittest.constraints.HasSize;
            hasSize = delegate.decorateConstraintAlias(HasSize(expectedSize), 'Size');
            delegate.qualifyThat(passCallback, failCallback, actual, hasSize, varargin{:});
        end
        
        function qualifyLength(delegate, passCallback, failCallback, actual, expectedLength, varargin)
            import matlab.unittest.constraints.HasLength;
            hasLength = delegate.decorateConstraintAlias(HasLength(expectedLength), 'Length');
            delegate.qualifyThat(passCallback, failCallback, actual, hasLength, varargin{:});
        end
        
        function qualifyNumElements(delegate, passCallback, failCallback, actual, expectedElementCount, varargin)
            import matlab.unittest.constraints.HasElementCount;
            hasElementCount = delegate.decorateConstraintAlias(HasElementCount(expectedElementCount), 'NumElements');
            delegate.qualifyThat(passCallback, failCallback, actual, hasElementCount, varargin{:});
        end
        
        function qualifyGreaterThan(delegate, passCallback, failCallback, actual, floor, varargin)
            import matlab.unittest.constraints.IsGreaterThan;
            isGreaterThan = delegate.decorateConstraintAlias(IsGreaterThan(floor), 'GreaterThan');
            delegate.qualifyThat(passCallback, failCallback, actual, isGreaterThan, varargin{:});
        end
                
        function qualifyGreaterThanOrEqual(delegate, passCallback, failCallback, actual, floor, varargin)
            import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            isGreaterThanOrEqualTo = delegate.decorateConstraintAlias(IsGreaterThanOrEqualTo(floor), 'GreaterThanOrEqual');
            delegate.qualifyThat(passCallback, failCallback, actual, isGreaterThanOrEqualTo, varargin{:});
        end
        
        function qualifyLessThan(delegate, passCallback, failCallback, actual, ceiling, varargin)
            import matlab.unittest.constraints.IsLessThan;
            isLessThan = delegate.decorateConstraintAlias(IsLessThan(ceiling), 'LessThan');
            delegate.qualifyThat(passCallback, failCallback, actual, isLessThan, varargin{:});
        end
        
        function qualifyLessThanOrEqual(delegate, passCallback, failCallback, actual, ceiling, varargin)
            import matlab.unittest.constraints.IsLessThanOrEqualTo;
            
            isLessThanOrEqualTo = delegate.decorateConstraintAlias(IsLessThanOrEqualTo(ceiling), 'LessThanOrEqual');
            delegate.qualifyThat(passCallback, failCallback, actual, isLessThanOrEqualTo, varargin{:});
        end
        
        function qualifyReturnsTrue(delegate, passCallback, failCallback, actual, varargin)
            import matlab.unittest.constraints.ReturnsTrue;
            
            returnsTrue = delegate.decorateConstraintAlias(ReturnsTrue, 'ReturnsTrue');
            delegate.qualifyThat(passCallback, failCallback, actual, returnsTrue, varargin{:});
        end
        
        function qualifyInstanceOf(delegate, passCallback, failCallback, actual, expectedBaseClass, varargin)
            import matlab.unittest.constraints.IsInstanceOf;
            isInstanceOf = delegate.decorateConstraintAlias( IsInstanceOf(expectedBaseClass), 'InstanceOf');
            delegate.qualifyThat(passCallback, failCallback, actual, isInstanceOf, varargin{:});
        end
        
        function qualifyClass(delegate, passCallback, failCallback, actual, expectedClass, varargin)
            import matlab.unittest.constraints.IsOfClass;
            isOfClass = delegate.decorateConstraintAlias( IsOfClass(expectedClass), 'Class');
            delegate.qualifyThat(passCallback, failCallback, actual, isOfClass, varargin{:});
        end
        
        function qualifySubstring(delegate, passCallback, failCallback, actual, substring, varargin)
            import matlab.unittest.constraints.ContainsSubstring;
            containsSubstring = delegate.decorateConstraintAlias(ContainsSubstring(substring), 'Substring');
            delegate.qualifyThat(passCallback, failCallback, actual, containsSubstring, varargin{:});
        end
        
        function qualifyMatches(delegate, passCallback, failCallback, actual, expression, varargin)
            import matlab.unittest.constraints.Matches;
            matches = delegate.decorateConstraintAlias(Matches(expression), 'Matches');
            delegate.qualifyThat(passCallback, failCallback, actual, matches, varargin{:});
        end
        
    end


    methods(Access=private)
        function constraint = decorateConstraintAlias(delegate, constraint, aliasSuffix)
            import matlab.unittest.internal.constraints.AliasDecorator
            constraint = AliasDecorator(constraint, ['matlab.unittest.TestCase.' delegate.Type, aliasSuffix]);          
        end
    end
end

% LocalWords:  performant completenames el Teardownable
