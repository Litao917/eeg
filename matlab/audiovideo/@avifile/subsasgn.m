function obj=subsasgn(obj,subscript,value)
%SUBSASGN subsasgn for an avifile object

%   Copyright 1984-2013 The MathWorks, Inc.

if length(subscript) > 1
  error(message('MATLAB:audiovideo:avisubsasgn:invalidSubscriptLength'));
end

switch subscript.type
 case '.'
  param = subscript.subs;
  obj = set(obj,param,value);
 otherwise
  error(message('MATLAB:audiovideo:avisubsasgn:invalidSubscriptType'))
end
