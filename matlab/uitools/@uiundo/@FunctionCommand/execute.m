function execute(hThis)

% Copyright 2002-2012 The MathWorks, Inc.

try 
  feval(hThis.Function,hThis.Varargin{:});
catch ex
   newExc = MException('MATLAB:execute:CommandExecutionFailed','%s',...
       getString(message('MATLAB:uistring:uiundo:CommandExecutionFailed', ...
       ex.message)));
   newExc = newExc.addCause(ex);
   throw(newExc);
end