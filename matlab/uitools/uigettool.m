function [out] = uigettool(fig,id)
% This function is undocumented and will change in a future release

% C = UIGETTOOL(H,'GroupName.ComponentName')
%     H is a vector of toolbar handles or a figure handle
%     'GroupName' is the name of the toolbar group
%     'ComponentName' is the name of the toolbar component
%     C is a toolbar component
%
% See also UITOOLFACTORY

%   Copyright 1984-2007 The MathWorks, Inc.

% Note: All code here must have fast performance
% since this function will be used in callbacks.
if ~all(ishghandle(fig))
  error(message('MATLAB:uigettool:InvalidHandle'));
end
if length(fig) == 1 && ishghandle(fig,'figure')
  fig = findobj(allchild(fig),'flat','Type','uitoolbar');
end

out =[];
children = findall(fig);
% 'toolid' is used by GUIDE GUIs
for i=1:length(children)
    toolid = getappdata(children(i),'toolid');
    if isequal(get(children(i),'Tag'), id) || isequal(toolid, id) 
        out = [out; children(i)];
    end
end
