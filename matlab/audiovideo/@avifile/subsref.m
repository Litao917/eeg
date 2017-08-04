function value=subsref(obj,subscript)
%SUBSREF subsref for a AVIFILE object

%   Copyright 1984-2013 The MathWorks, Inc.

if length(subscript) > 1
  error(message('MATLAB:audiovideo:avisubsref:invalidSubscriptLength'));
end

switch subscript.type
 case '.'
  param = subscript.subs;    
  value = get(obj,param);
 otherwise
  error(message('MATLAB:audiovideo:avisubsref:invalidSubscriptType'))
end
