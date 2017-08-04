function SavedData = saveobj(this)
% SAVE method for @variable class

%   Copyright 1986-2005 The MathWorks, Inc.

% Serialize variable as its name
SavedData = this.Name;