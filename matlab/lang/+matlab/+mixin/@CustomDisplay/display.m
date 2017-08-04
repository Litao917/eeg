%DISPLAY Print variable name and display object
%   DISPLAY(A) prints the name of input argument A as it appears in the
%   workspace of the caller.  If no name is available, 'ans' is used as the
%   object's name.  It then calls the DISP method to print the object array.
%
%   This method is sealed by matlab.mixin.CustomDisplay.  To customize a
%   display format, override one or more of the unsealed
%   matlab.mixin.CustomDisplay methods.
%
%   See also matlab.mixin.CustomDisplay, disp  

%   Copyright 2013 The MathWorks, Inc.
%   Built-in method.   
