function constraint = convertStringToConstraint(string)

% Copyright 2013 The MathWorks, Inc.

validateattributes(string, {'char', 'matlab.unittest.constraints.Constraint'}, {'row'});
constraint = matlab.unittest.internal.selectors.convertValueToConstraint(string);