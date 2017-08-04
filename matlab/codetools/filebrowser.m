function filebrowser
%FILEBROWSER Open Current Folder browser, or select it if already open
%   FILEBROWSER Opens the Current Folder browser or brings the Current
%   Folder browser to the front if it is already open.

%   Copyright 1984-2009 The MathWorks, Inc.

err = javachk('mwt', 'The Current Folder Browser');
if ~isempty(err)
    error(err);
end

try
    % Launch the Current Folder Browser
    com.mathworks.mde.explorer.Explorer.invoke;    
catch
    % Failed. Bail
    error(message('MATLAB:filebrowser:filebrowserFailed'));
end
