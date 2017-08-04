classdef AssertionDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
  
    % Copyright 2011-2012 The MathWorks, Inc.
    
    properties(Constant, Access=protected)
        Type = 'assert';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('assert'); 
    end
    
    
    
    methods
        function doFail(~)
            import matlab.unittest.qualifications.AssertionFailedException;
            
            msg = message('MATLAB:unittest:Assertable:AssertionFailed');
            ex = AssertionFailedException(msg.Identifier, msg.getString);
            throw(ex);
        end
    end
end
