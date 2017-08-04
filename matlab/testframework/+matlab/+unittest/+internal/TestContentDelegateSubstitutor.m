classdef (Hidden) TestContentDelegateSubstitutor
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods (Static)
        function transferTeardownDelegate(supplier, acceptor)
            supplier.transferTeardownDelegate_(acceptor);
        end
        
        function substituteFixtureQualifiable(newQualifiable, fixture)
            fixture.substituteQualifiable_(newQualifiable);
        end
    end
end

% LocalWords:  Qualifiable
