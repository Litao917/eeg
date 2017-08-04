function h = constantline(varargin)
% CONSTANTLINE Create a line from a constant.
%    H = CONSTANTLINE(VAL) where VAL is a scalar creates a 
%    horizontal line at VAL. If VAL is a vector, it creates
%    a one line that looks like a set of lines, one at each value, 
%    returning just one handle.  To create vertical lines, use 
%    CHANGEDEPENDVAR method.
%
%    H = CONSTANTLINE(VAL,PARAM1,VALUE1,PARAM2,VALUE2) creates a line
%    with properties specified by the param value pairs.

%   Copyright 1984-2009 The MathWorks, Inc.

val = 0;
if nargin && ~ischar(varargin{1})
    % If the first argument is a char, assume p-v pairs, otherwise assume
    % the first argument is the value to place the line at.
    val = varargin{1};
    varargin(1) = [];
end

% Construct the line.  No xdata or ydata are initially required; the update
% method will set the correct values later.
h = graph2d.constantline('xdata',[],'ydata',[],varargin{:});  % calls built-in constructor

parent = get(h,'Parent');
curraxes = ancestor(parent,'axes');

% Initialize
h.value = val;       % Constant
% Install a listener for the axes limits
hgpkg = findpackage('hg');    % get handle to hg package
axesC = hgpkg.findclass('axes');
xlimP = axesC.findprop('xlim');
ylimP = axesC.findprop('ylim');
h.listenerAxes = handle.listener(curraxes, [xlimP ylimP], 'PropertyPostSet', {@localUpdateLine, h});

% Install a listener for the constantline Value and DependVar property
h.listenerValue = handle.listener(h, [h.findprop('Value') h.findprop('DependVar')], 'PropertyPostSet', {@localUpdateLine, h});

% Draw the line
update(h);

%-----------------------------------------------------------
function localUpdateLine(~, ~, hCline)
% LOCALUPDATELINE Callback to update constantline when axes limits change.
update(hCline);
