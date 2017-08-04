function bfitSetListenerEnabled(L, state)
%BFITSETLISTENERENABLED   Set the enabled state for a listener
%
%   BFITSETLISTENERENABLED(L, STATE) sets the enabled state of the listener L.
%   STATE is a logical scalar.  This function will work correctly with both
%   old and new style listeners.

%   Copyright 2008-2011 The MathWorks, Inc.
%        

% non-HGUsingMATLABClasses/HGUsingMATLABClasses Safe way to set the Enabled 
% property of a listener
if ~graphicsversion(L,'handlegraphics')
    L.Enabled = state;
else
    if state
        L.Enabled = 'on';
    else
        L.Enabled = 'off';
    end
end
