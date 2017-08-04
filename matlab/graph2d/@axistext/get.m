function val = get(A, varargin)
%AXISTEXT/GET Get axistext property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

HGObj = A.axischild;

if nargin == 2
   switch varargin{1}
   case 'XData'
      val = get(HGObj,'Position');
      val = val(1);
   case 'YData'
      val = get(HGObj,'Position');
      val = val(2);
   otherwise
      val = get(HGObj, varargin{:});
   end
else
   val = get(HGObj, varargin{:});
end

