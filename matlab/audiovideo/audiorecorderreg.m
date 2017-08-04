function audiorecorderreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audiorecorder objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2013 The MathWorks, Inc.

if ispc,
	WinAudioRecorder(lockOrUnlock);
else
	error(message('MATLAB:audiovideo:audiorecorder:invalidPlatform'));
end
