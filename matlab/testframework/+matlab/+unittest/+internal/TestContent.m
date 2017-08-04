classdef(Hidden) TestContent < matlab.unittest.internal.Teardownable & matlab.unittest.internal.ObsoleteTestResultHolder
    
    %  Copyright 2012-2013 The MathWorks, Inc.
    
    events (NotifyAccess=?matlab.unittest.TestRunner)
        % ExceptionThrown - Event triggered when an exception is thrown
        %   The ExceptionThrown event provides a means to observe and react
        %   to when an exception is thrown during test content execution.
        %   Callback functions listening to this event receive information
        %   about the unexpected exception caught in the form of
        %   ExceptionEventData. 
        %
        %   NOTE: The TestRunner must be used to execute the test content
        %   in order for the callback to be triggered.
        %
        %   See also: matlab.unittest.qualifications.ExceptionEventData
        ExceptionThrown
    end
end

% LocalWords:  Teardownable
