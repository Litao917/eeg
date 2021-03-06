function varargout=web(varargin)
%WEB Open Web site or file in Web browser.
%   WEB opens an empty MATLAB Web browser.
%
%   WEB URL displays the page specified by url in the MATLAB Web browser.
%   If any MATLAB Web browsers are already open, it displays the page in
%   the browser that was used last. The web function accepts a valid URL
%   such as a web site address, a full path to a file, or a relative path
%   to a file (using url within the current folder if it exists there). If
%   url is located inside the installed documentation, the page displays in
%   the MATLAB Help browser instead of the MATLAB Web browser.
%
%   WEB URL -NEW displays the page specified by url in a new MATLAB Web
%   browser.
%
%   WEB URL -NOTOOLBAR displays the page specified by url in a MATLAB Web
%   browser that does not include the toolbar and address field. If any
%   MATLAB Web browsers are already open, also use the -new option.
%   Otherwise url displays in the browser that was used last, regardless of
%   its toolbar status.
%
%   WEB URL -NOADDRESSBOX displays the page specified by url in a MATLAB Web
%   browser that does not include the address field. If any MATLAB Web
%   browsers are already open, also use the -new option. Otherwise url
%   displays in the browser that was used last, regardless of its address
%   field status.
%
%   WEB URL -BROWSER displays url in a system Web browser window. url can
%   be in any form that the browser supports. On Microsoft Windows and
%   Apple Macintosh platforms, the system Web browser is determined by the
%   operating system.  On UNIX platforms, the default system Web browser
%   for MATLAB is Mozilla Firefox.  To specify a different browser, use
%   MATLAB Web preferences.
%
%   STAT = WEB(...) -BROWSER returns the status of the WEB command in the
%   variable STAT. STAT = 0 indicates successful execution. STAT = 1
%   indicates that the browser was not found. STAT = 2 indicates that the
%   browser was found, but could not be launched.
%
%   [STAT, BROWSER] = WEB returns the status, and a handle to the last
%   active browser.
%
%   [STAT, BROWSER, URL] = WEB returns the status, a handle to the last
%   active browser, and the URL of the current location.
%
%   Examples:
%      web http://www.mathworks.com 
%         loads the MathWorks Web site home page into the MATLAB Web browser.web 
%      
%      web file:///disk/dir1/dir2/foo.html
%         opens the file foo.html in the MATLAB Web browser.
%
%      web mydir/myfile.html 
%         opens myfile.html in the MATLAB Web browser, where
%      mydir is in the current folder.
%
%      web(['file:///' which('foo.html')])
%         opens foo.html if the file is in a folder on the search path or
%         in the current folder for MATLAB.
%
%      web('text://<html><h1>Hello World</h1></html>') 
%         displays the HTML-formatted text Hello World.
%    
%      web('http://www.mathworks.com', '-new', '-notoolbar') 
%         loads the MathWorks Web site home page into a new MATLAB Web
%         browser that does not include a toolbar or address field.
%
%      web file:///disk/dir1/foo.html -browser
%         opens the file foo.html in the system Web browser.
%
%      web mailto:email_address 
%         uses the system browser's default email application to send a
%         message to email_address.
%
%      web http://www.mathtools.net -browser 
%         opens the system Web browser at mathtools.net. 
%
%      [stat,h1]=web('http://www.mathworks.com'); 
%         opens mathworks.com in a MATLAB Web browser. Use close(h1) to
%         close the browser window.

%   Copyright 1984-2013 The MathWorks, Inc.

% Examine the inputs to see what options are selected.
[options, html_file] = examineInputs(varargin{:});

% Handle matlab: protocol by passing the command to evalin.
if strncmp(html_file, 'matlab:', 7)
    evalin('caller', html_file(8:end));
    return;
end

% Redirect links to old demo pages to corresponding Examples pages.
[redirect,mapfile,topic] = helpUtils.checkForDemoRedirect(html_file);
if redirect
    helpview(mapfile,topic)
    return
end

if ~options.useSystemBrowser && usejava('mwt') && ~strncmp(html_file,'mailto:',7)
    % If in Java environment, use the MATLAB web browser for everything
    % other than mailto.
    [activeBrowser, html_file] = openMatlabBrowser(html_file, options);
    if nargout > 0
        varargout = {0 activeBrowser html_file};
    end
    return;
elseif ~usejava('mwt') && helpUtils.isUnderDocroot(html_file)
    displayWarningMessage(message('MATLAB:web:NoHelpBrowser'), ...
        options.showWarningInDialog);
    if nargout > 0
        varargout = {1 [] ''};
    end
    return;
end

% Otherwise, use system web browser.

% If no URL is specified with system browser, complain and exit.
if isempty(html_file)
    displayWarningMessage(message('MATLAB:web:NoURL'),...
        options.showWarningInDialog);
    if nargout > 0
        varargout(1) = {1};
    end;
    return;
end

% We'll only issue a warning for a system error if we will not be 
% returning a status code.
options.warnOnSystemError = nargout == 0;

% open HTML file in system browser
if isOnFileSystem(html_file)
    html_file = helpUtils.removeDotsFromFilePath(html_file);
end

if ismac
    % We can't detect system errors on the Mac, so the warning options are unnecessary.
    stat = openMacBrowser(html_file);
elseif isunix
    stat = openUnixBrowser(html_file, options);
elseif ispc
    stat = openWindowsBrowser(html_file, options);
end

if nargout > 0
    varargout(1) = {stat};
end
end

%--------------------------------------------------------------------------
function [options, html_file] = examineInputs(varargin)
% Initialize defaults.
options = struct;

% If running in deployed mode, use the system browser since the builtin
% web browser is not available.
options.useSystemBrowser = isdeployed;
options.showWarningInDialog = 0;
options.useHelpBrowser = 0;
options.newBrowser = 0;
options.showToolbar = 1;
options.showAddressBox = 1;

html_file = [];

for i = 1:length(varargin)
    argName = strtrim(varargin{i});
    if strcmp(argName, '-browser') == 1
        options.useSystemBrowser = 1;
    elseif strcmp(argName, '-display') == 1
        options.showWarningInDialog = 1;
    elseif strcmp(argName, '-helpbrowser') == 1
        options.useHelpBrowser = 1;
    elseif strcmp(argName, '-new') == 1
        options.newBrowser = 1;
    elseif strcmp(argName, '-notoolbar') == 1
        options.showToolbar = 0;
    elseif strcmp(argName, '-noaddressbox') == 1
        options.showAddressBox = 0;
    else
        % assume this is the filename.
        html_file = argName;
    end
end
html_file = resolveUrl(html_file);
end

%--------------------------------------------------------------------------
function html_file = resolveUrl(html_file)
if ~isempty(html_file)
    if length(html_file) < 7 || ~(strcmp('text://', html_file(1:7)) == 1 || strcmp('http://', html_file(1:7)) == 1)
        % If the file is on MATLAB's search path, get the fully qualified
        % filename.
        fullpath = which(html_file);
        if ~isempty(fullpath)
            % This means the file is on the path somewhere.
            html_file = fullpath;
        else
            % If the file is referenced as a relative path, get the fully
            % qualified filename.
            fullpath = fullfile(pwd,html_file);
            if isOnFileSystem(fullpath)
                html_file = fullpath;
            end
        end
    end
end
end

%--------------------------------------------------------------------------
function [activeBrowser, html_file] = openMatlabBrowser(html_file, options)

% Initialize the active browser.
activeBrowser = [];

% if the file is under docroot, use the help browser.
options.useHelpBrowser = options.useHelpBrowser || helpUtils.isUnderDocroot(html_file);

% If no protocol specified, or an absolute/UNC pathname is not given,
% include explicit 'http:'.  Otherwise the web browser assumes 'file:'
if ~isempty(html_file) && isempty(strfind(html_file,':')) && ~strcmp(html_file(1:2),'\\') && ~strcmp(html_file(1),'/')
    html_file = ['http://' html_file];
end

% The file should be displayed inside the help browser
if options.useHelpBrowser
    if strncmp(html_file,'text://',7)
        com.mathworks.mlservices.MLHelpServices.setHtmlText(html_file(8:end));
    else
        com.mathworks.mlservices.MLHelpServices.setCurrentLocation(html_file);
    end
else
    activeBrowser = [];
    if ~options.newBrowser
        % User doesn't want a new browser, so find the active browser.
        activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser;
    end
    if isempty(activeBrowser)
        % If there is no active browser, create a new one.
        activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.createBrowser(options.showToolbar, options.showAddressBox);
    end
    
    if ~isempty(html_file)
        if strncmp(html_file,'text://',7)
            activeBrowser.setHtmlText(html_file(8:end));
        else
            activeBrowser.setCurrentLocation(html_file);
        end
    else
        html_file = char(activeBrowser.getCurrentLocation);
    end
end

end

%--------------------------------------------------------------------------
function stat = openMacBrowser(html_file)
% Escape some special characters.  We're eventually going to shell out,
% and  while some shells (such as bash) can handle the characters,
% some others (such as tcsh) can't.
html_file = regexprep(html_file, '[?&!();]','\\$0');

% Since we're opening the system browser using the NextStep open command,
% we must specify a syntactically valid URL, even if the user didn't
% specify one.  We choose The MathWorks web site as the default.
if isempty(html_file)
    html_file = 'http://www.mathworks.com';
else
    % If no protocol specified, or an absolute/UNC pathname is not given,
    % include explicit 'http:'.  MAC command needs the http://.
    if isempty(strfind(html_file,':')) && ~strcmp(html_file(1:2),'\\') && ~strcmp(html_file(1),'/')
        html_file = ['http://' html_file];
    end
end
unix(['open ' html_file]);
stat = 0;
end

%--------------------------------------------------------------------------
function stat = openUnixBrowser(html_file,options)
stat = 0;

% Get the system browser and options from the preferences.
doccmd = system_dependent('getpref', 'HTMLSystemBrowser');
unixOptions = system_dependent('getpref', 'HTMLSystemBrowserOptions');
unixOptions = unixOptions(2:end);  % Strip off the S

if isempty(doccmd)
    % The preference has not been set from the preferences dialog, so use the default.
    doccmd = 'firefox';
else
    % Strip off the "S" which was returned by the system_dependent command above.
    doccmd = doccmd(2:end);
end

if isempty(doccmd)
    % The preference was cleared in the preference dialog, so notify
    % the user there is no browser defined.
    handleWarning(message('MATLAB:web:NoBrowser'), ...
        options.warnOnSystemError, options.showWarningInDialog);
    stat = 1;
else
    % Use 'which' to determine if the user's browser exists, since we
    % can't catch an accurate status when attempting to start the
    % browser since it must be run in the background.
    [status,output] = unix(['which ' doccmd]);
    if status ~= 0
        handleWarning(message('MATLAB:web:BrowserNotFound', ...
            output), ...
            options.warnOnSystemError, options.showWarningInDialog);
        stat = 1;
    end
end

if stat == 0   
    % Need to escape ! on UNIX
    html_file = regexprep(html_file, '!','\\$0');
    
    % For the system browser, always send a file: URL
    if isOnFileSystem(html_file) && ~strcmp(html_file(1:5),'file:')
        html_file = ['file://' html_file];
    end
            
    % browser not running, then start it up.
    comm = [doccmd ' ' unixOptions ' ''' html_file ''' & '];
    [status,output] = unix(comm);
    if status
        stat = 1;
    end

    if stat ~= 0
        handleWarning(message('MATLAB:web:BrowserNotFound', ...
            output),options.warnOnSystemError, options.showWarningInDialog);

    end
end
end

%--------------------------------------------------------------------------
function stat = openWindowsBrowser(html_file,options)
if strncmp(html_file,'mailto:',7)
    % Use the user's default mail client.
    [stat,output] = dos(['cmd.exe /c start "" "' html_file '"']);
else
    html_file = strrep(html_file, '"', '\"');
    % If we're on the filesystem and there's an anchor at the end of
    % the URL, we need to strip it off; otherwise the file won't be
    % displayed in the browser.
    % This is a known limitation of the FileProtocolHandler.
    [file_exists,no_anchor] = isOnFileSystem(html_file);
    if file_exists
        html_file = no_anchor;
    end
    [stat,output] = dos(['cmd.exe /c rundll32 url.dll,FileProtocolHandler "' html_file '"']);
end

if stat ~= 0
    handleWarning(message('MATLAB:web:BrowserNotFound', ...
        output),options.warnOnSystemError, options.showWarningInDialog);
    
end
end

%--------------------------------------------------------------------------
function handleWarning(theMessage, warnOnSystemError, warnInDialog)
if warnOnSystemError
    displayWarningMessage(theMessage, warnInDialog);
end
end

%--------------------------------------------------------------------------
function displayWarningMessage(theMessage, warnInDialog)
if warnInDialog
    warndlg(getString(theMessage), getString(message('MATLAB:web:DialogTitleWarning')));
else
    warning(theMessage);
end
end

%--------------------------------------------------------------------------
function [onFileSystem,html_file] = isOnFileSystem(html_file)
onFileSystem = false;
html_file = stripAnchor(html_file);
if ~isempty(html_file)
    % If the path starts with "file:" assume it's on the local
    % filesystem and return.
    if length(html_file) >= 5 && strncmp(html_file, 'file:', 5)
        onFileSystem = true;
        return;
    end
    
    % If using the "file:" protocol OR the path begins with a forward slash
    % OR there is no protocol being used (no colon exists in the path), assume
    % it's on the filesystem.  Relative paths already should have been
    % converted to absolute before calling this function.
    if strcmp(html_file(1), '/') || isempty(strfind(html_file, ':'))
        onFileSystem = true;
    elseif ispc
        % On the PC, if the 2nd character is a colon OR the path begins
        % with 2 backward slashes, assume it's on the filesystem.
        if (strcmp(html_file(2), ':') || strcmp(html_file(1:2), '\\'))
            onFileSystem = true;
        end
    end
    
    % One last check, make sure the file actually exists...
    if onFileSystem
        if ~exist(html_file, 'file')
            onFileSystem = false;
        end
    end
end
end

%--------------------------------------------------------------------------
function html_file = stripAnchor(html_file)
    [html_file_dir,html_file_name,html_file_ext] = fileparts(html_file);
    anchor_pos = strfind(html_file_ext, '#');
    if ~isempty(anchor_pos)
        full_file_name = [html_file_name html_file_ext(1:anchor_pos-1)];
        html_file = fullfile(html_file_dir,full_file_name);
        if strncmp(html_file, 'file:', 5)
            html_file = strrep(html_file,'\','/');
        end
    end
end
