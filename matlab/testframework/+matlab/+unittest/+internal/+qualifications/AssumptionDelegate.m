classdef AssumptionDelegate < matlab.unittest.internal.qualifications.QualificationDelegate
    % Copyright 2011-2012 The MathWorks, Inc.
        
    properties(Constant, Access=protected)
        Type = 'assume';
        IsTrueConstraint = matlab.unittest.internal.qualifications.QualificationDelegate.generateIsTrueConstraint('assume'); 
    end
    methods        
        function doFail(~)
            import matlab.unittest.qualifications.AssumptionFailedException;
            
            msg = message('MATLAB:unittest:Assumable:AssumptionFailed');
            ex = AssumptionFailedException(msg.Identifier, msg.getString);
            throw(ex);
        end
    end
end

