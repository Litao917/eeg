classdef ExceptionEventData < event.EventData
    % ExceptionEventData - EventData passed to 'ExceptionThrown' event listeners.
    %
    %   The ExceptionEventData is EventData passed to listeners listening
    %   to the ExceptionThrown event, which is notified when TestRunner
    %   encounters an error during test content execution.
    %
    %   ExceptionEventData properties:
    %       Exception - Unexpected exception caught
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Exception - Unexpected exception caught
        %   
        %   The unexpected exception caught by TestRunner during test
        %   execution. 
        %
        %   See also:
        %       matlab.unittest.TestRunner
        Exception
    end
    
    methods
        function evd = ExceptionEventData(exception)
            validateattributes(exception, {'MException'}, {'scalar'}, '', 'exception');
            evd.Exception = exception;
        end
    end
end

% LocalWords:  evd
