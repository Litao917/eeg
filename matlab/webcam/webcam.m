function varargout = webcam(varargin)
%WEBCAM A tripline that specifies to install webcam support package.
    
%   Copyright 2013 The MathWorks, Inc.

varargout = {[]};

% Check if the support package is installed.
fullpathToUtility = which('matlab.webcam.internal.Utility');
if isempty(fullpathToUtility) 
    % Support package not installed - Error.
    if feature('hotlinks')
        error('MATLAB:webcam:supportPkgNotInstalled', message('MATLAB:webcam:webcam:supportPkgNotInstalled').getString);
    end
end