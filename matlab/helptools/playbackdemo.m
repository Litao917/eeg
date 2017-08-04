function playbackdemo(demoName,relativePath)
%PLAYBACKDEMO  Launch demo playback device
%   PLAYBACKDEMO(demoName) launches a playback demo in "$matlabroot/demos".
%
%   PLAYBACKDEMO(demoName,relativePath) specifies the relative path from
%   matlabroot to an arbitrary directory.
%
%   Example:
%      playbackdemo('desktop')

%   Copyright 1984-2013 The MathWorks, Inc.

% Define constants.
if (nargin < 2)
    relativePath = 'toolbox/matlab/web/demos';
else
    relativePath = strrep(relativePath,'\','/');
end
lang = lower(regexprep(get(0,'language'),'(..).*','$1'));
docLocale = char(com.mathworks.mlwidgets.help.HelpPrefs.getDocLocale);

% See first if it is found locally under MATLABROOT.
url = findLocalFile(relativePath,lang,docLocale,demoName);

% If not, build the URL to the web.
if isempty(url)
    product = regexp(relativePath,'(\w+)\/web\/demos$','tokens','once');
    if isempty(product)
        % The file isn't found and this directory it isn't a web directory.
        errordlg(sprintf('Can''t find %s',demoName));
        return
    else
        url = buildUrl(product{1},lang,docLocale,demoName);
    end
end

% Launch browser
web(url,'-browser','-display');

%==========================================================================
function url = findLocalFile(relativePath,lang,docLocale,demoName)
url = '';
htmlFilePaths = {fullfile(matlabroot,relativePath,[demoName '.html'])};
if ~strcmp(lang,'en') && ~strcmp(docLocale,'en')
    localizedFilePaths = {
        fullfile(matlabroot,relativePath,lang,[demoName '.html']);
        fullfile(matlabroot,relativePath,[demoName '_' lang '.html']);
        };
    htmlFilePaths = [localizedFilePaths; htmlFilePaths];
end
for iHtmlFilePaths = 1:numel(htmlFilePaths)
    htmlFilePath = htmlFilePaths{iHtmlFilePaths};
    if fileExists(htmlFilePath)
         url = htmlFilePath;
        break
    end
end

%==========================================================================
function tf = fileExists(html_file)
tf = exist(html_file,'file')==2;

%==========================================================================
function url = buildUrl(product,lang,docLocale,demoName)

if strcmp(lang,'ja') && ~strcmp(docLocale,'en')
    urlbase = 'http://www.mathworks.co.jp/support';
else
    urlbase = 'http://www.mathworks.com/support';
end
release = version('-release');
v = ver(product);
if isempty(v)
    wp = {urlbase,release,product,'demos',[demoName '.html']};
else
    productVersion = v.Version;
    wp = {urlbase,release,product,productVersion,'demos',[demoName '.html']};
end
url = strjoin(wp,'/');
