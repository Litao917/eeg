function f = ismethod(obj,name)
%ISMETHOD  True if method of object.
%   ISMETHOD(OBJ,NAME) returns 1 if string NAME is a method of object
%   OBJ, and 0 otherwise.
%
%   Example:
%     Hd = dfilt.df2;
%     f = ismethod(Hd, 'order')
%
%   See also METHODS.  
  
%   Author: Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

error(nargchk(2,2,nargin,'struct'))

i = strmatch(name,methods(obj),'exact');
f = ~isempty(i);