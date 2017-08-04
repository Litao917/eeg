function deleteview(this)
%DELETEVIEW  Deletes @view and associated g-objects.

%  Copyright 1986-2008 The MathWorks, Inc.

%% Overloaded since the call to ghandles in the parent method cannot return
%% the links or the labels

for ct = 1:length(this)
   delete(this(ct).VLines(ishghandle(this(ct).VLines)));
   delete(this(ct).Points(ishghandle(this(ct).Points)));
end

% Delete views
delete(this)
