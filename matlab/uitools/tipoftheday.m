function varargout = tipoftheday(tag, tip_fcn)
% This function is undocumented and will change in a future release
 
% TIPOFTHEDAY   Launches a Tip of the Day window.
%   HFIG = TIPOFTHEDAY(TAG, TIPFCN)  Launches a Tip of the Day window and
%   returns the handle to the figure created.  TIPFCN is a function handle
%   which must take an integer index and return a string to be used for the
%   tip.  This function will be called at launch and when the user presses
%   the 'Next' button.  The index passed to TIPFCN will be incremented each
%   time the 'Next' button is pressed and each time that the TIPOFTHEDAY
%   function is called.  TAG is a unique string used to identify the
%   instance of Tip of the Day so that its settings can be restored from
%   previous instances.
%
%   TIPOFTHEDAY(TAG)  Returns a boolean indicating the previous state of
%   the 'Don't show me this again' checkbox.  It is up to the caller of
%   TIPOFTHEDAY to determine whether they want to actually launch the
%   dialog by passing the TIPFCN input.
%
%   Example:
%       h = tipoftheday('example_tips', @gettipoftheday);
%
%       % Add this function on to your path.
%       % -------------------------------------------------
%       function tip = gettipoftheday(indx)
%
%       switch rem(indx, 6)
%           case 0
%               tip = ['MATLABs current directory browser can analyze your code' ...
%                   ' for programming style and efficiency.  Launch the current' ...
%                   ' directory browser and select ''M-Lint Code Check Report' ...
%                   ' from the drop down menu.'];
%           case 1
%               tip = ['MATLABs command history window can be used to generate' ...
%                   ' M-files.  Launch the command history window, select a' ...
%                   ' few lines of code, right click on the select and choose' ...
%                   ' Create M-File.'];
%           case 2
%               tip = ['MATLAB now supports block comments.  Use the characters' ...
%                   ' ''%{'' to indicate the beginning and ''%}'' to indciate' ...
%                   ' the end of a block comment.'];
%           otherwise
%               tip = sprintf('This tip #%d', indx);
%       end
%       % -------------------------------------------------
%
%   See also MSGBOX, ERRORDLG, WARNDLG.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

error(nargchk(1,2,nargin));

% Build the default info structure.
info.Index = 1;
info.DontShowAgain = 0;

% See if we already have information saved.
info = getpref('TipOfTheDay', tag, info);

if nargin < 2
    % If the user asked for the don't show again state, return it.
    varargout = {info.DontShowAgain};
    return;
end

pf = get(0,'ScreenPixelsPerInch')/96;
if isunix,
    pf = 1;
end

% Draw the figure.
h.figure = figure('Visible', 'Off', ...
    'Resize',           'Off', ...
    'HandleVisibility', 'Off', ...
    'NumberTitle',      'Off', ...
    'IntegerHandle',    'Off', ...
    'WindowStyle',      'Normal', ...
    'DockControls',     'Off', ...
    'MenuBar',          'None', ...
    'Color',            get(0, 'DefaultUicontrolBackgroundColor'), ...
    'Name',             getString(message('MATLAB:uistring:tipoftheday:TitleTipOfTheDay')), ...
    'CloseRequestFcn',  @close_cb, ...
    'Position',         [500 300 400 200]*pf);

% Add a beveled frame for the text.
h.frame = uipanel(h.figure, ...
    'Units', 'Pixels', ...
    'BorderType', 'beveledin', ...
    'BorderWidth', 2, ...
    'BackgroundColor', 'w', ...
    'Position', [6 31 390 164]*pf);

% Add an axes for the icon.
h.icon = axes('Parent', h.frame, ...
    'Units', 'Pixels', ...
    'Position', [6*pf 119*pf 28 37]);

% Load the icons.
icons = load('dialogicons');

% Add the lightbulb to the axes.
h.image = image('CData',icons.lightbulbIconData, 'Parent', h.icon);

% Set up the axes to display the icon correctly.
set(h.icon, ...
    'Box',    'off', ...
    'YDir',   'reverse', ...
    'XColor', 'w', ...
    'YColor', 'w', ...
    'XLim',   get(h.image, 'XData')+[-0.5 0.5], ...
    'YLim',   get(h.image, 'YData')+[-0.5 0.5], ...
    'XTick',  [], ...
    'YTick',  []);

% Set up the color map for the figure.
set(h.figure, 'Colormap', icons.lightbulbIconMap);

% Add the 'Did you know ...' text.
h.didyouknow = uicontrol(h.frame, ...
    'Style', 'text', ...
    'Tag', 'didyouknow', ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold', ...
    'BackgroundColor', 'w', ...
    'Position', [46 129 230 20]*pf, ...
    'String', getString(message('MATLAB:uistring:tipoftheday:LabelDidYouKnow')));

% Add the tip area text.

h.display = uicontrol(h.frame, ...
    'Style', 'text', ...
    'Tag', 'display', ...
    'Enable', 'Inactive', ...
    'HorizontalAlignment', 'Left', ...
    'BackgroundColor', 'w', ...
    'Position', [6 6 370 105]*pf, ...
    'String', tip_fcn(info.Index));

% Add the Don't show me again checkbox.
h.dontshowmeagain = uicontrol(h.figure, ...
    'Style', 'Checkbox', ...
    'Callback', @checkbox_cb, ...
    'Tag', 'dontshowmeagain', ...
    'Position', [6 6 278 20]*pf, ...
    'Value', info.DontShowAgain, ...
    'String', getString(message('MATLAB:uistring:tipoftheday:ButtonDontShowMeThisAgain')));

% Add the next button.
h.next = uicontrol(h.figure, ...
    'Style', 'pushbutton', ...
    'Tag', 'next', ...
    'Callback', @next_cb, ...
    'Position', [289 6 51 20]*pf, ...
    'String', getString(message('MATLAB:uistring:tipoftheday:ButtonNext')));

% Add the close button.
h.close = uicontrol(h.figure, ...
    'Style', 'pushbutton', ...
    'Tag', 'close', ...
    'Callback', @close_cb, ...
    'Position', [345 6 51 20]*pf, ...
    'String', getString(message('MATLAB:uistring:tipoftheday:ButtonClose')));

set(h.figure, 'Visible', 'On');

if nargout
    varargout = {h.figure};
end

% -------------------------------------------------------------------------
    function close_cb(hcbo, eventStruct) %#ok

        % Increment the Index so that we get a new tip the next time the
        % dialog is launched.
        info.Index = info.Index+1;

        % Save the preferences.
        setpref('TipOfTheDay', tag, info);

        % Destroy the figure.
        delete(h.figure);
    end

% -------------------------------------------------------------------------
    function checkbox_cb(hcbo, eventStruct) %#ok

        % Set the DontShowAgain flag to false.  We will save at close time.
        info.DontShowAgain = get(hcbo, 'Value');
    end

% -------------------------------------------------------------------------
    function next_cb(hcbo, eventStruct) %#ok

        % Increment the Index
        info.Index = info.Index+1;

        % Update the display.
        set(h.display, 'String', tip_fcn(info.Index));
    end
end

% [EOF]
