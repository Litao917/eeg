function scribeclearmode(fig,varargin)
%SCRIBECLEARMODE  Plot Editor helper function
%   Utility for cooperative mode switching.  Before taking over a
%   figure, call 
%       SCRIBECLEARMODE(Fig, OffCallbackFcn, Args, ...)
%
%   The OffCallbackFcn is stored with on the figure and is
%   executed with the arguments Args the next time OffCallbackFcn
%   is called.  In other words, SCRIBECLEARMODE notifies the
%   current mode that a new mode is taking over and also installs
%   its own notification function.

%   Copyright 1984-2010 The MathWorks, Inc. 

% clear the current mode
if ~graphicsversion(fig,'handlegraphics')
    if isprop(fig,'ScribeClearModeCallback')
        s = fig.ScribeClearModeCallback;
    else
        s = [];
    end
else
    s = getappdata(fig,'ScribeClearModeCallback');
end
if ~isempty(s) && iscell(s)
   func = s{1};
   if length(s)>1
      feval(func,s{2:end});
   else
      feval(func);
   end
end

% set notification callback for the new mode
if nargin>2
   s = varargin;
   if ~graphicsversion(fig,'handlegraphics')
       if ~isprop(fig,'ScribeClearModeCallback')
           p = addprop(fig,'ScribeClearModeCallback');
           p.Transient = true;
           p.Hidden = true;
       end    
       fig.ScribeClearModeCallback = s;
   else        
       setappdata(fig,'ScribeClearModeCallback',s);
   end
else
   if ~graphicsversion(fig,'handlegraphics')
       if isprop(fig,'ScribeClearModeCallback')
           fig.ScribeClearModeCallback = [];
       end
   elseif isappdata(fig,'ScribeClearModeCallback')
      rmappdata(fig,'ScribeClearModeCallback');
   end
end