function hh = ylabel(varargin)
%YLABEL Y-axis label.
%   YLABEL('text') adds text beside the Y-axis on the current axis.
%
%   YLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the ylabel.
%
%   YLABEL(AX,...) adds the ylabel to the specified axes.
%
%   H = YLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, ZLABEL, TITLE, TEXT.

%   Copyright 1984-2013 The MathWorks, Inc.

narginchk(1,inf);

% if the input has a ylabel property which is a text object, use it to set
% the ylabel on.
[ax,args,nargs] = labelcheck('YLabel',varargin);
if isempty(ax)
    ax = gca;
    args = varargin;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error(message('MATLAB:ylabel:InvalidNumberOfInputs'))
end

string = args{1};
if isempty(string), string=''; end;
pvpairs = args(2:end);

if isappdata(ax,'MWBYPASS_ylabel')
  h = mwbypass(ax,'MWBYPASS_ylabel',string,pvpairs{:});

  %---Standard behavior
else
    h = get(ax,'YLabel');

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
