function [ pluginList, errFlag ] = privateMMReaderPluginSearch()
%MMREADERPLUGINSEARCH Locate mmreader plugins
%   [PLUGINLIST] = PRIVATEMMREADERPLUGINSEARCH locates all available
%   VideoReader plugin files and returns the fully qualified path to each 
%   in a cell array PLUGINLIST.   
%
%   VideoReader plugins are searched for in the mmreader plugins directory:
%
%       (matlabroot)/toolbox/matlab/audiovideo/bin/mmreader/plugins/(arch)
%
%   where (arch) is a given platform (maci, win32, etc).
%
%   PRIVATEMMREADERPLUGINSEARCH is used internally by VideoReader and is
%   not intended to be used directly by an end user. 

%   NH 
%   Copyright 2007-2013 The MathWorks, Inc.
%


% Initailize variables
pluginList = {};
errFlag = false;

osDir = computer('arch');
osExt = feature('GetSharedLibExt');

% Define the mmreader plugin path
pluginDir = fullfile(matlabroot, ...
    'toolbox', 'shared', 'multimedia', 'bin', osDir,'reader');
wildFile = ['*' osExt];

% Perform a wildecard search (i.e. *.dll) 
% for any VideoReader adaptors

searchPath = fullfile(pluginDir, wildFile );
dirList = dir(searchPath);

for ii=1:length(dirList)
    [~, pluginFileName] = fileparts( dirList(ii).name );
    pluginList = {pluginList{:} fullfile(pluginDir, pluginFileName)}; %#ok<CCAT>
end


end