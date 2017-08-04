function run( appid )
% matlab.apputil.run Run an installed app.
% 
%   matlab.apputil.run(APPID) runs the specified app.  The app must be
%   installed.  APPID is a string containing the ID of the app as returned
%   by matlab.apputil.install when the app was installed or by
%   matlab.apputil.getInstalledAppInfo.
%
%   Example:
%
%     matlab.apputil.run('DataVisualizationAPP');
%
%   See also: matlab.apputil.create, matlab.apputil.install, matlab.apputil.getInstalledAppInfo.

% Copyright 2012 The MathWorks, Inc.

narginchk(1,1);
validateattributes(appid, {'char'}, {'row', 'vector'}, '', 'APPID');

appview = com.mathworks.appmanagement.AppManagementViewSilent;
appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);
infos = matlab.internal.apputil.getAllAppInfo(char(appAPI.getMyAppsLocation));

if isempty(infos)
    error(message('MATLAB:apputil:run:notinstalled'));
end

appIndex = matlab.internal.apputil.AppUtil.findAppIDs({infos.id}, appid, false);

if ~any((appIndex))
    error(message('MATLAB:apputil:run:notinstalled'));
end

if numel(infos(appIndex)) > 1
    error(message('MATLAB:apputil:run:findappfailed'));
end

appAPI.run(infos(appIndex).GUID);

end

