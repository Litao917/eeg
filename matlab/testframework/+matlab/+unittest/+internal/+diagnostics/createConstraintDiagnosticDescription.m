function description = createConstraintDiagnosticDescription(requirement, isSatisfied, consType)
% This function is undocumented.

%  Copyright 2013 MathWorks, Inc.
                               
import matlab.unittest.internal.diagnostics.DiagnosticSense;
import matlab.unittest.internal.diagnostics.createClassNameForCommandWindow;

isNegated = consType == DiagnosticSense.Negative;

if metaclass(requirement) <= ?matlab.unittest.internal.constraints.AliasDecorator
    cmdWindowName = requirement.Alias;
    isAliasDecorated = true;
else
    cmdWindowName = class(requirement);
    isAliasDecorated = false;
end

if isNegated && ~isAliasDecorated
    if isSatisfied
        messageID = 'NegatedRequirementCompletelySatisfied';
    else
        messageID = 'NegatedRequirementNotCompletelySatisfied';
    end
else
    if isSatisfied
        messageID = 'RequirementCompletelySatisfied';
    else
        messageID = 'RequirementNotCompletelySatisfied';
    end
end

catalog = matlab.internal.Catalog('MATLAB:unittest:ConstraintDiagnostic');
description = catalog.getString(messageID, createClassNameForCommandWindow(cmdWindowName));
end                                     
