classdef FatalAssertionDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
    % Copyright 2011-2012 The MathWorks, Inc.
    properties(Constant, Access=protected)
        Type = 'fatalAssert';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('fatalAssert'); 
    end
    
    
    methods        
        function doFail(~)
            import matlab.unittest.qualifications.FatalAssertionFailedException;
            
            msg = message('MATLAB:unittest:FatalAssertable:FatalAssertionFailed');
            ex = FatalAssertionFailedException(msg.Identifier, msg.getString);
            throw(ex);
        end
    end
end

