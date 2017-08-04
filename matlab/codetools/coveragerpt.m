function htmlOut = coveragerpt(dirname)
%COVERAGERPT  Audit a folder for profiler line coverage
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   COVERAGERPT checks which lines of which files have been executed by the
%   last generated profile.
%
%   COVERAGERPT(DIRNAME) scans the specified folder.
%
%   HTMLOUT = COVERAGERPT(...) returns the generated HTML text as a cell array
%
%   See also PROFILE, MLINT, DEPRPT, HELPRPT, CONTENTSRPT

% Copyright 1984-2013 The MathWorks, Inc.

reportName = getString(message('MATLAB:codetools:reports:CoverageReportName'));

if nargout == 0
    internal.matlab.codetools.reports.displayLoadingMessage(reportName);
end

if nargin < 1
    dirname = cd;
end

fileList = internal.matlab.codetools.reports.buildCoverageInfo(dirname, reportName);

%% Make the Header
help = [getString(message('MATLAB:codetools:reports:CoverageReportDescription')) ' '];
docPage = 'matlab_env_coverage_rpt';
rerunAction = sprintf('coveragerpt(''%s'')', dirname);
thisDirAction = 'coveragerpt';

% Now generate the HTML
s = internal.matlab.codetools.reports.makeReportHeader(reportName, help, docPage, rerunAction, thisDirAction);

s{end+1} = [getString(message('MATLAB:codetools:reports:ReportForSpecificFolder', dirname)) '<p>'];

% pixel gif location
pixelPath = ['file:///' fullfile(matlabroot,'toolbox','matlab','codetools','private')];
whitePixelGif = fullfile(pixelPath, 'one-pixel-white.gif');
bluePixelGif = fullfile(pixelPath, 'one-pixel.gif');

% Make sure there is something to show before you build the table
if numel(fileList) == 1 && isempty(fileList.name)
    s{end+1} = [getString(message('MATLAB:codetools:reports:NoMATLABCodeFilesInThisFolder')) '<p>'];
else
    [~, ndx] = sort([fileList.coverage]);
    fileList = fileList(fliplr(ndx));
    
    s{end+1} = '<table cellspacing="0" cellpadding="2" border="0">';
    % Loop over all the files in the structure
    for n = 1:length(fileList)
        encoded = urlencode(fullfile(dirname, fileList(n).name));
        decoded = urldecode(encoded);
        reportComponent = sprintf('%s', fileList(n).name);
        openInEditor = sprintf('edit(''%s'')',decoded);
        
        if isempty(fileList(n).funlist)
            s{end+1} ='<tr><td valign="top" colspan="2" class="td-linetop">';
            s = getFileNameAsHyperlink(s, reportComponent, openInEditor);
        else
            % First put a header on for the whole file
            s{end+1} = '<tr><td valign="top" class="td-linetop">';
            s = getFileNameAsHyperlink(s, reportComponent, openInEditor);
            s{end+1} = '<td valign="top" class="td-linetopleft">';
            s{end+1} = '<div style="border:1px solid black; padding:2px; margin:4px; width: 100px;">';
            s{end+1} = sprintf('<img src="%s" width="%d" height="10" />', ...
                bluePixelGif, round(fileList(n).coverage));
            s{end+1} = sprintf('<img src="%s" width="%d" height="10" /></div>', ...
                whitePixelGif, round(100-fileList(n).coverage));
            
            if length(fileList(n).funlist) == 1
                
                s{end+1} = ['<a href="matlab: profview(' sprintf('%d',fileList(n).funlist(1).profindex) ',profile(''info''))">' getString(message('MATLAB:codetools:reports:CoverageHeader')) '</a>:' sprintf('%4.1f%%',fileList(n).funlist(1).coverage) '<br/>'];
                s{end+1} = ['<span style="font-size:small;">' getString(message('MATLAB:codetools:reports:TotalTime')) ' ' getString(message('MATLAB:codetools:reports:NumberOfSeconds', sprintf('%4.1f', fileList(n).funlist(1).totaltime))) '</span><br/>'];
                s{end+1} = ['<span style="font-size:small;">' getString(message('MATLAB:codetools:reports:TotalLines', fileList(n).funlist(1).runnablelines)) '</span><br/>'];
                s{end+1} = '</td>';
                s{end+1} = '</tr>';
                
            else
                
                s{end+1} = ['<span style="font-size:small;">' ...
                    getString(message('MATLAB:codetools:reports:TotalCoveragePercentage', sprintf('%4.1f', fileList(n).coverage))) ...
                    '</span></td>'];
                s{end+1} = '</tr>';
                
                for m = 1:length(fileList(n).funlist)
                    s{end+1} = sprintf('<tr><td valign="top" class="td-dashtop">&nbsp;&nbsp;<a href="matlab: opentoline(''%s'',%d)"><span class="mono">%s</span></a></td>', ...
                        fullfile(dirname,fileList(n).name), fileList(n).funlist(m).firstline, fileList(n).funlist(m).name);
                    
                    if fileList(n).funlist(m).coverage == 0
                        s{end+1} = '<td valign="top" class="td-dashtopleft"></td>';
                    else
                        s{end+1} = '<td valign="top" class="td-dashtopleft">';
                        s{end+1} = sprintf(['<a href="matlab: profview(%d,profile(''info''))">' getString(message('MATLAB:codetools:reports:CoverageHeader')) '</a>: %4.1f%%<br/>'], ...
                            fileList(n).funlist(m).profindex, ...
                            fileList(n).funlist(m).coverage);
                        s{end+1} = ['<span style="font-size:small;">' getString(message('MATLAB:codetools:reports:TotalTime')) ' ' getString(message('MATLAB:codetools:reports:NumberOfSeconds', sprintf('%4.1f', fileList(n).funlist(m).totaltime))) '</span><br/>'];
                        s{end+1} = ['<span style="font-size:small;">' getString(message('MATLAB:codetools:reports:TotalLines', fileList(n).funlist(m).runnablelines)) '</span><br/>'];
                        s{end+1} = '</td>';
                    end
                    s{end+1} = '</tr>';
                end
            end
            
        end
    end
    s{end+1} = '</table>';
end

s{end+1} = '</body></html>';

if nargout==0
    sOut = [s{:}];
    web(['text://' sOut],'-noaddressbox');
else
    htmlOut = s;
end
end
%#ok<*AGROW>

function s = getFileNameAsHyperlink(s, reportComponent, openInEditor)
s{end+1} = ['<a href="matlab:' openInEditor '"> '];
s{end+1} = ['<span class= "mono">' reportComponent  '</span>'];
s{end+1} = '</a></td>';
end
