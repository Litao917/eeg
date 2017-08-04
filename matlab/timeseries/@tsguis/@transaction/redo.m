function redo(t)
%REDO  Redoes transaction.

%   Copyright 2004-2006 The MathWorks, Inc.

% Redo transaction
for k=1:length(t.ObjectsCell)
    t.ObjectsCell{k}.TsValue = t.FinalValue{k};
end
