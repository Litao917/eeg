function y = ifftn(varargin)
%IFFTN Overloaded function for UINT8 input.

%   Copyright 1984-2007 The MathWorks, Inc. 

for k = 1:length(varargin)
    if (isa(varargin{k},'uint8'))
        varargin{k} = double(varargin{k});
    end
end
y = ifftn(varargin{:});
