function hh = xlabel(varargin)
%XLABEL X-axis label.
%   XLABEL('text') adds text beside the X-axis on the current axis.
%
%   XLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the xlabel.
%
%   XLABEL(AX,...) adds the xlabel to the specified axes.
%
%   H = XLABEL(...) returns the handle to the text object used as the label.
%
%   See also YLABEL, ZLABEL, TITLE, TEXT.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1,inf);

% if the input has an xlabel property which is a text object, use it to set
% the xlabel on.
[ax,args,nargs] = labelcheck('XLabel',varargin);
if isempty(ax)
    ax = gca;
    args = varargin;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error(message('MATLAB:xlabel:InvalidNumberOfInputs'))
end

string = args{1};
if isempty(string), string=''; end;
pvpairs = args(2:end);

if isappdata(ax,'MWBYPASS_xlabel')
  h = mwbypass(ax,'MWBYPASS_xlabel',string,pvpairs{:});

  %---Standard behavior
else
  h = get(ax,'XLabel');

   if graphicsversion(ax,'handlegraphics')
       %Over-ride text objects default font attributes with
       %the Axes' default font attributes.
       set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
              'FontName',   get(ax, 'FontName'), ...
              'FontUnits',  get(ax, 'FontUnits'),...
              'FontSize',   get(ax, 'FontSize'), ...
              'FontWeight', get(ax, 'FontWeight'));
    else
        set(h,'FontAngleMode','auto',...
            'FontNameMode','auto',...
            'FontUnitsMode','auto',...
            'FontSizeMode','auto',...
            'FontWeightMode','auto');
   end

   set(h, 'String', string, pvpairs{:});
   
end

if nargout > 0
  hh = h;
end
