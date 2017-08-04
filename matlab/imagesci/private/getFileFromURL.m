function [isUrl, filenameOut] = getFileFromURL(filenameIn)
%GETFILEFROMURL Detects whether the input filename is a URL and downloads
%file from the URL

%   Copyright 2007-2013 The MathWorks, Inc.

% Download remote file.
if (strfind(filenameIn, '://'))
  
    isUrl = true;

    if (~usejava('jvm'))
        error(message('MATLAB:imagesci:getFileFromURL:noJVM'))
    end
    
    try
        filenameOut = urlwrite(filenameIn, tempname);
    catch me
        error(message('MATLAB:imagesci:getFileFromURL:urlRead', filenameIn));
    end
    
else
  
    isUrl = false;
    filenameOut = filenameIn;
    
end
