classdef Throws < matlab.unittest.internal.constraints.FunctionHandleConstraint & ...
                  matlab.unittest.internal.constraints.WhenNargoutIsMixin & ...
                  matlab.unittest.internal.constraints.CausedByMixin
              
    % Throws - Constraint specifying a function handle that throws an MException
    %
    %   The Throws constraint produces a qualification failure for any
    %   value that is not a function handle that throws a specific exception.
    %
    %   A qualification failure is always produced when the actual value
    %   provided is not a function handle or if it is a function handle that
    %   does not throw any MException.
    %
    %   If an MException is thrown by the function handle and the
    %   ExpectedException property is an error identifier, a qualification
    %   failure will occur if the actual MException thrown has a different
    %   identifier. Alternately, if the ExpectedException property is a
    %   meta.class a qualification failure will occur if the actual MException
    %   thrown does not derive from the ExpectedException.
    %
    %   If an MException is thrown with causes, a qualification failure
    %   will occur, if the actual MException thrown does not contain any
    %   one or more exceptions listed in the 'RequiredCauses' property, in
    %   its cause tree.
    %
    %   Throws methods:
    %       Throws - Class constructor
    %
    %   Parameter Options:
    %       Parameter       Value                               
    %       ---------       -----  
    %       WhenNargoutIs   a non-negative real scalar integer that
    %                       determines the number of output arguments the 
    %                       instance will use when executing the function 
    %                       under test.
    %       CausedBy        a cell array of Strings or meta.classes 
    %                       or any combination of these or empty cell.
    %
    %   Throws properties:
    %       ExpectedException - expected MException identifier or class
    %       Nargout - specifies the number of outputs this instance should supply
    %       RequiredCauses -lists the expected causes to look for, inside the actual cause tree
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.Throws;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % By identifier
    %       testCase.verifyThat(@() error('SOME:error:id','Error!'), Throws('SOME:error:id'));
    %
    %       % By class
    %       testCase.verifyThat(@() error('SOME:error:id','Error!'), Throws(?MException));
    %
    %       % With a certain number of outputs
    %       testCase.verifyThat(@() disp('hi'), Throws('MATLAB:maxlhs','WhenNargoutIs', 1));
    %
    %       % Check Causes by identifier
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id','CausedBy', {'causedBy:someOtherError:id'}));
    %
    %       % Check Causes by class
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id','CausedBy', {?MException}));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.fatalAssertThat(5, Throws('some:id'));
    %
    %       % does not throw any exception
    %       testCase.assumeThat(@why, Throws(?MException));
    %
    %       % wrong id
    %       testCase.verifyThat(@() error('SOME:id'), Throws('OTHER:id'));
    %
    %       % wrong class type
    %       testCase.verifyThat(@testCase.fatalAssertFail, ...
    %           Throws(?matlab.unittest.qualifications.AssumptionFailedException));
    %
    %       % cause id not found
    %       testCase.verifyThat(@() error('TOP:error:id','TopLevelError!'), Throws('TOP:error:id','CausedBy',{'causedBy:someOtherError:id'}));
    %
    %       % cause class type not found
    %       testCase.verifyThat(@() error('TOP:error:id','TopLevelError!'), Throws('TOP:error:id','CausedBy',{?MException}));
    %
    %   See also
    %       matlab.unittest.constraints.Constraint
    %       MException
    %       error
    
    %  Copyright 2011-2013 The MathWorks, Inc.

    properties(SetAccess=private)
        % ExpectedException - expected MException identifier or class
        %   
        %   The exception that should be thrown when supplied a function to invoke.
        %   This property is either an error identifier or a meta.class instance
        %   which describes a subclass of MException.
        %
        %   This property is read only and can only be set through the constructor.
        %
        %   See also:
        %       meta.class
        ExpectedException;
    end
    
    properties(Hidden, Constant, Access=private)
        MetaClassExceptionParser = createMetaClassExceptionParser;
        MessageObjectParser = createMessageObjectParser;
    end
    
    properties(Access=private)
        ActualExceptionThrown = MException.empty;
        MessageObjectExpectedMessage = '';
    end
    
    properties(Dependent, Access=private)
        CompareExceptionByClass;
        CompareExceptionByMessageObject;
        HasThrownAnException;
        HasThrownExpectedException;
        HasThrownExpectedExceptionCauses;
    end
    
    
    methods
        function constraint = Throws(exception, varargin)
            % Throws - Class constructor
            %
            %   CONSTRAINT = matlab.unittest.constraints.Throws(EXCEPTION) creates a
            %   constraint that is able to determine whether an actual value is a
            %   function handle that throws a particular MException when invoked, and
            %   produce an appropriate qualification failure if it does not. EXCEPTION
            %   can be an error identifier or a meta.class representing the specific
            %   type of exception that is expected to be thrown. If EXCEPTION is a
            %   meta.class, then it must represent a class that derives from
            %   MException or the constructor itself throws an MException.
            %
            %   CONSTRAINT = matlab.unittest.constraints.Throws(EXCEPTION,'WhenNargoutIs',NUMOUTPUTS) 
            %   creates a constraint that is able to determine whether an actual value
            %   is a function handle that throws a particular MException when invoked
            %   with NUMOUTPUTS number of output arguments.
            
            %   CONSTRAINT = matlab.unittest.constraints.Throws(EXCEPTION,'CausedBy',{LISTOFCAUSES})
            %   creates a constraint that is able to determine whether an
            %   actual value is a function handle that throws a particular
            %   MException with list of causes specified as a cell array of
            %   LISTOFCAUSES in its cause tree.
            
            validateattributes(  ...
                exception,{'meta.class', 'char', 'message'}, {'row'}, '', 'exception');
            
            % meta classes and message objects need a little more validation.
            % Use parsers defined at class level for performance.
            if isa(exception, 'meta.class')
                constraint.MetaClassExceptionParser.parse(exception);
            end
            
            if isa(exception, 'message')
                constraint.MessageObjectParser.parse(exception);
                
                % Validate that the ID is valid by calling getString.
                constraint.MessageObjectExpectedMessage = exception.getString();
            end
            
            constraint.ExpectedException = exception;
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = get.CompareExceptionByClass(constraint)
            % Test to determine if we are comparing thrown exceptions by class
            tf = isa(constraint.ExpectedException, 'meta.class');
        end
        function tf = get.CompareExceptionByMessageObject(constraint)
            % Test to determine if we are comparing thrown exceptions by
            % message object
            tf = isa(constraint.ExpectedException, 'message');
        end
        
        function tf = get.HasThrownExpectedException(constraint)
            % Need to fork on whether the exception was to be compared by
            % class, ID, or message object.
            if constraint.CompareExceptionByClass
                tf = exceptionEqualByClass(constraint.ActualExceptionThrown,constraint.ExpectedException);
            elseif constraint.CompareExceptionByMessageObject
                tf = exceptionEqualByMessageObject(constraint.ActualExceptionThrown,constraint.ExpectedException);
            else % compare by ID
                tf = exceptionEqualByID(...
                    constraint.ActualExceptionThrown,...
                    constraint.ExpectedException);
            end
        end
        
        function tf = get.HasThrownAnException(constraint)
            % Check to see if an error was thrown
            tf = ~isempty(constraint.ActualExceptionThrown);
        end
        
        function tf = get.HasThrownExpectedExceptionCauses(constraint)
            % If CausedBy is not specified (it is empty) or if it is
            % specified as empty cell, it is a passing condition.
            tf = true;

            for i=1:numel(constraint.RequiredCauses)
                if isa(constraint.RequiredCauses{i}, 'char')
                    tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByID);
                elseif isa(constraint.RequiredCauses{i}, 'message')
                   tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByMessageObject);
                else
                   tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByClass);
                end
                % return as soon as an expected value is not found
                if ~tf 
                    return
                end
            end
            
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.throwsExpectedException(actual);
            
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % Failure diag if it's not a function
            if ~constraint.isFunction(actual)
                diag = constraint.getDiagnosticFor@matlab.unittest.internal.constraints.FunctionHandleConstraint(actual);
                return
            end
            
            % We need to invoke in this method in two scenarios 
            %   1) satisfiedBy has not yet been called
            %   2) the last time satisfiedBy was called was for a "different" function
            %      handle
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never threw an exception
            if ~constraint.HasThrownAnException
                diag = constraint.createNoExceptionThrownDiagnostic;
                return
            end
            
                       
            if constraint.CompareExceptionByClass
                % Failure diag if it threw wrong type
                if ~exceptionEqualByClass(constraint.ActualExceptionThrown, constraint.ExpectedException)
                    diag = constraint.createWrongExceptionClassDiagnostic;
                    return
                end
            elseif constraint.CompareExceptionByMessageObject
                % Failure diag if it threw wrong message
                if ~exceptionEqualByMessageObject(constraint.ActualExceptionThrown, constraint.ExpectedException)
                    if ~messageObjectIDsEqual(constraint.ActualExceptionThrown, constraint.ExpectedException)
                        diag = constraint.createWrongExceptionIdentifierDiagnostic( ...
                            constraint.ActualExceptionThrown.identifier, constraint.ExpectedException.Identifier);
                        diag.addCondition(constraint.createWrongErrorMessageSubDiagnostic());
                    else 
                        diag = constraint.createWrongErrorMessageDiagnostic();
                    end
                    return
                end
            else % compare by ID
                % Failure diag if it threw wrong id
                if ~exceptionEqualByID(constraint.ActualExceptionThrown,constraint.ExpectedException)
                    diag = constraint.createWrongExceptionIdentifierDiagnostic( ...
                        constraint.ActualExceptionThrown.identifier, constraint.ExpectedException);
                    return
                end
            end
            
            % Failure diag if it did not throw an exception with cause or
            % with specified causes
            if ~constraint.HasThrownExpectedExceptionCauses
                diag = constraint.createDiagnosticForCausesNotThrown;
                return
            end
            
            % If we made it here then we passed.
            diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                DiagnosticSense.Positive);
        end
    end
    
    
    methods(Hidden,Access=protected)
        function invoke(constraint,fcn)
            % Function which actually invokes the function to observe errors
            outputs = cell(1,constraint.Nargout);
            try
                [outputs{:}] = constraint.invoke@matlab.unittest.internal.constraints.FunctionHandleConstraint(fcn); %#ok<NASGU>
                constraint.ActualExceptionThrown = MException.empty;
            catch ex
                constraint.ActualExceptionThrown =  ex;
            end
        end
    end
    
    methods(Access=private)
        
        function tf = throwsExpectedException(constraint, actual)
            % invoke the function to see whether it throws any exception
            constraint.invoke(actual);
            
            tf = ...
                constraint.HasThrownAnException && ...
                constraint.HasThrownExpectedException && ...
                constraint.HasThrownExpectedExceptionCauses;
            
        end
        
        
        function diag = createNoExceptionThrownDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
                        
            subDiag = ConstraintDiagnostic;
            subDiag.DisplayDescription = true;
            subDiag.Description = getString(message('MATLAB:unittest:Throws:NoExceptionThrown'));
            subDiag.DisplayExpVal = true;
            if constraint.CompareExceptionByClass
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedExceptionType'));
                subDiag.ExpVal = constraint.ExpectedException.Name;
            elseif constraint.CompareExceptionByMessageObject
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedMessageObject'));
                subDiag.ExpVal = constraint.ExpectedException;
            else % compare by ID
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedIdentifier'));
                subDiag.ExpVal = constraint.ExpectedException;
            end
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
        function diag = createWrongExceptionClassDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            actualClass = metaclass(constraint.ActualExceptionThrown);
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, ...
                actualClass.Name,  constraint.ExpectedException.Name);
            subDiag.Description = getString(message('MATLAB:unittest:Throws:WrongExceptionType'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:Throws:ActualExceptionType'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedExceptionType'));
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
        function diag = createWrongExceptionIdentifierDiagnostic(constraint, actID, expID)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, actID, expID);
            subDiag.Description = getString(message('MATLAB:unittest:Throws:WrongIdentifier'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:Throws:ActualIdentifier'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedIdentifier'));
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
        
        function diag = createWrongErrorMessageDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, constraint.ActualExceptionThrown.message, ...
                constraint.MessageObjectExpectedMessage);
            subDiag.Description = getString(message('MATLAB:unittest:Throws:WrongErrorMessage'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:Throws:ActualErrorMessage'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedErrorMessage'));
            diag = constraint.generateFcnDiagnostic(subDiag);
        end
        
        function subDiag = createWrongErrorMessageSubDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            subDiag = ConstraintDiagnostic;
            
            subDiag.DisplayActVal = true;
            subDiag.ActValHeader = getString(message('MATLAB:unittest:Throws:ActualErrorMessage'));
            subDiag.ActVal = constraint.ActualExceptionThrown.message;
            
            subDiag.DisplayExpVal = true;
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedErrorMessage'));
            subDiag.ExpVal = constraint.MessageObjectExpectedMessage;
        end
        
        
         function diag = createDiagnosticForCausesNotThrown(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = constraint.generateFcnDiagnostic(createDiagnosticForMissingExpectedCauses(constraint));

         end
         
         function subDiag = createDiagnosticForMissingExpectedCauses(constraint)
              
              import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
              import matlab.unittest.internal.diagnostics.DiagnosticSense;
              import matlab.unittest.diagnostics.ConstraintDiagnostic;
              
              subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                  DiagnosticSense.Positive, ...
                  '');
              subDiag.DisplayDescription = true;
              subDiag.Description = getString(message('MATLAB:unittest:Throws:MissingCauseException'));
              subDiag.DisplayActVal = false;
              
              for i=1:numel(constraint.RequiredCauses)
                  if isa(constraint.RequiredCauses{i}, 'char')
                     tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByID);
                     if ~tf
                         subMissingCauseDiag = generateActualValueDiagnostic(...
                              getString(message('MATLAB:unittest:Throws:MissingCauseIdentifier')),...
                              constraint.RequiredCauses{i});
                     end
                      
                 elseif isa(constraint.RequiredCauses{i}, 'message')
                    tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByMessageObject);
                    
                    if ~tf
                          subMissingCauseDiag = generateActualValueDiagnostic(...
                              getString(message('MATLAB:unittest:Throws:MissingCauseIdentifier')),...
                              constraint.RequiredCauses{i}.Identifier);
                          subMissingCauseDiag.DisplayExpVal = true;
                          subMissingCauseDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:MissingCauseMessage'));
                          subMissingCauseDiag.ExpVal = constraint.RequiredCauses{i}.getString;
                    end
                    
                  else
                      tf = recursivelyCompareExpected(constraint.ActualExceptionThrown,constraint.RequiredCauses{i},@exceptionEqualByClass);
                      
                      if ~tf
                          subMissingCauseDiag = generateActualValueDiagnostic(...
                              getString(message('MATLAB:unittest:Throws:MissingCauseExceptionType')),...
                              constraint.RequiredCauses{i}.Name);
                      end

                  end
                  
                  if ~tf
                      subDiag.addCondition(subMissingCauseDiag);
                  end
                  
              end
          end
    end
    
    
end    


function p = createMetaClassExceptionParser
p = inputParser;
p.addRequired('exception',@(class) isscalar(class) && class <= ?MException);
end

function p = createMessageObjectParser
p = inputParser;
p.addRequired('message',@(msg) isscalar(msg));
end


function tf = exceptionEqualByID(actualException, expectedExceptionID)
% Test to determine whether we are satisfied by id
tf = strcmp(actualException.identifier, expectedExceptionID);
end

function tf = exceptionEqualByMessageObject(actualException, expMsgObj)
% Test to determine whether we are satisfied by message object
tf = messageObjectIDsEqual(actualException,expMsgObj) &&...
     messageObjectMessagesEqual(actualException, expMsgObj);
end


function tf = messageObjectIDsEqual(actualException,expMsgObj)
% Test to determine the identifiers are equal
    tf = exceptionEqualByID(actualException, expMsgObj.Identifier);
end

function tf = messageObjectMessagesEqual(actualException,expMsgObj)
% Test to determine the messages are equal
    tf = strcmp(actualException.message, expMsgObj.getString());
end

function tf = exceptionEqualByClass(actualException, expMetaClass)
    % Test to determine whether we are satisfied by class
    tf = metaclass(actualException) <= expMetaClass;
end


function tf = recursivelyCompareExpected(actualException,expValue, causesEqual)
% Helper function to recursively find the expected value in the cause
% tree.

    tf = true;
    
    causes = actualException.cause;
    
    for n= 1:numel(causes)
        
        if causesEqual(causes{n}, expValue);
            return
        else
            if recursivelyCompareExpected(...
                causes{n},expValue,causesEqual)
                return
            end
        end
    end
    
    % If in actual, cause tree does not exist but expected causes is specified 
    tf = false;
end

 
function subDiag = generateActualValueDiagnostic(actHeader, actVal)
      import matlab.unittest.diagnostics.ConstraintDiagnostic; 
                        
      subDiag =  ConstraintDiagnostic;
      subDiag.DisplayActVal = true;
      subDiag.ActValHeader = actHeader;
      subDiag.ActVal = actVal;
end

% LocalWords:  maxlhs
