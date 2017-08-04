function hWinMenu = createWinMenu(hFig,label)
% This function is undocumented and will change in a future release

%CREATEWINMENU Add a standard "Window" menu to a Figure's menubar
%
%  CREATEWINMENU(F) adds a standard "Window" menu to figure F's menubar.
%
%  CREATEWINMENU(F,LABEL) adds a window menu with the user-specified
%  label L to figure F's menubar.
%
%  If the figure handle F is not specified, 
%  CREATEWINMENU operates on the current figure(GCF).
%
%  H = CREATEWINMENU(...) returns the handle to the new menu.
%
%  On Mac with the screen menubar enabled, if the figure is not visible
%  when this function is called, the figure itself will not appear in the
%  window menu the first time the user clicks on the menu.

%   Copyright 2011 The MathWorks, Inc.

if feature('showFigureWindows')
    if (nargin == 0)
        hFig = gcf;
    end
    if (nargin < 2)
        label = getString(message('MATLAB:uistring:figuremenu:Label_figMenuWindow'));
    end
    if graphicsversion(hFig, 'handlegraphics')
        hWinMenu = uimenu(hFig, 'Label',label,'Callback', winmenu('callback'),...
                    'Tag','winmenu');
    else
        hWinMenu = double(uimenu(hFig, 'Label',label,'Callback', winmenu('callback'),...
                    'Tag','winmenu'));
    end

    if ismac
        % g696470: invoke the callback once to set up the initial state of the menu
        if graphicsversion(hFig, 'handlegraphics')
            winmenu(hFig);
        else
            winmenu(double(hFig));
        end
    end
end
