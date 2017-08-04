function htmlOut = makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
% MAKEREPORTHEADER  Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
% makeReportHeader( reportName, help, docPage, rerunAction, runOnThisDirAction )
%    reportName: the full name of the report
%    help: the report description
%    docpage: the html page in the matlab environment CSH book
%    rerunAction: the matlab command that would regenerate the report
%    runOnThisDirAction: the matlab command that generates the report for the cwd
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 2009-2012 The MathWorks, Inc.

htmlOut = {};

%% XML information
h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

%% The character set depends on the language

locale = feature('Locale');
% locale.ctype returns charset strings of this form:
%   ja_JP.Shift_JIS
%   en_US.windows-1252
% and so on. We remove language name and territory name to get the
% appropriate charset.
encoding = regexprep(locale.ctype,'(^.*\.)','');
% windows-949 shows garbled Korean text on win32, see g1029465
if strncmpi(locale.ctype,'ko_KR',5)
    if strcmpi(encoding,'windows-949')
        encoding = 'euc-kr';
    end
end
h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

%% Add cascading style sheet link
reportdir = fullfile(matlabroot,'toolbox','matlab','codetools','+internal','+matlab','+codetools','+reports');
cssfile = fullfile(reportdir,'matlab-report-styles.css');
h4 = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />', cssfile);

jsfile = fullfile(reportdir,'matlabreports.js');
h5 = sprintf('<script type="text/javascript" language="JavaScript" src="file:///%s"></script>',jsfile);

%% HTML header
htmlOut{1} = [h1 h2 h3 h4 h5];

htmlOut{2} = sprintf('<title>%s</title>', reportName);
htmlOut{3} = '</head>';
htmlOut{4} = '<body>';
htmlOut{5} = sprintf('<div class="report-head">%s</div><p>', reportName);

learnMoreTag = sprintf(['<a href="matlab:helpview([docroot ''/matlab/helptargets.map''], ''%s'')">' ...
    '%s</a>'],  docPage, getString(message('MATLAB:codetools:reports:LearnMore'))); 

reportDescription = [help ' ' getString(message('MATLAB:codetools:reports:LearnMoreParen', learnMoreTag))];

%% Descriptive text
htmlOut{6} = ['<div class="report-desc">' reportDescription '</div>'];

%% Rerun report buttons 
htmlOut{end+1} = '<table border="0"><tr>';
htmlOut{end+1} = '<td>';

htmlOut{end+1} = sprintf('<input type="button" value="%s" id="rerunThisReport" onclick="runreport(''%s'');" />',...
    getString(message('MATLAB:codetools:reports:RerunReport')), internal.matlab.codetools.reports.escape(rerunAction));
htmlOut{end+1} = '</td>';

htmlOut{end+1} = '<td>';
htmlOut{end+1} = sprintf('<input type="button" value="%s" id="runReportOnCurrent" onclick="runreport(''%s'');" />',...
    getString(message('MATLAB:codetools:reports:RunReport')), internal.matlab.codetools.reports.escape(runOnThisDirAction));
htmlOut{end+1} = '</td>';

htmlOut{end+1} = '</tr></table>';
end

