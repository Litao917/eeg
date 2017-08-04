classdef AssumptionFailedException < matlab.unittest.internal.qualifications.QualificationFailedException
    % AssumptionFailedException - Exception used for assumption failures.
    %
    %   This class is meant to be used exclusively by the 'assume'
    %   qualification type in matlab.unittest.
    %
    %   See also
    %       matlab.unittest.qualifications.Assumable
    
    % Copyright 2010-2013 The MathWorks, Inc.
    methods
        function exception = AssumptionFailedException(id, message, varargin)
            exception = exception@matlab.unittest.internal.qualifications.QualificationFailedException(id, message, varargin{:});
        end
    end
end
