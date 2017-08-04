function sound(y,fs,bits)
%SOUND Play vector as sound.
%   SOUND(Y,FS) sends the signal in vector Y (with sample frequency
%   FS) out to the speaker on platforms that support sound. Values in
%   Y are assumed to be in the range -1.0 <= y <= 1.0. Values outside
%   that range are clipped.  Stereo sounds are played, on platforms
%   that support it, when Y is an N-by-2 matrix.
%
%   SOUND(Y) plays the sound at the default sample rate of 8192 Hz.
%
%   SOUND(Y,FS,BITS) plays the sound using BITS bits/sample if
%   possible.  Most platforms support BITS=8 or 16.
%
%   Example:
%     load handel
%     sound(y,Fs)
%   You should hear a snippet of Handel's Hallelujah Chorus.
%
%   See also SOUNDSC, AUDIOPLAYER.

%   Copyright 1984-2013 The MathWorks, Inc.

% Keep a list of running audioplayer objects
persistent playerObj;

if nargin<1, error(message('MATLAB:audiovideo:playsnd:invalidInputs')); end
if nargin<2, fs = 8192; end
if nargin<3, bits = 16; end

% Error handling for y
% Verify data is real and double.
if ~isreal(y) || issparse(y) || ~isfloat(y)
    error(message('MATLAB:audiovideo:playsnd:invalidDataType'));
end

% Error handling for fs
if (isempty(fs))
    error(message('MATLAB:audiovideo:sound:invalidfrequencyinput'));
end

% Error handling for bits
if (isempty(bits))
    error(message('MATLAB:audiovideo:sound:invalidbitdepthinput'));
end

% "Play" silence if y is empty
if (isempty(y))
    return;
end

% Make sure y is in the range +/- 1
y = max(-1,min(y,1));

% Make sure that there's one column
% per channel.
if ndims(y)>2, error(message('MATLAB:audiovideo:playsnd:twoDimValuesOnly')); end
if size(y,1)==1, y = y.'; end

try
    
  if isempty(playerObj)
    % initialize the audioplayer object list
    playerObj = audioplayer.empty;
  else
    % clear any players that are finished playing
    stoppedPlayers = arrayfun(@(x)(~isplaying(x)), playerObj);
    playerObj(stoppedPlayers) = [];
  end
     
  % construct a new audioplayer and add it to the list
  playerObj(end+1) = audioplayer(y, fs, bits);
  playerObj(end).StopFcn = @localRemoveAudioObj;

  play(playerObj(end));
catch exception
    throw(exception);
end

function localRemoveAudioObj(obj, ~)
    % clear the objects audio data
    % to reduce memory usage.
    obj.clearAudioData();
end

end

