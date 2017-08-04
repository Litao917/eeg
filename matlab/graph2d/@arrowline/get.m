function val = get(A, varargin)
%ARROWLINE/GET Get arrowline property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

if nargin == 2
   switch varargin{1}
   % case 'XData'
   %    val = A.XData;
   % case 'YData'
   %    val = A.YData;
   case {'LineWidth' 'Color' 'LineStyle' 'EraseMode'}
      val = get(A.line, varargin{:});
   case 'UIContextMenu'
      val = getscribecontextmenu(A.line);
   otherwise
      editlineObj = A.editline;
      val = get(editlineObj, varargin{:});
   end
else
   editlineObj = A.editline;
   val = get(editlineObj, varargin{:});
end

