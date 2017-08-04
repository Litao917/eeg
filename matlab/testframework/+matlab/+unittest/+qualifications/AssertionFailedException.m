classdef AssertionFailedException < matlab.unittest.internal.qualifications.QualificationFailedException
    % AssertionFailedException - Exception used for assertion failures.
    %
    %   This class is meant to be used exclusively by the 'assert'
    %   qualification type in matlab.unittest.
    %
    %   See also
    %       matlab.unittest.qualifications.Assertable
    
    % Copyright 2010-2013 The MathWorks, Inc.
    methods
        function exception = AssertionFailedException(id, message, varargin)
            exception = exception@matlab.unittest.internal.qualifications.QualificationFailedException(id, message, varargin{:});
        end
    end
end
