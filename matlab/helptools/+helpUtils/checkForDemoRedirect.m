function [redirect,mapfile,topic] = checkForDemoRedirect(html_file)
% Internal use only.

%   Copyright 2012-2013 The MathWorks, Inc.

% Defaults.
redirect = false;
mapfile = '';
topic = '';

% WEB called with no arguments?
if isempty(html_file)
    return
end

% Under matlab/toolbox? (Use FILEPARTS to align fileseps).
[htmlDir,topic] = fileparts(fullfile(html_file));
toolbox = fullfile(matlabroot,'toolbox');
if ~strncmp(toolbox,htmlDir,numel(toolbox))
    return
end

% In an "html" directory?
relDir = strrep(htmlDir(numel(toolbox)+2:end),'\','/');
if isempty(regexp(relDir,'/html$','once')) 
    return
end
    
% In foodemos (or foodemo for wavedemo) or examples or fooexamples?
if isempty(regexp(relDir,'demos?/','once')) && ...
   isempty(regexp(relDir,'examples/','once'))
    return
end

% A corresponding map file?
[group,book,exdir] = mapDirToBook(relDir);
mapfile = fullfile(docroot,group,book,exdir,[book '_examples.map']);
if numel(dir(mapfile)) ~= 1
    return
end

% Contains topic?
topicMap = com.mathworks.mlwidgets.help.CSHelpTopicMap(mapfile);
if isempty(topicMap.mapID(topic))
    return
end

% Then redirect!
redirect = true;

end

%--------------------------------------------------------------------------
function [group,book,exdir] = mapDirToBook(relDir)

exdir = 'examples';
group = '';
dc = @(d)strncmp(relDir,[d '/'],numel(d)+1);
if dc('aero')
    book = 'aerotbx';
elseif dc('shared/eda') || dc('shared/tlmgenerator')
    book = 'hdlverifier';
elseif dc('globaloptim')
    book = 'gads';
elseif dc('idelink') || dc('target')
    book = 'rtw';
elseif dc('rfblks')
    book = 'simrf';
elseif dc('simulink/fixedandfloat')
    book = 'fixedpoint';
elseif dc('physmod')
    group = 'physmod';
    book = regexp(relDir,'(?<=/)[^\/]+','match','once');
    switch book
        case 'sh'
            book = 'hydro';
        case 'powersys'
            book = 'sps';
            exdir = 'examples_v2';
        case 'pe'
            book = 'sps';
            exdir = 'examples_v3';
        case 'mech'
            book = 'sm';
            exdir = 'examples_v1';
        case 'sm'
            exdir = 'examples_v2';
    end
elseif dc('rtw/targets')
    book = regexp(relDir,'(?<=targets\/)[^\/]+','match','once');
else
    book = regexp(relDir,'[^\/]+','match','once');
end
end
