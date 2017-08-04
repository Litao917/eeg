function ret = mmcompinfo(varargin)
%MMCOMPINFO Multimedia compressor information.
%   COMPINFO = MMCOMPINFO returns a structure COMPINFO containing two 
%   fields, audio compressors and video decompressors.  Each of these 
%   fields is an array of structures, each structure containing 
%   information about one of the audio/video compressors on the 
%   system.  The individual codec structure fields are Name (name of 
%   the codec, string) and ID (the codec's ID).
%
%   MMCOMPINFO(AorV) returns the number of audio or video 
%   compresors on the system.  Set AorV = 'audio' for audio, AorV = 
%   'video' for video.
%
%   MMCOMPINFO(AorV, NAME) returns the ID of the audio or 
%   video compressor with the given name.  If no audio/video 
%   compressor is found with the given name, -1 is returned.
%
%   MMCOMPINFO(AorV, ID) returns the name of the audio or 
%   video compressor with the given ID.
%
%   This function is only for use with 32-bit Windows machines.
%
%   See also MMFILEINFO, AUDIODEVINFO. 

%    Author(s): BJW
%    Copyright 1984-2013 The MathWorks, Inc.

if ~ ispc,
   error(message('MATLAB:audiovideo:mmcompinfo:invalidPlatform'));
end

error(nargchk(0,2,nargin));

if nargin ~= 0,
% specific request
    ret = MMCodecChooserMex(varargin{:});
else
% give back all information about devices
    numAudioCompressors = MMCodecChooserMex('audio');
    numVideoCompressors = MMCodecChooserMex('video');
    
    audioCompressors = [];
    videoCompressors = [];
    
    for i=1:numAudioCompressors,
        audioCompressors(i).Name = MMCodecChooserMex('audio', i - 1);
        audioCompressors(i).ID = i - 1;
    end
    
    for i=1:numVideoCompressors,
        videoCompressors(i).Name = MMCodecChooserMex('video', i - 1);
        videoCompressors(i).ID = i - 1;
    end
    
    ret.audioCompressors = audioCompressors;
    ret.videoCompressors = videoCompressors;
end

% [EOF] mmcompinfo.m