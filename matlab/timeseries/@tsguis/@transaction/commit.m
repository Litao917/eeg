function commit(t)
%COMMIT  Commits transaction.

%   Copyright 2004-2006 The MathWorks, Inc.


%% No-op if the transaction was created with 'notrans' (only for recording)
if isempty(t.ObjectsCell)
    return
end
t.FinalValue = cell(length(t.ObjectsCell),1);
for k=1:length(t.ObjectsCell)
    t.FinalValue{k} = t.ObjectsCell{k}.TsValue;
end
