function varargout = fileExchangeDesktopTool()
%FILEEXCHANGEDESKTOPTOOL opens the File Exchange Desktop Tool and brings the GUI to 
% the forefront
% 
% From behind a firewall, use the Preferences to set your proxy server.
%
% Copyright 1984-2012 The MathWorks, Inc.

% This function requires Java.
if ~usejava('jvm')
   error(message('MATLAB:checkFilesDirInputs:NoJvm', upper(mfilename)));
end

% create the desktop tool
handle = com.mathworks.webintegration.fileexchange.ui.FileExchangeDesktopClientFactory.getInstance;

% now display it
import com.mathworks.mde.desk.MLDesktop;
if (com.mathworks.webintegration.fileexchange.ui.FileExchangeDesktopClientImpl.isFeatureEnabled)
    MLDesktop.getInstance.showClient(MLDesktop.FILE_EXCHANGE_NAME);
end

if nargout==1
    varargout={handle};
end
