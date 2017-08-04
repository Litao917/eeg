function y = conv2(varargin)
%CONV2 Overloaded function for UINT16 input.

%   Copyright 1984-2010 The MathWorks, Inc. 

warnIssued = false;
for k = 1:length(varargin)
  if (isa(varargin{k},'uint16'))
    if ~warnIssued && (k == 1 || k == 2)
      warning(message('MATLAB:conv2:uint16Obsolete'));
      warnIssued = true;
    end
    varargin{k} = double(varargin{k});
  end
end

y = conv2(varargin{:});

