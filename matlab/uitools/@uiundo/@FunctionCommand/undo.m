function undo(hThis)

% Copyright 2002-2012 The MathWorks, Inc.

try
    feval(hThis.InverseFunction,hThis.InverseVarargin{:});
catch ex
    newExc = MException('MATLAB:undo:CannotUndoCommand','%s',...
        getString(message('MATLAB:uistring:uiundo:CannotUndoCommand', ...
        ex.message)));
    newExc = newExc.addCause(ex);
    throw(newExc);
end

