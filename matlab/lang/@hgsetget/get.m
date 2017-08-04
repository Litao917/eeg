%GET    Get MATLAB object properties.
%   V = GET(H, 'PropertyName') returns the value of the specified
%   property for the MATLAB object with handle H.  If H is an array of  
%   handles, GET returns an M-by-1 cell array of values, where M is equal
%   to length(H).  If 'PropertyName' is replaced by a 1-by-N or N-by-1
%   cell array of strings containing property names, GET returns an M-by-N
%   cell array of values.  For non-scalar H, if 'PropertyName' is a 
%   dynamic  property, GET returns a value only if the property exists in 
%   all objects of the array.
%
%   V = GET(H) returns a structure in which each field name is the name of
%   a user-gettable property of H and each field contains the value of that
%   property.  If H is non-scalar, GET returns a struct array with 
%   dimensions M-by-1, where M = numel(H).  If H is non-scalar, GET does 
%   not return dynamic properties.
%
%   GET(H) displays the names of all user-gettable properties and their 
%   current values for the MATLAB object with handle H.  The class can 
%   override the GETDISP method to control how this information is 
%   displayed.  H must be scalar.
%
%   See also GET, HGSETGET, HGSETGET/GETDISP, HANDLE
 
%   Copyright 2007-2013 The MathWorks, Inc.
%   Built-in function.