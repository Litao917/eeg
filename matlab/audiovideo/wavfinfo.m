function [m,d] = wavfinfo(filename)
%WAVFINFO Text description of WAV file contents.
%   WAVFINFO will be removed in a future release. Use AUDIOINFO instead.
%
%   See also AUDIOREAD, AUDIOWRITE, AUDIOINFO.

% Copyright 1984-2013 The MathWorks, Inc.

warning(message('MATLAB:audiovideo:wavfinfo:functionToBeRemoved'));

try
    m = getString(message('MATLAB:audiovideo:wavread:FInfoSoundWAVFile'));
    
    % The WAVFINFO function should succeed only for WAV files. Replacing
    % wavread with audioread will result in non-WAV audio files also being
    % read in. As a result, the warning is being suppressed. This is
    % sufficient as this function will be deprecated.
    warnObj = warning('off', 'MATLAB:audiovideo:wavread:functionToBeRemoved');
    warnObjCleanUp = onCleanup( @() warning(warnObj) );
    d = wavread(filename, 'size');
    d = getString(message('MATLAB:audiovideo:wavread:FInfoSoundWAVFileContents', ...
                d(1), d(2)));
catch
    m = '';
    d = getString(message('MATLAB:audiovideo:wavread:FInfoNotWAVEFile'));
end    
