function undo(t)
%UNDO  Undo transaction.

%   Copyright 2004-2006 The MathWorks, Inc.

for k=1:length(t.ObjectsCell)
    t.ObjectsCell{k}.TsValue = t.InitialValue{k};
end

