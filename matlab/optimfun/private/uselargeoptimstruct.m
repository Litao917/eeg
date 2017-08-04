function val = uselargeoptimstruct
% Check to see if the large options structure should be returned.

%   Copyright 2008 The MathWorks, Inc.

val = license('test','Optimization_Toolbox') || ...
                license('test','curve_fitting_toolbox') || ...
                license('test','statistics_toolbox') || ...
                license('test','simulink_control_design');