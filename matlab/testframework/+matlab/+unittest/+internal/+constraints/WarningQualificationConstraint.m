classdef WarningQualificationConstraint < matlab.unittest.internal.constraints.FunctionHandleConstraint & ...
                                          matlab.unittest.internal.constraints.WhenNargoutIsMixin
    % Internal only class which interacts with the warning log in order to test
    % for expected warnings
    %
    
    % Copyright 2011-2013 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % FunctionOutputs - cell array of outputs produced when invoking
        %   the supplied function handle
        %
        %   The FunctionOutputs property contains a cell array of output
        %   arguments that are produced when the supplied function handle
        %   is invoked. The number of outputs is determined by the Nargout
        %   property.
        %
        %   This property is read only and is set when the function handle
        %   is invoked.
        FunctionOutputs = cell(1,0);
    end
    
    properties(Hidden, SetAccess=private, GetAccess=protected)
        ActualWarningsIssued
    end
    
    properties(Hidden, Dependent,SetAccess=private,GetAccess=protected)
        ActualWarnings
        HasIssuedSomeWarnings
    end
    
    
    methods(Abstract,Hidden, Access=protected)
        processWarnings(constraint)
    end
    
    methods
        function identifiers = get.ActualWarnings(constraint)
            identifiers = {constraint.ActualWarningsIssued.identifier};
        end     
        function tf = get.HasIssuedSomeWarnings(constraint)           
            tf = ~isempty(constraint.ActualWarningsIssued);
        end
    end
    
    methods(Hidden, Access=protected)
        function invoke(constraint, fcn)
            % Invoke the function in such a way as to capture issued warnings.
            
            import matlab.unittest.internal.constraints.WarningLogger;
            
            logger = WarningLogger;
            logger.start();
            [constraint.FunctionOutputs{1:constraint.Nargout}] = ...
                constraint.invoke@matlab.unittest.internal.constraints.FunctionHandleConstraint(fcn);
            logger.stop();
            
            constraint.ActualWarningsIssued = logger.Warnings;
            constraint.processWarnings;
        end
        
        function list = convertToDisplayableList(~, warnings)
            % This method takes a cell array of strings (ids) and produces a "pretty"
            % string appropriate for display (e.g., in diagnostics)
            list = sprintf('\t%s\n', warnings{:});
            list = list(1:end-1); % remove the trailing newline
        end
        
    end
    
end

