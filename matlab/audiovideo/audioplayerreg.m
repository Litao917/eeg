function audioplayerreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audioplayer objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2013 The MathWorks, Inc.

if ispc,
	WinAudioPlayer(lockOrUnlock);
else
    error(message('MATLAB:audiovideo:audioplayer:invalidPlatform'));
end