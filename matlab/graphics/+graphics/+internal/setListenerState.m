function setListenerState(hList,state)
%SETLISTENERSTATE Helper function to set the Enabled property of listeners
%
%   Copyright 2011 The MathWorks, Inc.

if strcmp(state,'off')
    if ~graphicsversion(hList,'handlegraphics')
        offVal = repmat({false},size(hList));
        [hList.Enabled] = deal(offVal{:});
    else
        set(hList,'Enabled','off');
    end
elseif strcmp(state,'on')
    if ~graphicsversion(hList,'handlegraphics')
        onVal = repmat({true},size(hList));
        [hList.Enabled] = deal(onVal{:});
    else
        set(hList,'Enabled','on');
    end
else 
    error(message('MATLAB:hg:InvalidListenerState'));
end