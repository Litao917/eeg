%DISP Simple informal object display
%   DISP(A) displays the contents of the object array A in one of four simple
%   formats, based on the state of A:  deleted, empty, scalar, and
%   non-scalar.
%
%   This method is sealed by matlab.mixin.CustomDisplay.  To customize a
%   display format, override one or more of the unsealed
%   matlab.mixin.CustomDisplay methods.
%   
%   See also matlab.mixin.CustomDisplay, getHeader, getFooter,
%   getPropertyGroups, displayScalarObject, displayNonScalarObject,
%   displayEmptyObject

%   Copyright 2012 The MathWorks, Inc.
%   Built-in method.   
