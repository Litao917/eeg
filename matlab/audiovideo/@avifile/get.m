function value = get(obj,param)
% GET Query AVIFILE properties
%
%   VALUE = GET(AVIOBJ,'PropertyName') returns the value of the specified
%   property of the AVIFILE object AVIOBJ.  
%  
%   Although GET will return the values of many properties of the AVIFILE
%   object, some properties are not allowed to be modified.  They are
%   automatically updated as frames are added with ADDFRAME.  
%
%    Note: This function is a helper for SUBSREF and is not intended for
%    users.  To retrieve property values of the AVIFILE object, use
%    structure notation.  For example:
%
%               value = obj.Fps;

%   Copyright 2000-2013 The MathWorks, Inc.

value = privateGet(obj,param);

