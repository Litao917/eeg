function [m,d] = aufinfo(filename)
%AUFINFO Text description of AU file contents.
%   AUFINFO will be removed in a future release. Use AUDIOINFO instead.
%
%   See also AUDIOREAD, AUDIOWRITE, AUDIOINFO.

%   Copyright 1984-2013 The MathWorks, Inc.

warning(message('MATLAB:audiovideo:aufinfo:functionToBeRemoved'));

try
    m = getString(message('MATLAB:audiovideo:auread:FInfoSoundAUFile'));
    
    % The AUFINFO function should succeed only for AU files. Replacing
    % audread with audioread will result in non-AU audio files also being
    % read in. As a result, the warning is being suppressed. This is
    % sufficient as this function will be deprecated.
    warnObj = warning('off', 'MATLAB:audiovideo:auread:functionToBeRemoved');
    warnObjCleanUp = onCleanup( @() warning(warnObj) );
    d = auread(filename, 'size');
    d = getString(message('MATLAB:audiovideo:auread:FInfoSoundAUFileContents', ...
                d(1), d(2)));
catch
    m = '';
    d = getString(message('MATLAB:audiovideo:auread:FInfoNotAUFile'));
end    
