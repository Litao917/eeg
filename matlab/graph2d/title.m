function hh = title(varargin)
%TITLE  Graph title.
%   TITLE('text') adds text at the top of the current axis.
%
%   TITLE('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the title.
%
%   TITLE(AX,...) adds the title to the specified axes.
%
%   H = TITLE(...) returns the handle to the text object used as the title.
%
%   See also XLABEL, YLABEL, ZLABEL, TEXT.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1,inf);

% if the input has a title property which is a text object, use it to set
% the title on.
[ax,args,nargs] = labelcheck('Title',varargin);
if isempty(ax)
    ax = gca;
    args = varargin;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error(message('MATLAB:title:InvalidNumberOfInputs'))
end

string = args{1};
if isempty(string), string=''; end;
pvpairs = args(2:end);

%---Check for bypass option
if isappdata(ax,'MWBYPASS_title')       
   h = mwbypass(ax,'MWBYPASS_title',string,pvpairs{:});

%---Standard behavior      
else
   h = get(ax,'Title');

   if graphicsversion(ax,'handlegraphics')
       %Over-ride text objects default font attributes with
       %the Axes' default font attributes.
       set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
              'FontName',   get(ax, 'FontName'), ...
              'FontUnits',  get(ax, 'FontUnits'), ...
              'FontSize',   get(ax, 'FontSize'), ...
              'FontWeight', get(ax, 'FontWeight'), ...
              'Rotation',   0);
   end

   set(h, 'String', string, pvpairs{:});
      
end

if nargout > 0
  hh = h;
end
