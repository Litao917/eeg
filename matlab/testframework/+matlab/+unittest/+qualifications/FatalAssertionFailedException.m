classdef(Sealed) FatalAssertionFailedException < matlab.unittest.internal.qualifications.QualificationFailedException
    % FatalAssertionFailedException - MException used for fatal assertions failures.
    %
    %   This class is meant to be used exclusively by the fatal assert
    %   qualification type in matlab.unittest.
    %
    %   See also
    %      matlab.unittest.qualifications.FatalAssertable
    
    % Copyright 2010-2013 The MathWorks, Inc.
    methods
        function exception = FatalAssertionFailedException(id, message, varargin)
            exception = exception@matlab.unittest.internal.qualifications.QualificationFailedException(id, message, varargin{:});
        end
    end
end
