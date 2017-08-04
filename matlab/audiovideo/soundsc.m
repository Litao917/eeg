function soundsc(varargin)
%SOUNDSC Autoscale and play vector as sound.
%   SOUNDSC(Y,...) is the same as SOUND(Y,...) except the data is
%   scaled so that the sound is played as loud as possible without
%   clipping.  The mean of the dynamic range of the data is set to
%   zero after the normalization.
%
%   SOUNDSC(Y,...,SLIM) where SLIM = [SLOW SHIGH] linearly scales
%   values in Y in the range [SLOW, SHIGH] to [-1, 1].  Values
%   outside this range are not clipped.  By default, SLIM is
%   [MIN(Y) MAX(Y)].
%
%   See also SOUND, AUDIOPLAYER, AUDIORECORDER.

%   Copyright 1984-2013 The MathWorks, Inc.

% Determine if user entered SLIM vector:
%

if nargin<1, error(message('MATLAB:audiovideo:soundsc:invalidInputs')); end
x = varargin{1};

% Verify data is real and double.
if ~isreal(x) || issparse(x) || ~isfloat(x)
    error(message('MATLAB:audiovideo:playsnd:invalidDataType'));
end

user_scale = (nargin>1) & isequal(size(varargin{end}),[1 2]);

% Determine scaling vector, SLIM:
%
xmin = min(x(:));
xmax = max(x(:));
if user_scale,
    slim = varargin{end};
    varargin = varargin(1:end-1);  % remove SLIM from arg list
else
    slim = [xmin xmax];
end

% Scale the data so that the limits in
% SLIM are scaled to the range [-1 +1]
%
dx=diff(slim);
if dx==0,
    % Protect against divide-by-zero errors:
    varargin{1} = zeros(size(varargin{1}));
else
	varargin{1} = (x-slim(1))/dx*2-1;
end

% Play the scaled sequence:
sound(varargin{:})

% [EOF] soundsc.m
