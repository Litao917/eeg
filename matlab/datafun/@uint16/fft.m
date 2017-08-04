function y = fft(varargin)
%FFT Overloaded function for UINT16 input.

%   Copyright 1984-2007 The MathWorks, Inc. 

for k = 1:length(varargin)
    if (isa(varargin{k},'uint16'))
        varargin{k} = double(varargin{k});
    end
end

y = fft(varargin{:});
