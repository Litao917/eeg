function out = length(obj)
%LENGTH Length of timer object array.
%
%    LENGTH(OBJ) returns the length of timer object array,
%    OBJ. It is equivalent to MAX(SIZE(OBJ)).  
%    
%    See also TIMER/SIZE.
%

%    RDD 1-8-2002
%    Copyright 2001-2007 The MathWorks, Inc.


% The jobject property of the object indicates the number of 
% objects that are concatenated together.
try
   out = builtin('length', obj.jobject);
catch exception  %#ok<NASGU>
   out = 1;
end




