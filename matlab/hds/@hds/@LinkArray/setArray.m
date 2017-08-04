function setArray(this,DSArray)
%SETARRAY  Writes data link value (array of data set handles).
%
%   SETARRAY(LinkArray,DSArray)

%   Copyright 1986-2004 The MathWorks, Inc.

% Clear cached variable data (entire data link is being redefined)
LinkArray.LinkedVariables = [];
LinkArray.SharedVariables = [];

if isempty(DSArray)
   % Clear the link array
   this.Links = {};
else
   % Validate specified linked data sets (class and variables)
   this.checkLinks(DSArray);
   % Update the link array
   this.Links = DSArray;
end
