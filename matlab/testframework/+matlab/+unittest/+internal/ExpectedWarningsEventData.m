classdef(Hidden) ExpectedWarningsEventData <  event.EventData;
    
    properties
        ExpectedWarnings;
    end

    
    methods
        function evd = ExpectedWarningsEventData(warnings)
            evd.ExpectedWarnings = warnings;
        end
    end
end

