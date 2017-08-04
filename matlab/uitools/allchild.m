function ChildList=allchild(HandleList)
%ALLCHILD Get all object children
%   ChildList=ALLCHILD(HandleList) returns the list of all children 
%   (including ones with hidden handles) for each handle.  If 
%   HandleList is a single element, the output is returned in a 
%   vector.  Otherwise, the output is a cell array.
%
%   Example:
%       get(gca,'children')
%           %or
%       allchild(gca)
%
%   See also GET, FINDALL.

%   Loren Dean
%   Copyright 1984-2011 The MathWorks, Inc.
%    

error(nargchk(1,1,nargin));

% figure out which, if any, items in list don't refer to hg objects
hgIdx = ishghandle(HandleList); % index of hghandles in list
nonHGHandleList = HandleList(~hgIdx); 

% if any of the items in the nonHGHandlList aren't handles, error out
if ~isempty(nonHGHandleList) && ~all(ishandle(nonHGHandleList)),
  error(message('MATLAB:allchild:InvalidHandles'))
end  

% establish the root object
rootobj = allchildRootHelper(HandleList);

Temp=get(rootobj,'ShowHiddenHandles');
set(rootobj,'ShowHiddenHandles','on');
% Create protected cleanup
c = onCleanup(@()set(rootobj,'ShowHiddenHandles',Temp));
ChildList=get(HandleList,'Children');
